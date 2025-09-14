use gst::prelude::*;
use anyhow::{anyhow, Error};
use actix::prelude::*;
pub mod application;
pub mod domain;
pub mod infrastructure;
pub mod presentation;
pub mod shared;

use eframe::{NativeOptions, Renderer};
use std::env;
use crate::shared::config::Config;
use anyhow::{Error as Errors};

/// Application entry point
fn start_server(cfg: Config) -> Result<(), Errors> {
    let cfg = Config::default();
    
    gst::init()?;
    // An Actix runtime system is created and used to run the server function
    //  which is defined in the gateway::server module
    let system: actix::prelude::SystemRunner = actix_rt::System::new();
    system.block_on(presentation::api::server::run(cfg))?;

    Ok(())
}

fn _main(mut options: NativeOptions) -> eframe::Result<()> {
    options.renderer = Renderer::Wgpu;
    eframe::run_native(
        "My egui App",
        options,
        Box::new(|_cc| Box::<presentation::gui::MyApp>::default()),
    )
}

#[cfg(not(target_os = "android"))]
fn main() {
    env_logger::builder()
        .filter_level(log::LevelFilter::Warn) // Default Log Level
        .parse_default_env()
        .init();

    _main(NativeOptions::default());
}