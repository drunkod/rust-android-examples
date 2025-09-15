#![cfg_attr(target_os = "android", no_main)]

use anyhow::Error;
use eframe::{NativeOptions, Renderer};
use std::env;

pub mod application;
pub mod domain;
pub mod infrastructure;
pub mod presentation;
pub mod shared;
// Note: fallbackswitch should be moved to infrastructure
pub mod fallbackswitch;

use crate::shared::config::Config;

pub fn start_server(cfg: Config) -> Result<(), Error> {
    gst::init()?;
    let system = actix_rt::System::new();
    system.block_on(presentation::api::server::run(cfg))?;
    Ok(())
}

pub fn _main(mut options: NativeOptions) -> eframe::Result<()> {
    options.renderer = Renderer::Wgpu;
    eframe::run_native(
        "My egui App",
        options,
        Box::new(|_cc| Box::<presentation::gui::MyApp>::default()),
    )
}


// Android entry point
#[cfg(target_os = "android")]
pub use infrastructure::android::android_main;