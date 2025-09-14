use chrono::{DateTime, Utc};
use gst::prelude::*;
use anyhow::{anyhow, Error};
use actix::prelude::*;
pub mod config;
pub mod pipeline_manager;
pub mod property_controller;
pub mod schedulable;
pub mod setting_controller;
pub mod stream_producer;
pub mod tests;

use actix::prelude::*;
use anyhow::{anyhow, Error};
use chrono::{DateTime, Utc};
use gst::prelude::*;

#[derive(Debug)]
pub struct ErrorMessage {
    pub message: String,
}

impl Message for ErrorMessage {
    type Result = ();
}

pub fn make_element(element: &str, name: Option<&str>) -> Result<gst::Element, Error> {
    let mut elementgst = gst::ElementFactory::make(element)
        .name(element)
        .build()
        .map_err(|err| {
            anyhow!(
                "Failed to create element {}: {}",
                element,
                err.message().unwrap()
            )
        })?;

    if let Some(name) = name {
        elementgst.set_property("name", name);
    }

    Ok(elementgst)
}

pub fn get_now() -> DateTime<Utc> {
    Utc::now()
}
