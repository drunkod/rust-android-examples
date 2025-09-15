use eframe::egui;
use eframe::{NativeOptions, Renderer};
use std::sync::{Arc, atomic::{AtomicBool, Ordering}};
use std::thread;
use crate::shared::config::Config;

#[derive(Default)]
pub struct MyApp {
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
            config: Config::default(), // Initialize Config here
            log: String::new(),
        }
    }
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
                                let cfg = crate::shared::config::Config::default(); // Assuming you have a way to create a Config
                                match crate::start_server(cfg) {
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
