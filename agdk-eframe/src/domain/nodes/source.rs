use actix::prelude::*;
use anyhow::{anyhow, Error};
use chrono::{DateTime, Utc};
use gst::prelude::*;
use std::collections::HashMap;
use tracing::{debug, instrument, trace};

use crate::shared::{
    make_element,
    pipeline_manager::{PipelineManager, StopManagerMessage, WaitForEosMessage},
    schedulable::{Schedulable, StateChangeResult, StateMachine},
    stream_producer::StreamProducer,
    ErrorMessage,
};
use auteur_controlling::controller::{NodeInfo, SourceInfo, State};
use super::messages::{
    AddControlPointMessage, GetNodeInfoMessage, GetProducerMessage, NodeStatusMessage,
    RemoveControlPointMessage, ScheduleMessage, StartMessage, StopMessage, StoppedMessage,
};
use super::node::NodeManager;

/// A source processing node.
///
/// The actual source depends on its URI scheme.
/// `videotestsrc` and `audiotestsrc` are used for `test://`,
/// `filesrc` is used for `file://`, and `uridecodebin` for everything
/// else.
///
/// The output of the source is propagated through a
/// [`StreamProducer`](crate::shared::stream_producer::StreamProducer).
pub struct Source {
    /// Unique identifier
    id: String,
    /// The URI this source is playing
    uri: String,
    /// Video-related elements
    video_producer: Option<StreamProducer>,
    /// Audio-related elements
    audio_producer: Option<StreamProducer>,
    /// The wrapped pipeline
    pipeline: gst::Pipeline,
    /// A helper for managing the pipeline
    pipeline_manager: Option<Addr<PipelineManager>>,
    /// Our state machine
    state_machine: StateMachine,
}

impl Actor for Source {
    type Context = Context<Self>;

    #[instrument(level = "debug", name = "starting", skip(self, ctx), fields(id = %self.id))]
    fn started(&mut self, ctx: &mut Context<Self>) {
        self.pipeline_manager = Some(
            PipelineManager::new(
                self.pipeline.clone(),
                ctx.address().downgrade().recipient(),
                &self.id,
            )
            .start(),
        );
    }

    #[instrument(level = "debug", name = "stopping", skip(self, _ctx), fields(id = %self.id))]
    fn stopping(&mut self, _ctx: &mut Context<Self>) -> Running {
        if let Some(manager) = self.pipeline_manager.take() {
            manager.do_send(StopManagerMessage);
        }

        Running::Stop
    }

    #[instrument(level = "debug", name = "stopped", skip(self, _ctx), fields(id = %self.id))]
    fn stopped(&mut self, _ctx: &mut Self::Context) {
        NodeManager::from_registry().do_send(StoppedMessage {
            id: self.id.clone(),
            video_producer: self.video_producer.clone(),
            audio_producer: self.audio_producer.clone(),
        });
    }
}

impl Source {
    /// Create a source
    #[instrument(level = "debug", name = "creating")]
    pub fn new(id: &str, uri: &str, audio: bool, video: bool) -> Self {
        let video_producer = if video {
            let appsink = gst::ElementFactory::make("appsink")
                .name(&format!("src-video-appsink-{}", id))
                .build()
                .unwrap()
                .downcast::<gst_app::AppSink>()
                .unwrap();
            Some(StreamProducer::from(&appsink))
        } else {
            None
        };

        let audio_producer = if audio {
            let appsink = gst::ElementFactory::make("appsink")
                .name(&format!("src-audio-appsink-{}", id))
                .build()
                .unwrap()
                .downcast::<gst_app::AppSink>()
                .unwrap();
            Some(StreamProducer::from(&appsink))
        } else {
            None
        };

        let pipeline = gst::Pipeline::new();
        pipeline.upcast_ref::<gst::Object>().set_name(&format!("source-pipeline-{}", id));

        Self {
            id: id.to_string(),
            uri: uri.to_string(),
            video_producer,
            audio_producer,
            pipeline,
            pipeline_manager: None,
            state_machine: StateMachine::default(),
        }
    }

    /// Start our pipeline when cue_time is reached
    #[instrument(level = "debug", name = "playing", skip(self, ctx), fields(id = %self.id))]
    fn start_pipeline(&mut self, ctx: &mut Context<Self>) -> Result<StateChangeResult, Error> {
        let src = make_element("uridecodebin3", None)?;
        src.set_property("uri", &self.uri);

        let pcm_resample = make_element("audioresample", None)?;
        let pcm_convert = make_element("audioconvert", None)?;
        let video_convert = make_element("videoconvert", None)?;

        self.pipeline.add_many(&[
            &src,
            &pcm_resample,
            &pcm_convert,
            &video_convert,
        ])?;

        if let Some(ref video_producer) = self.video_producer {
            self.pipeline
                .add(video_producer.appsink().upcast_ref::<gst::Element>())?;
            gst::Element::link_many(&[&video_convert, video_producer.appsink().upcast_ref()])?;
        }

        if let Some(ref audio_producer) = self.audio_producer {
            self.pipeline
                .add(audio_producer.appsink().upcast_ref::<gst::Element>())?;
            gst::Element::link_many(&[
                &pcm_convert,
                &pcm_resample,
                audio_producer.appsink().upcast_ref(),
            ])?;
        }

        let pipeline_weak = self.pipeline.downgrade();
        let video_convert_clone = video_convert.clone();
        let pcm_convert_clone = pcm_convert.clone();
        src.connect_pad_added(move |_src, pad| {
            if let Some(_pipeline) = pipeline_weak.upgrade() {
                let (is_video, _is_audio) = {
                    let media_type = pad.current_caps().and_then(|caps| {
                        caps.structure(0).map(|s| {
                            let name = s.name();
                            (name.starts_with("video/"), name.starts_with("audio/"))
                        })
                    });
                    media_type.unwrap_or((false, false))
                };

                if is_video {
                    let sinkpad = video_convert_clone.static_pad("sink").unwrap();
                    if !sinkpad.is_linked() {
                        pad.link(&sinkpad).unwrap();
                    }
                } else {
                    let sinkpad = pcm_convert_clone.static_pad("sink").unwrap();
                    if !sinkpad.is_linked() {
                        pad.link(&sinkpad).unwrap();
                    }
                }
            }
        });

        let addr = ctx.address();
        let id_clone = self.id.clone();
        self.pipeline.call_async(move |pipeline| {
            if let Err(err) = pipeline.set_state(gst::State::Playing) {
                addr.do_send(ErrorMessage {
                    message: format!("Failed to start source {}: {}", id_clone, err),
                });
            }
        });

        if let Some(ref producer) = self.video_producer {
            producer.forward();
        }
        if let Some(ref producer) = self.audio_producer {
            producer.forward();
        }

        Ok(StateChangeResult::Success)
    }

    #[instrument(level = "debug", skip(self, ctx), fields(id = %self.id))]
    fn stop(&mut self, ctx: &mut Context<Self>) {
        self.stop_schedule(ctx);
        ctx.stop();
    }
}

impl Schedulable<Self> for Source {
    fn state_machine(&self) -> &StateMachine {
        &self.state_machine
    }

    fn state_machine_mut(&mut self) -> &mut StateMachine {
        &mut self.state_machine
    }

    fn node_id(&self) -> &str {
        &self.id
    }

    fn next_time(&self) -> Option<DateTime<Utc>> {
        match self.state_machine.state {
            State::Initial => self.state_machine.cue_time,
            State::Starting => self.state_machine.cue_time,
            State::Started => self.state_machine.end_time,
            State::Stopping => None,
            State::Stopped => None,
        }
    }

    fn transition(
        &mut self,
        ctx: &mut Context<Self>,
        target: State,
    ) -> Result<StateChangeResult, Error> {
        match target {
            State::Initial => Ok(StateChangeResult::Success), // FIXME
            State::Starting => self.start_pipeline(ctx),
            State::Started => Ok(StateChangeResult::Success),
            State::Stopping => {
                self.stop(ctx);
                Ok(StateChangeResult::Success)
            }
            State::Stopped => unreachable!(),
        }
    }
}

impl Handler<StartMessage> for Source {
    type Result = MessageResult<StartMessage>;

    fn handle(&mut self, msg: StartMessage, ctx: &mut Context<Self>) -> Self::Result {
        MessageResult(self.start_schedule(ctx, msg.cue_time, msg.end_time))
    }
}

impl Handler<ErrorMessage> for Source {
    type Result = ();

    fn handle(&mut self, msg: ErrorMessage, ctx: &mut Context<Self>) -> Self::Result {
        NodeManager::from_registry().do_send(NodeStatusMessage::Error {
            id: self.id.clone(),
            message: msg.message,
        });
        gst::debug_bin_to_dot_file_with_ts(
            &self.pipeline,
            gst::DebugGraphDetails::all(),
            &format!("error-source-{}", self.id),
        );
        self.stop(ctx);
    }
}

impl Handler<GetProducerMessage> for Source {
    type Result = MessageResult<GetProducerMessage>;

    fn handle(&mut self, _msg: GetProducerMessage, _ctx: &mut Context<Self>) -> Self::Result {
        MessageResult(Ok((
            self.video_producer.clone(),
            self.audio_producer.clone(),
        )))
    }
}

impl Handler<ScheduleMessage> for Source {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: ScheduleMessage, ctx: &mut Context<Self>) -> Self::Result {
        self.reschedule(ctx, msg.cue_time, msg.end_time)
    }
}

impl Handler<StopMessage> for Source {
    type Result = Result<(), Error>;

    fn handle(&mut self, _msg: StopMessage, ctx: &mut Context<Self>) -> Self::Result {
        self.stop(ctx);
        Ok(())
    }
}

impl Handler<GetNodeInfoMessage> for Source {
    type Result = Result<NodeInfo, Error>;

    fn handle(&mut self, _msg: GetNodeInfoMessage, _ctx: &mut Context<Self>) -> Self::Result {
        Ok(NodeInfo::Source(SourceInfo {
            uri: self.uri.clone(),
            video_consumer_slot_ids: self
                .video_producer
                .as_ref()
                .map(|p| p.get_consumer_ids()),
            audio_consumer_slot_ids: self
                .audio_producer
                .as_ref()
                .map(|p| p.get_consumer_ids()),
            cue_time: self.state_machine.cue_time,
            end_time: self.state_machine.end_time,
            state: self.state_machine.state,
        }))
    }
}

impl Handler<AddControlPointMessage> for Source {
    type Result = Result<(), Error>;
    fn handle(&mut self, _msg: AddControlPointMessage, _ctx: &mut Context<Self>) -> Self::Result {
        Err(anyhow!("Source has no property to control"))
    }
}

impl Handler<RemoveControlPointMessage> for Source {
    type Result = ();
    fn handle(
        &mut self,
        _msg: RemoveControlPointMessage,
        _ctx: &mut Context<Self>,
    ) {
    }
}