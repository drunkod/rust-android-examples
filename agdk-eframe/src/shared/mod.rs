pub mod config;
pub mod pipeline_manager;
pub mod property_controller;
pub mod schedulable;
pub mod setting_controller;
pub mod stream_producer;
#[cfg(test)]
pub mod tests;

pub use self::pipeline_manager::PipelineManager;
pub use self::stream_producer::StreamProducer;

use actix::prelude::*;
use anyhow::{anyhow, Error};
use chrono::{DateTime, Utc};
use gst::prelude::*;

// Common error message type
#[derive(Debug)]
pub struct ErrorMessage {
    pub message: String,
}

impl Message for ErrorMessage {
    type Result = ();
}

// Utility functions
pub fn make_element(element: &str, name: Option<&str>) -> Result<gst::Element, Error> {
    gst::ElementFactory::make(element)
        .name(name.unwrap_or(element))
        .build()
        .map_err(|err| {
            anyhow!(
                "Failed to create element {}: {}",
                element,
                err.message.unwrap_or_default()
            )
        })
}

pub fn get_now() -> DateTime<Utc> {
    Utc::now()
}
