use chrono::{DateTime, Utc};
use anyhow::Error;

pub trait Schedulable {
    fn schedule(&mut self, time: DateTime<Utc>) -> Result<(), Error>;
}

// TODO: Add StateMachine and related types
