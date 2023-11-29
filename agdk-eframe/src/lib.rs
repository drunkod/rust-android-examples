mod gateway;
mod nodes;
mod utils;
// mod common;

use anyhow::{anyhow, Error};
use structopt::StructOpt;

use crate::gateway::config::Config;

// use tracing_subscriber::prelude::*;

use std::fs;


use std::{env, process};
use gst::prelude::*;
use log::{debug};
//add RUSTFLAGS="-lffi" with error dlopen failed: cannot locate symbol "ffi_type_void" referenced by

use std::os::raw::c_char;
use std::ffi::CString;



use eframe::egui;

use eframe::{NativeOptions, Renderer};

use std::sync::{Arc, atomic::{AtomicBool, Ordering}};
use std::thread;


use std::fmt::Write;

#[cfg(target_os = "android")]
use egui_winit::winit::platform::android::activity::AndroidApp;

// #[derive(Debug)]
// pub struct Config {
//     pub server_address: String,
//     pub log_path: Option<String>,
//     // Add other configuration fields as needed
// }

impl Config {
    // Function to create a default configuration
    pub fn new() -> Self {
        Config {
            port: 8080,
            use_tls: false,
            log_path: None,
            certificate_file: None,
            key_file: None,    
            // By default, no log file path is specified
            // Initialize other fields with default values
        }
    }

    // Function to create a configuration from command-line arguments or other sources
    pub fn from_args() -> Self {
        // Normally, you would parse command-line arguments or read from a file/environment
        // For demonstration purposes, we'll just return the default configuration
        Self::new()
    }
}


#[derive(Default)]
struct MyApp {
    name: String,
    label: String,
    age: u32,
    value: u32,
    version: String,
    server_running: Arc<AtomicBool>,
    config: Config, // Add the Config field to your struct
    log: String,
}

impl MyApp {
    // Initialize MyApp with a default Config
    pub fn new() -> Self {
        MyApp {
            name: String::new(),
            label: String::new(),
            age: 0,
            value: 0,
            version: String::new(),
            server_running: Arc::new(AtomicBool::new(false)),
            config: Config::new(), // Initialize Config here
            log: String::new(),
        }
    }
}

// #[no_mangle]
// pub extern fn rust_greeting() {
//     // Get a string containing the passed pipeline launch syntax audiotestsrc wave=saw freq=205 ! autoaudiosink
//     let pipeline_str = "audiotestsrc wave=saw freq=205 ! autoaudiosink";
    
//     // gst::init().unwrap();
//     let gst_version_string = gst::version_string();
    
//     // Let GStreamer create a pipeline from the parsed launch syntax on the cli.
//     // In comparison to the launch_glib_main example, this is using the advanced launch syntax
//     // parsing API of GStreamer. The function returns a Result, handing us the pipeline if
//     // parsing and creating succeeded, and hands us detailed error information if something
//     // went wrong. The error is passed as gst::ParseError. In this example, we separately
//     // handle the NoSuchElement error, that GStreamer uses to notify us about elements
//     // used within the launch syntax, that are not available (not installed).
//     // Especially GUIs should probably handle this case, to tell users that they need to
//     // install the corresponding gstreamer plugins.

//     let mut context = gst::ParseContext::new();
//     let pipeline =
//         match gst::parse_launch_full(&pipeline_str, Some(&mut context), gst::ParseFlags::empty()) {
//             Ok(pipeline) => pipeline,
//             Err(err) => {
//                 if let Some(gst::ParseError::NoSuchElement) = err.kind::<gst::ParseError>() {
//                     println!("Missing element(s): {:?}", context.missing_elements());
//                 } else {
//                     println!("Failed to parse pipeline: {err}")
//                 }

//                 return
//             }
//         };
//     let bus = pipeline.bus().unwrap();

//     pipeline
//         .set_state(gst::State::Playing)
//         .expect("Unable to set the pipeline to the `Playing` state");

//     for msg in bus.iter_timed(gst::ClockTime::NONE) {
//         use gst::MessageView;

//         match msg.view() {
//             MessageView::Eos(..) => break,
//             MessageView::Error(err) => {
//                 println!(
//                     "Error from {:?}: {} ({:?})",
//                     err.src().map(|s| s.path_string()),
//                     err.error(),
//                     err.debug()
//                 );
//                 break;
//             }
//             _ => (),
//         }
//     }

//     pipeline
//         .set_state(gst::State::Null)
//         .expect("Unable to set the pipeline to the `Null` state");

//     debug!("Using {} as player", gst::version_string());
    
//     // let gst_version_string = gst::version_string();
//     // CString::new(gst::version_string().to_owned()).unwrap().into_raw()
// }

/// Application entry point
fn start_server(cfg: Config) -> Result<(), Error> {
    let cfg = Config::from_args();
    // It initializes a logger with tracing_log::LogTracer::init(). 
    // The logging level is set by the "AUTEUR_LOG" environment variable or 
    // defaults to "warn" if the variable is not set.
    // tracing_log::LogTracer::init().expect("Failed to set logger");
    // let env_filter = tracing_subscriber::EnvFilter::try_from_env("AUTEUR_LOG")
    //     .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("warn"));
    // // The log output is directed either to a file or the console, 
    // // depending on whether a log path is specified in the configuration.
    // let (writer, _guard) = {
    //     if let Some(ref path) = cfg.log_path {
    //         let path = fs::canonicalize(&path)
    //             .map_err(|err| anyhow!("Invalid log path: {}", err.to_string()))?;

    //         if !path.is_dir() {
    //             return Err(anyhow!("Log path is not a directory: {:?}", path));
    //         }

    //         let file_appender = tracing_appender::rolling::never(&path, "auteur.log");
    //         let (writer, guard) = tracing_appender::non_blocking(file_appender);

    //         (writer, guard)
    //     } else {
    //         let (writer, guard) = tracing_appender::non_blocking(std::io::stdout());

    //         (writer, guard)
    //     }
    // };
    // // A log format layer is created with tracing_subscriber::fmt::layer(). 
    // // This includes thread IDs, targets, and span events.
    // let fmt_layer = tracing_subscriber::fmt::layer()
    //     .with_thread_ids(true)
    //     .with_target(true)
    //     .with_span_events(
    //         tracing_subscriber::fmt::format::FmtSpan::NEW
    //             | tracing_subscriber::fmt::format::FmtSpan::CLOSE,
    //     )
    //     .with_writer(writer);
    // // A global subscriber is set up with the environment filter and format layer.
    // //  This is where the logs will be sent.
    // let subscriber = tracing_subscriber::Registry::default()
    //     .with(env_filter)
    //     .with(fmt_layer);
    // tracing::subscriber::set_global_default(subscriber).expect("Failed to set subscriber");

    gst::init().unwrap();
    // An Actix runtime system is created and used to run the server function
    //  which is defined in the gateway::server module
    let system: actix::prelude::SystemRunner = actix_rt::System::new();
    system.block_on(gateway::server::run(cfg))?;

    Ok(())
}

impl eframe::App for MyApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
     egui::TopBottomPanel::top("top_panel").show(ctx, |ui| {
            // The top panel is often a good place for a menu bar:
            egui::menu::bar(ui, |ui| {
                ui.menu_button("File", |ui| {
                    if ui.button("Quit").clicked() {
                        _frame.close();
                    }
                });
            });
        });

        egui::SidePanel::left("side_panel").show(ctx, |ui| {
            ui.heading("Side Panel");

            ui.horizontal(|ui| {
                ui.label("Write something: ");

            });

            ui.heading("My egui Application");
            ui.horizontal(|ui| {
                let name_label = ui.label("Your name: ");
                ui.text_edit_singleline(&mut self.name)
                    .labelled_by(name_label.id);
            });
            ui.add(egui::Slider::new(&mut self.age, 0..=120).text("age"));
                    let button = ui.button("Click me please");
                    if button.clicked() {
                        // Call a function when the button is clicked
                        self.age += 1;
                        self.version = "version".to_string();
                        // rust_greeting();
                    }
                    if ui.button("Start Server").clicked() {
                        // Check if the server is already running
                        if self.server_running.load(std::sync::atomic::Ordering::SeqCst) {
                            // Server is already running, perhaps show a message
                            log::info!("Server is already running!");
                            self.log = "Server is already running!".to_string();
                            println!("Server is already running! println 260");
                        } else {
                            // Mark the server as running
                            self.server_running.store(true, std::sync::atomic::Ordering::SeqCst);
                            let server_running_clone = self.server_running.clone();
                            let mut log_clone = self.log.clone();
                            // Spawn a new thread to run the server
                            thread::spawn(move || {
                                let cfg = Config::from_args(); // Assuming you have a way to create a Config
                                match start_server(cfg) {
                                    Ok(()) => {
                                        log::info!("Server started successfully");
                                        println!("Server started successfully");
                                    log_clone = "Server started successfully".to_string();
                                },
                                    Err(err) => {
                                        println!("Server failed to start: {:?}", err);
                                        log::error!("Server failed to start: {}", err); // Log the error
                                        
                                        // Mark the server as not running if it fails to start
                                        server_running_clone.store(false, std::sync::atomic::Ordering::SeqCst);
                                    }
                                }
                            });
                        }
                    }            
            ui.label(format!("Name '{}', Age {}, version '{}'", self.name, self.age, self.version));
            ui.heading("Loging:");
            ui.label(format!("Server_running '{}', Log '{}', Log clone '{}'", self.server_running.load(Ordering::Relaxed), self.log, self.log));
                      // fn do_something() {
                          // Initialize GStreamer
                       //  gst::init().unwrap();

                        // Do something when the button is clicked.
                        //   println!("The button was clicked!");
                       //  }



            ui.with_layout(egui::Layout::bottom_up(egui::Align::LEFT), |ui| {
                ui.horizontal(|ui| {
                    ui.spacing_mut().item_spacing.x = 0.0;
                    ui.label("powered by ");
                    ui.hyperlink_to("egui", "https://github.com/emilk/egui");
                    ui.label(" and ");
                    ui.hyperlink_to(
                        "eframe",
                        "https://github.com/emilk/egui/tree/master/crates/eframe",
                    );
                    ui.label(".");
                });
            });
        });

        egui::CentralPanel::default().show(ctx, |ui| {

        });
    }
}


fn _main(mut options: NativeOptions) -> eframe::Result<()> {
    options.renderer = Renderer::Wgpu;
    eframe::run_native(
        "My egui App",
        options,
        Box::new(|_cc| Box::<MyApp>::default()),
    )
}

#[cfg(target_os = "android")]
#[no_mangle]
fn android_main(app: AndroidApp) {
    use log::Level;
    
    use egui_winit::winit::platform::android::EventLoopBuilderExtAndroid;

    android_logger::init_once(
        android_logger::Config::default().with_max_level(log::LevelFilter::Debug),
    );

    let options = NativeOptions {
        event_loop_builder: Some(Box::new(move |builder| {
            builder.with_android_app(app);

            // EventLoopBuilderExtAndroid::with_android_app(builder, app);
        })),
        ..Default::default()
    };

    _main(options).unwrap_or_else(|err| {
        log::error!("Failure while running EFrame application: {err:?}");
    });
}

#[cfg(not(target_os = "android"))]
fn main() {
    env_logger::builder()
        .filter_level(log::LevelFilter::Warn) // Default Log Level
        .parse_default_env()
        .init();

    _main(NativeOptions::default());
}