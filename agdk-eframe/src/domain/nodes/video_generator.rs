use tracing::{debug, error, instrument, trace};
use chrono::{DateTime, Utc};
use gst::prelude::*;
use anyhow::{anyhow, Error};
use actix::prelude::*;
/// A source processing node for video generation

use crate::shared::{
    make_element,
    pipeline_manager::{PipelineManager, StopManagerMessage},
    schedulable::{Schedulable, StateChangeResult, StateMachine},
    stream_producer::StreamProducer,
    ErrorMessage,
};
use actix::MessageResult;
use auteur_controlling::controller::{NodeInfo, SourceInfo, State};
use super::messages::{
    AddControlPointMessage, GetNodeInfoMessage, GetProducerMessage, NodeStatusMessage,
    RemoveControlPointMessage, ScheduleMessage, StartMessage, StopMessage, StoppedMessage,
};
use super::node::NodeManager;

/// The pipeline and various GStreamer elements that the source
/// optionally wraps, their lifetime is not directly bound to that
/// of the source itself
#[derive(Debug)]
struct Media {
    /// The wrapped pipeline
    pipeline: gst::Pipeline,
    /// A helper for managing the pipeline
    pipeline_manager: Addr<PipelineManager>,
    /// `videotestsrc`
    src: gst::Element,
    /// Vector of `fallbackswitch`, only used to monitor status
    switches: Vec<gst::Element>,
    /// Increments when the src element exposes pads, decrements
    /// when they receive EOS
    n_streams: u32,
    /// `urisourcebin`, only used to monitor status
    source_bin: Option<gst::Element>,
}

/// The Source actor
pub struct VideoGenerator {
    /// Unique identifier
    id: String,
    /// Output video producer
    video_producer: Option<StreamProducer>,
    /// GStreamer elements when prerolling or playing
    media: Option<Media>,
    /// Statistics timer
    monitor_handle: Option<SpawnHandle>,
    /// Our state machine
    state_machine: StateMachine,
} // <- This was missing!

impl VideoGenerator {
    /// Create a source
    #[instrument(level = "debug", name = "creating")]
    pub fn new(id: &str) -> Self {
        let video_producer = {
            Some(StreamProducer::from(
                &gst::ElementFactory::make("appsink")
                    .name(&format!("src-video-appsink-{}", id))
                    .build()
                    .unwrap()
                    .downcast::<gst_app::AppSink>()
                    .unwrap(),
            ))
        };
        Self {
            id: id.to_string(),
            video_producer,
            media: None,
            monitor_handle: None,
            state_machine: StateMachine::default(),
        }
    }

    /// Connect pads exposed by `videotestsrc` to our output producers
    #[instrument(level = "debug", name = "connecting", skip(pipeline, is_video, pad, video_producer), fields(pad = %pad.name()))]
    fn connect_pad(
        _id: String,
        is_video: bool,
        pipeline: &gst::Pipeline,
        pad: &gst::Pad,
        video_producer: &Option<StreamProducer>,
    ) -> Result<Option<gst::Element>, Error> {
        if is_video {
            if let Some(video_producer) = video_producer {
                let deinterlace = make_element("deinterlace", None)?;
                pipeline.add(&deinterlace)?;
                let appsink = video_producer.appsink();
                debug!(appsink = %appsink.name(), "linking video stream");
                deinterlace.sync_state_with_parent()?;
                let sinkpad = deinterlace.static_pad("sink").unwrap();
                pad.link(&sinkpad)?;
                deinterlace.link(&appsink)?;
                Ok(Some(appsink.upcast()))
            } else {
                Ok(None)
            }
        } else {
            Ok(None)
        }
    } // <- This was missing!

    /// Preroll the pipeline ahead of time (by default 10 seconds before cue time)
    #[instrument(level = "debug", name = "prerolling", skip(self, ctx), fields(id = %self.id))]
    fn preroll(&mut self, ctx: &mut Context<Self>) -> Result<StateChangeResult, Error> {
        let pipeline = gst::Pipeline::with_name(&self.id.to_string());
        if let Some(ref video_producer) = self.video_producer {
            pipeline.add(video_producer.appsink().upcast_ref::<gst::Element>())?;
        }

        let src = make_element("videotestsrc", None)?;
        pipeline.add(&src)?;
        src.set_property("flip", &true);
        src.set_property("is-live", &true);
        src.set_property_from_str("pattern", "ball");
        
        let pipeline_clone = pipeline.downgrade();
        let addr = ctx.address();
        let video_producer = self.video_producer.clone();
        let id = self.id.clone();
        src.connect_pad_added(move |_src, pad| {
            if let Some(pipeline) = pipeline_clone.upgrade() {
                let is_video = pad.name() == "video";
                match VideoGenerator::connect_pad(
                    id.clone(),
                    is_video,
                    &pipeline,
                    pad,
                    &video_producer,
                ) {
                    Ok(Some(appsink)) => {
                        let addr_clone = addr.clone();
                        let pad = appsink.static_pad("sink").unwrap();
                        pad.add_probe(gst::PadProbeType::EVENT_DOWNSTREAM, move |_pad, info| {
                            match info.data {
                                Some(gst::PadProbeData::Event(ref ev))
                                    if ev.type_() == gst::EventType::Eos =>
                                {
                                    addr_clone.do_send(StreamMessage { starting: false });
                                    gst::PadProbeReturn::Drop
                                }
                                _ => gst::PadProbeReturn::Ok,
                            }
                        });
                        addr.do_send(StreamMessage { starting: true });
                    }
                    Ok(None) => (),
                    Err(err) => addr.do_send(ErrorMessage {
                        message: format!("Failed to connect source stream: {:?}", err),
                    }),
                }
            }
        });

        let addr_clone = ctx.address();
        src.connect("notify::status", false, move |_args| {
            addr_clone.do_send(SourceStatusMessage);
            None
        });

        let addr_clone = ctx.address();
        src.connect("notify::statistics", false, move |_args| {
            addr_clone.do_send(SourceStatusMessage);
            None
        });

        debug!("now prerolling");
        self.media = Some(Media {
            pipeline: pipeline.clone(),
            pipeline_manager: PipelineManager::new(
                pipeline.clone(),
                ctx.address().downgrade().recipient(),
                &self.id,
            )
            .start(),
            src,
            switches: vec![],
            n_streams: 0,
            source_bin: None,
        });

        let addr = ctx.address();
        let id = self.id.clone();
        if let Err(err) = pipeline.set_state(gst::State::Playing) {
            addr.do_send(ErrorMessage {
                message: format!("Failed to start source {}: {}", id, err),
            });
        }

        Ok(StateChangeResult::Success)
    }

    /// Unblock a prerolling pipeline
    #[instrument(level = "debug", name = "unblocking", skip(self, ctx), fields(id = %self.id))]
    fn unblock(&mut self, ctx: &mut Context<Self>) -> Result<StateChangeResult, Error> {
        //let media = self.media.as_ref().unwrap();

        // Note: videotestsrc doesn't have an "unblock" signal, this is for fallbacksrc
        // For videotestsrc, we just forward the producer
        if let Some(ref producer) = self.video_producer {
            producer.forward();
        }

        debug!("unblocked, now playing");
        let id_clone = self.id.clone();
        self.monitor_handle = Some(ctx.run_interval(
            std::time::Duration::from_secs(1),
            move |s, _ctx| {
                if let Some(ref media) = s.media {
                    if let Some(ref source_bin) = media.source_bin {
                        let s = source_bin.property::<gst::Structure>("statistics");
                        trace!(id = %id_clone, "source statistics: {}", s.to_string());
                    }
                }
            },
        ));

        Ok(StateChangeResult::Success)
    }

    /// A new pad was added, or an existing pad EOS'd
    fn handle_stream_change(&mut self, ctx: &mut Context<Self>, starting: bool) {
        if let Some(ref mut media) = self.media {
            if starting {
                media.n_streams += 1;
                debug!(id = %self.id, n_streams = %media.n_streams, "new active stream");
            } else {
                media.n_streams -= 1;
                debug!(id = %self.id, n_streams = %media.n_streams, "active stream finished");
                if media.n_streams == 0 {
                    self.stop(ctx)
                }
            }
        }
    }

    /// Track the status of a new fallbackswitch
    #[instrument(level = "debug", name = "new-fallbackswitch", skip(self, ctx), fields(id = %self.id))]
    fn monitor_switch(&mut self, ctx: &mut Context<Self>, switch: gst::Element) {
        if let Some(ref mut media) = self.media {
            let addr_clone = ctx.address();
            switch.connect("notify::primary-health", false, move |_args| {
                addr_clone.do_send(SourceStatusMessage);
                None
            });

            let addr_clone = ctx.address();
            switch.connect("notify::fallback-health", false, move |_args| {
                addr_clone.do_send(SourceStatusMessage);
                None
            });

            media.switches.push(switch);
        }
    }

    /// Trace the status of the source for monitoring purposes
    #[instrument(level = "trace", name = "new-source-status", skip(self), fields(id = %self.id))]
    fn log_source_status(&mut self) {
        if let Some(ref media) = self.media {
            let value = media.src.property("status");
            let status = gst::glib::EnumValue::from_value(&value).expect("Not an enum type");
            trace!("Source status: {}", status.1.nick());
            trace!(
                "Source statistics: {:?}",
                media.src.property::<gst::Structure>("statistics")
            );

            for switch in &media.switches {
                let switch_name = match switch.static_pad("src").unwrap().caps() {
                    Some(caps) => match caps.structure(0) {
                        Some(s) => s.name(),
                        None => "EMPTY",
                    },
                    None => "ANY",
                };

                let value = switch.property_value("primary-health");
                let health = gst::glib::EnumValue::from_value(&value).expect("Not an enum type");
                trace!("switch {} primary health: {}", switch_name, health.1.nick());

                let value = switch.property_value("fallback-health");
                let health = gst::glib::EnumValue::from_value(&value).expect("Not an enum type");
                trace!(
                    "switch {} fallback health: {}",
                    switch_name,
                    health.1.nick()
                );
            }
        }
    }

    #[instrument(level = "debug", skip(self), fields(id = %self.id))]
    fn reinitialize(&mut self) -> Result<StateChangeResult, Error> {
        if let Some(media) = self.media.take() {
            debug!("tearing down previously prerolling pipeline");
            let _ = media.pipeline.set_state(gst::State::Null);

            if let Some(ref producer) = self.video_producer {
                media
                    .pipeline
                    .remove(producer.appsink().upcast_ref::<gst::Element>())
                    .unwrap();
            }

            media.pipeline_manager.do_send(StopManagerMessage);
        }

        Ok(StateChangeResult::Success)
    }

    #[instrument(level = "debug", skip(self, ctx), fields(id = %self.id))]
    fn stop(&mut self, ctx: &mut Context<Self>) {
        self.stop_schedule(ctx);
        ctx.stop();
    }
} // <- This was missing!

impl Actor for VideoGenerator {
    type Context = Context<Self>;

    #[instrument(level = "debug", name = "starting", skip(self, _ctx), fields(id = %self.id))]
    fn started(&mut self, _ctx: &mut Self::Context) {}

    #[instrument(level = "debug", name = "stopping", skip(self, _ctx), fields(id = %self.id))]
    fn stopped(&mut self, _ctx: &mut Self::Context) {
        if let Some(media) = self.media.take() {
            media.pipeline_manager.do_send(StopManagerMessage);
        }

        NodeManager::from_registry().do_send(StoppedMessage {
            id: self.id.clone(),
            video_producer: self.video_producer.clone(),
            audio_producer: None,
        });
    }
}

impl Schedulable<Self> for VideoGenerator {
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
            State::Initial => self
                .state_machine
                .cue_time
                .map(|cue_time| cue_time - chrono::Duration::seconds(10)),
            State::Starting => self.state_machine.cue_time,
            State::Started => self.state_machine.end_time,
            State::Stopping => None,
            State::Stopped => None,
        }
    }

    #[instrument(level = "debug", skip(self, ctx), fields(id = %self.id))]
    fn transition(
        &mut self,
        ctx: &mut Context<Self>,
        target: State,
    ) -> Result<StateChangeResult, Error> {
        match target {
            State::Initial => self.reinitialize(),
            State::Starting => self.preroll(ctx),
            State::Started => self.unblock(ctx),
            State::Stopping => Ok(StateChangeResult::Skip),
            State::Stopped => {
                self.stop(ctx);
                Ok(StateChangeResult::Success)
            }
        }
    }
}

/// Sent by the [`Source`] to notify itself that a stream started or ended
#[derive(Debug)]
struct StreamMessage {
    /// Whether the stream is starting or ending
    starting: bool,
}

impl Message for StreamMessage {
    type Result = ();
}

impl Handler<StreamMessage> for VideoGenerator {
    type Result = ();

    fn handle(&mut self, msg: StreamMessage, ctx: &mut Context<Self>) {
        self.handle_stream_change(ctx, msg.starting);
    }
}

impl Handler<StartMessage> for VideoGenerator {
    type Result = MessageResult<StartMessage>;

    fn handle(&mut self, msg: StartMessage, ctx: &mut Context<Self>) -> Self::Result {
        MessageResult(self.start_schedule(ctx, msg.cue_time, msg.end_time))
    }
}

impl Handler<GetProducerMessage> for VideoGenerator {
    type Result = MessageResult<GetProducerMessage>;

    fn handle(&mut self, _msg: GetProducerMessage, _ctx: &mut Context<Self>) -> Self::Result {
        MessageResult(Ok((self.video_producer.clone(), None)))
    }
}

impl Handler<ErrorMessage> for VideoGenerator {
    type Result = ();

    fn handle(&mut self, msg: ErrorMessage, ctx: &mut Context<Self>) -> Self::Result {
        error!("Got error message '{}' on source {}", msg.message, self.id);

        NodeManager::from_registry().do_send(NodeStatusMessage::Error {
            id: self.id.clone(),
            message: msg.message,
        });

        if let Some(media) = &self.media {
            gst::debug_bin_to_dot_file_with_ts(
                &media.pipeline,
                gst::DebugGraphDetails::all(),
                format!("error-source-{}", self.id),
            );
        }

        self.stop(ctx);
    }
}

/// Sent by the [`Source`] to notify itself that a new `fallbackswitch`
/// was added in `fallbacksrc`
#[derive(Debug)]
struct NewSwitchMessage(gst::Element);

impl Message for NewSwitchMessage {
    type Result = ();
}

impl Handler<NewSwitchMessage> for VideoGenerator {
    type Result = ();

    fn handle(&mut self, msg: NewSwitchMessage, ctx: &mut Context<Self>) -> Self::Result {
        self.monitor_switch(ctx, msg.0);
    }
}

/// Sent by the [`Source`] to notify itself that the `urisourcebin`
/// was added in `fallbacksrc`
#[derive(Debug)]
struct NewSourceBinMessage(gst::Element);

impl Message for NewSourceBinMessage {
    type Result = ();
}

impl Handler<NewSourceBinMessage> for VideoGenerator {
    type Result = ();

    fn handle(&mut self, msg: NewSourceBinMessage, _ctx: &mut Context<Self>) -> Self::Result {
        if let Some(ref mut media) = self.media {
            media.source_bin = Some(msg.0);
        }
    }
}

/// Sent by the [`Source`] to notify itself that the status of one
/// of the monitored elements changed
#[derive(Debug)]
struct SourceStatusMessage;

impl Message for SourceStatusMessage {
    type Result = ();
}

impl Handler<SourceStatusMessage> for VideoGenerator {
    type Result = ();

    fn handle(&mut self, _msg: SourceStatusMessage, _ctx: &mut Context<Self>) -> Self::Result {
        self.log_source_status();
    }
}

impl Handler<ScheduleMessage> for VideoGenerator {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: ScheduleMessage, ctx: &mut Context<Self>) -> Self::Result {
        self.reschedule(ctx, msg.cue_time, msg.end_time)
    }
}

impl Handler<StopMessage> for VideoGenerator {
    type Result = Result<(), Error>;

    fn handle(&mut self, _msg: StopMessage, ctx: &mut Context<Self>) -> Self::Result {
        self.stop(ctx);
        Ok(())
    }
}

impl Handler<GetNodeInfoMessage> for VideoGenerator {
    type Result = Result<NodeInfo, Error>;

    fn handle(&mut self, _msg: GetNodeInfoMessage, _ctx: &mut Context<Self>) -> Self::Result {
        Ok(NodeInfo::Source(SourceInfo {
            uri: "generated".to_string(), // videotestsrc doesn't have a URI
            video_consumer_slot_ids: self.video_producer.as_ref().map(|p| p.get_consumer_ids()),
            cue_time: self.state_machine.cue_time,
            end_time: self.state_machine.end_time,
            state: self.state_machine.state,
            audio_consumer_slot_ids: None,
        }))
    }
}

impl Handler<AddControlPointMessage> for VideoGenerator {
    type Result = Result<(), Error>;

    fn handle(&mut self, _msg: AddControlPointMessage, _ctx: &mut Context<Self>) -> Self::Result {
        Err(anyhow!("VideoGenerator has no property to control"))
    }
}

impl Handler<RemoveControlPointMessage> for VideoGenerator {
    type Result = ();

    fn handle(
        &mut self,
        _msg: RemoveControlPointMessage,
        _ctx: &mut Context<Self>,
    ) {
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::shared::get_now;
    use crate::shared::tests::*;
    use std::collections::VecDeque;
    use test_log::test;

    #[actix_rt::test]
    #[test]
    async fn test_status_after_create() {
        gst::init().unwrap();

        // Create a valid video generator
        create_video_generator("test-generator").await.unwrap();

        let info = node_info_unchecked("test-generator").await;

        if let NodeInfo::Source(sinfo) = info {
            assert_eq!(sinfo.uri, "generated");
            assert!(sinfo.video_consumer_slot_ids.unwrap().is_empty());
            assert!(sinfo.cue_time.is_none());
            assert!(sinfo.end_time.is_none());
            assert_eq!(sinfo.state, State::Initial);
        } else {
            panic!("Wrong info type");
        }
    }

    #[actix_rt::test]
    #[test]
    async fn test_start_immediate() {
        gst::init().unwrap();

        // Expect state to progress to Started with no hiccup
        let listener_addr = register_listener(
            "test-generator",
            "test-listener",
            VecDeque::from(vec![State::Starting, State::Started]),
        )
        .await;

        // Create a valid video generator
        create_video_generator("test-generator").await.unwrap();

        // Start it up immediately
        start_node("test-generator", None, None).await.unwrap();

        let progression_result = listener_addr.send(WaitForProgressionMessage).await.unwrap();

        assert!(progression_result.progressed_as_expected);
    }
}
