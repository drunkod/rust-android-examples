//! Узел обработки источника.//!
//! Единственный поддерживаемый тип источника создается с помощью URI. В будущем
//! Генераторы также могут поддерживаться, например, для отображения обратного отсчета.
//!
//! Основной сложностью для этого узла является [`starting`](State::Starting)
//! Особенность: когда узел должен играть в будущем, мы его раскручиваем
//! встать за 10 секунд до начала. Неживые источники блокируются
//! by fallbacksrc, который выбирает базовое время только после разблокировки,
//! и данные, поступающие из живых источников, отбрасываются StreamProducers
//! пока для них не будет вызвана функция forward().
//!
//! Часть дополнительной сложности связана с функцией изменения расписания:
//! При перепланировании источника прероллинга мы хотим снести
//! предыдущий конвейер, но поскольку логические соединения отслеживаются
//! элементы StreamProducer, мы хотим сохранить их жизненный цикл привязанным к
//! что и в источнике. Это означает, что ссылки на приложения могут быть удалены из старых
//! трубопровод и переместился на новый, он безопасен, но его нужно сохранить
//! в памяти.

use super::node::{
    AddControlPointMessage, GetNodeInfoMessage, GetProducerMessage, NodeManager, NodeStatusMessage,
    RemoveControlPointMessage, ScheduleMessage, StartMessage, StopMessage, StoppedMessage,
};
use crate::utils::{
    make_element, ErrorMessage, PipelineManager, Schedulable, StateChangeResult, StateMachine,
    StopManagerMessage, StreamProducer,
};
use actix::prelude::*;
use anyhow::{anyhow, Error};
use auteur_controlling::controller::{NodeInfo, SourceInfo, State};
use chrono::{DateTime, Utc};
use gst::prelude::*;
use tracing::{debug, error, instrument, trace};

/// Конвейер и различные элементы GStreamer, которые источник
/// по желанию обертывает, их время жизни не привязано напрямую к этому
/// самого источника
#[derive(Debug)]
struct Media {
    /// Обернутый трубопровод
    /// The wrapped pipeline
    pipeline: gst::Pipeline,
    /// A helper for managing the pipeline
    pipeline_manager: Addr<PipelineManager>,
    /// `fallbacksrc`
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
#[derive(Debug)]
pub struct Source {
    /// Unique identifier
    id: String,
    /// URI the source will play
    uri: String,
    /// Output audio producer
    audio_producer: Option<StreamProducer>,
    /// Output video producer
    video_producer: Option<StreamProducer>,
    /// GStreamer elements when prerolling or playing
    media: Option<Media>,
    /// Statistics timer
    monitor_handle: Option<SpawnHandle>,
    /// Our state machine
    state_machine: StateMachine,
}

impl Source {
     // Constructor to create a new source.
    /// Create a source
    #[instrument(level = "debug", name = "creating")]
    pub fn new(id: &str, uri: &str, audio: bool, video: bool) -> Self {
        // Initialize audio and video producers based on configuration.
        // Other properties are set to default values.        
        let audio_producer = if audio {
            Some(StreamProducer::from(
                &gst::ElementFactory::make("appsink")
                    .name(&format!("src-audio-appsink-{}", id))
                    .build()
                    .unwrap()
                    .downcast::<gst_app::AppSink>()
                    .unwrap(),
            ))
        } else {
            None
        };

        let video_producer = if video {
            Some(StreamProducer::from(
                &gst::ElementFactory::make("appsink")
                    .name(&format!("src-video-appsink-{}", id))
                    .build()
                    .unwrap()
                    .downcast::<gst_app::AppSink>()
                    .unwrap(),
            ))
        } else {
            None
        };

        Self {
            id: id.to_string(),
            uri: uri.to_string(),
            audio_producer,
            video_producer,
            media: None,
            monitor_handle: None,
            state_machine: StateMachine::default(),
        }
    }
    // Method to connect pads exposed by `fallbacksrc` to output producer
    /// Подключите колодки, открытые `fallbacksrc`, к нашим производителям вывода
    #[instrument(level = "debug", name = "connecting", skip(pipeline, is_video, pad, video_producer, audio_producer), fields(pad = %pad.name()))]
    fn connect_pad(
        id: String,
        is_video: bool,
        pipeline: &gst::Pipeline,
        pad: &gst::Pad,
        video_producer: &Option<StreamProducer>,
        audio_producer: &Option<StreamProducer>,
    ) -> Result<Option<gst::Element>, Error> {
        // Handle pad connections based on audio or video type.
        // Управление подключениями пэдов в зависимомти от типа аудио или видео
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
        } else if let Some(audio_producer) = audio_producer {
            let aconv = make_element("audioconvert", None)?;
            let level = make_element("level", None)?;

            pipeline.add_many(&[&aconv, &level])?;

            let appsink = audio_producer.appsink();

            debug!(appsink = %appsink.name(), "linking audio stream to appsink");

            aconv.sync_state_with_parent()?;
            level.sync_state_with_parent()?;

            gst::Element::link_many(&[&aconv, &level, appsink.upcast_ref()])?;

            let sinkpad = aconv.static_pad("sink").unwrap();
            pad.link(&sinkpad)?;

            Ok(Some(appsink.upcast()))
        } else {
            Ok(None)
        }
    }

    /// Прокрутите pipeline трубопровод заранее (по умолчанию за 10 секунд до начала сигнала).
    #[instrument(level = "debug", name = "prerolling", skip(self, ctx), fields(id = %self.id))]
    fn preroll(&mut self, ctx: &mut Context<Self>) -> Result<StateChangeResult, Error> {
        // let pipeline = gst::Pipeline::new(Some(&self.id.to_string()));
        let pipeline = gst::Pipeline::with_name(&self.id.to_string());
        if let Some(ref audio_producer) = self.audio_producer {
            pipeline.add(audio_producer.appsink().upcast_ref::<gst::Element>())?;
        }

        if let Some(ref video_producer) = self.video_producer {
            pipeline.add(video_producer.appsink().upcast_ref::<gst::Element>())?;
        }

        let src = make_element("fallbacksrc", None)?;
        pipeline.add(&src)?;

        src.set_property("uri", &self.uri);
        src.set_property("manual-unblock", &true);
        src.set_property("immediate-fallback", &true);
        src.set_property("enable-audio", &self.audio_producer.is_some());
        src.set_property("enable-video", &self.video_producer.is_some());

        let pipeline_clone = pipeline.downgrade();
        let addr = ctx.address();

        let video_producer = self.video_producer.clone();
        let audio_producer = self.audio_producer.clone();
        let id = self.id.clone();
        src.connect_pad_added(move |_src, pad| {
            if let Some(pipeline) = pipeline_clone.upgrade() {
                let is_video = pad.name() == "video";
                match Source::connect_pad(
                    id.clone(),
                    is_video,
                    &pipeline,
                    pad,
                    &video_producer,
                    &audio_producer,
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
                    Err(err) => addr.do_send(ErrorMessage(format!(
                        "Failed to connect source stream: {:?}",
                        err
                    ))),
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

        let src_bin: &gst::Bin = src.downcast_ref().unwrap();

        let addr = ctx.address();
        src_bin.connect_deep_element_added(move |_src, _bin, element| {
            if element.has_property("primary-health", None) {
                addr.do_send(NewSwitchMessage(element.clone()));
            }

            if element.type_().name() == "GstURISourceBin" {
                addr.do_send(NewSourceBinMessage(element.clone()));
            }
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
            addr.do_send(ErrorMessage(format!(
                "Failed to start source {}: {}",
                id, err
            )));
        }

        Ok(StateChangeResult::Success)
    }

    /// Разблокируйте трубопровод прероллинга
    #[instrument(level = "debug", name = "unblocking", skip(self), fields(id = %self.id))]
    fn unblock(&mut self, ctx: &mut Context<Self>) -> Result<StateChangeResult, Error> {
        let media = self.media.as_ref().unwrap();

        media.src.emit_by_name::<()>("unblock", &[]);

        if let Some(ref producer) = self.video_producer {
            producer.forward();
        }

        if let Some(ref producer) = self.audio_producer {
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

            if let Some(ref producer) = self.audio_producer {
                media
                    .pipeline
                    .remove(producer.appsink().upcast_ref::<gst::Element>())
                    .unwrap();
            }

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
}

impl Actor for Source {
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
            audio_producer: self.audio_producer.clone(),
        });
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
    /// Начинается или заканчивается поток
    starting: bool,
}

impl Message for StreamMessage {
    type Result = ();
}

impl Handler<StreamMessage> for Source {
    type Result = ();

    fn handle(&mut self, msg: StreamMessage, ctx: &mut Context<Self>) {
        self.handle_stream_change(ctx, msg.starting);
    }
}

impl Handler<StartMessage> for Source {
    type Result = MessageResult<StartMessage>;

    fn handle(&mut self, msg: StartMessage, ctx: &mut Context<Self>) -> Self::Result {
        MessageResult(self.start_schedule(ctx, msg.cue_time, msg.end_time))
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

impl Handler<ErrorMessage> for Source {
    type Result = ();

    fn handle(&mut self, msg: ErrorMessage, ctx: &mut Context<Self>) -> Self::Result {
        error!("Got error message '{}' on source {}", msg.0, self.id,);

        NodeManager::from_registry().do_send(NodeStatusMessage::Error {
            id: self.id.clone(),
            message: msg.0,
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

/// Отправляется [Источником], чтобы уведомить себя о том, что новый `fallbackswitch`
/// was added in `fallbacksrc`
#[derive(Debug)]
struct NewSwitchMessage(gst::Element);

impl Message for NewSwitchMessage {
    type Result = ();
}

impl Handler<NewSwitchMessage> for Source {
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

impl Handler<NewSourceBinMessage> for Source {
    type Result = ();

    fn handle(&mut self, msg: NewSourceBinMessage, _ctx: &mut Context<Self>) -> Self::Result {
        if let Some(ref mut media) = self.media {
            media.source_bin = Some(msg.0);
        }
    }
}

/// Отправляется [`Источником`], чтобы уведомить себя о том, что статус одного
/// of the monitored elements changed
#[derive(Debug)]
struct SourceStatusMessage;

impl Message for SourceStatusMessage {
    type Result = ();
}

impl Handler<SourceStatusMessage> for Source {
    type Result = ();

    fn handle(&mut self, _msg: SourceStatusMessage, _ctx: &mut Context<Self>) -> Self::Result {
        self.log_source_status();
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
            video_consumer_slot_ids: self.video_producer.as_ref().map(|p| p.get_consumer_ids()),
            audio_consumer_slot_ids: self.audio_producer.as_ref().map(|p| p.get_consumer_ids()),
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
    ) -> Self::Result {
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::utils::get_now;
    use crate::utils::tests::*;
    use std::collections::VecDeque;
    use test_log::test;

    #[actix_rt::test]
    #[test]
    async fn test_status_after_create() {
        gst::init().unwrap();
        let uri = asset_uri("ball.mp4");

        // Create a valid source
        create_source("test-source", &uri, true, true)
            .await
            .unwrap();

        let info = node_info_unchecked("test-source").await;

        if let NodeInfo::Source(sinfo) = info {
            assert_eq!(sinfo.uri, uri);
            assert!(sinfo.video_consumer_slot_ids.unwrap().is_empty());
            assert!(sinfo.audio_consumer_slot_ids.unwrap().is_empty());
            assert!(sinfo.cue_time.is_none());
            assert!(sinfo.end_time.is_none());
            assert_eq!(sinfo.state, State::Initial);
        } else {
            panic!("Wrong info type");
        }
    }

    #[actix_rt::test]
    #[test]
    async fn test_disable_video() {
        gst::init().unwrap();
        let uri = asset_uri("ball.mp4");

        // Create a valid source
        create_source("test-source", &uri, false, true)
            .await
            .unwrap();

        let info = node_info_unchecked("test-source").await;

        if let NodeInfo::Source(sinfo) = info {
            assert_eq!(sinfo.uri, uri);
            assert!(sinfo.video_consumer_slot_ids.is_none());
            assert!(sinfo.audio_consumer_slot_ids.unwrap().is_empty());
            assert!(sinfo.cue_time.is_none());
            assert!(sinfo.end_time.is_none());
            assert_eq!(sinfo.state, State::Initial);
        } else {
            panic!("Wrong info type");
        }
    }

    #[actix_rt::test]
    #[test]
    #[should_panic(expected = "must have either audio or video enabled")]
    async fn test_disable_video_audio() {
        gst::init().unwrap();
        let uri = asset_uri("ball.mp4");

        // Create a valid source
        create_source("test-source", &uri, false, false)
            .await
            .unwrap();
    }

    #[actix_rt::test]
    #[test]
    async fn test_start_immediate() {
        gst::init().unwrap();
        let uri = asset_uri("ball.mp4");

        // Expect state to progress to Started with no hiccup
        let listener_addr = register_listener(
            "test-source",
            "test-listener",
            VecDeque::from(vec![State::Starting, State::Started]),
        )
        .await;

        // Create a valid source
        create_source("test-source", &uri, true, true)
            .await
            .unwrap();

        // Start it up immediately
        start_node("test-source", None, None).await.unwrap();

        let progression_result = listener_addr.send(WaitForProgressionMessage).await.unwrap();

        assert!(progression_result.progressed_as_expected);
    }

    #[actix_rt::test]
    #[test]
    async fn test_reschedule() {
        gst::init().unwrap();

        let uri = asset_uri("ball.mp4");

        // Expect state to progress to Started with no hiccup
        let listener_addr = register_listener(
            "test-source",
            "test-listener",
            VecDeque::from(vec![
                State::Starting,
                State::Initial,
                State::Starting,
                State::Started,
            ]),
        )
        .await;

        // Create a valid source
        create_source("test-source", &uri, true, true)
            .await
            .unwrap();

        // "Pause" time, which will cause it to progress immediately on Sleep (eg actix' run_later)
        tokio::time::pause();

        let fut = tokio::time::sleep(std::time::Duration::from_secs(10));

        let cue_time = get_now() + chrono::Duration::seconds(15);

        tracing::info!("Scheduling for {:?}", cue_time);

        // Schedule the source to start later
        start_node("test-source", Some(cue_time), None)
            .await
            .unwrap();

        // Wait for the node to have prerolled but not started
        fut.await;

        let info = node_info_unchecked("test-source").await;

        if let NodeInfo::Source(sinfo) = info {
            assert_eq!(sinfo.state, State::Starting);
        } else {
            panic!("Wrong info type");
        }

        let cue_time = get_now() + chrono::Duration::seconds(25);

        // Reschedule, node state should reset to Initial
        reschedule_node("test-source", Some(cue_time), None)
            .await
            .unwrap();

        let progression_result = listener_addr.send(WaitForProgressionMessage).await.unwrap();

        assert!(progression_result.progressed_as_expected);
    }
}
