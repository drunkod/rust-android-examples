use actix::prelude::*;
use anyhow::Error;
use chrono::{DateTime, Utc};
use auteur_controlling::controller::{Command, CommandResult, ControlPoint, NodeInfo};
use crate::shared::stream_producer::StreamProducer;

// Move all message types here
#[derive(Debug)]
pub struct StartMessage {
    pub cue_time: Option<DateTime<Utc>>,
    pub end_time: Option<DateTime<Utc>>,
}

impl Message for StartMessage {
    type Result = Result<(), Error>;
}

#[derive(Debug)]
pub struct StopMessage;

impl Message for StopMessage {
    type Result = Result<(), Error>;
}

#[derive(Debug)]
pub struct GetProducerMessage;

impl Message for GetProducerMessage {
    type Result = Result<(Option<StreamProducer>, Option<StreamProducer>), Error>;
}

#[derive(Debug)]
pub struct ScheduleMessage {
    pub cue_time: Option<DateTime<Utc>>,
    pub end_time: Option<DateTime<Utc>>,
}

impl Message for ScheduleMessage {
    type Result = Result<(), Error>;
}

#[derive(Debug)]
pub struct AddControlPointMessage {
    pub property: String,
    pub control_point: ControlPoint,
}

impl Message for AddControlPointMessage {
    type Result = Result<(), Error>;
}

#[derive(Debug)]
pub struct RemoveControlPointMessage {
    pub controller_id: String,
    pub property: String,
}

impl Message for RemoveControlPointMessage {
    type Result = ();
}

#[derive(Debug)]
pub struct GetNodeInfoMessage;

impl Message for GetNodeInfoMessage {
    type Result = Result<NodeInfo, Error>;
}

#[derive(Debug)]
pub struct StoppedMessage {
    pub id: String,
    pub video_producer: Option<StreamProducer>,
    pub audio_producer: Option<StreamProducer>,
}

impl Message for StoppedMessage {
    type Result = ();
}

#[derive(Debug, Clone)]
pub enum NodeStatusMessage {
    State { id: String, state: auteur_controlling::controller::State },
    Error { id: String, message: String },
}

impl Message for NodeStatusMessage {
    type Result = ();
}

pub enum ConsumerMessage {
    Connect {
        link_id: String,
        video_producer: Option<StreamProducer>,
        audio_producer: Option<StreamProducer>,
        config: Option<std::collections::HashMap<String, serde_json::Value>>,
    },
    Disconnect {
        slot_id: String,
    },
    AddControlPoint {
        slot_id: String,
        property: String,
        control_point: ControlPoint,
    },
    RemoveControlPoint {
        controller_id: String,
        slot_id: String,
        property: String,
    },
}

impl Message for ConsumerMessage {
    type Result = Result<(), Error>;
}

#[derive(Debug)]
pub struct CommandMessage {
    pub command: Command,
}

impl Message for CommandMessage {
    type Result = CommandResult;
}

#[derive(Debug)]
pub struct RegisterListenerMessage {
    pub id: String,
    pub recipient: Recipient<NodeStatusMessage>,
}

impl Message for RegisterListenerMessage {
    type Result = Result<(), Error>;
}
