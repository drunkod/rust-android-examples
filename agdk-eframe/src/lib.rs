use std::{env, process};
use gst::{prelude::*};
use log::{debug};
//add RUSTFLAGS="-lffi" with error dlopen failed: cannot locate symbol "ffi_type_void" referenced by

use std::os::raw::c_char;
use std::ffi::CString;



use eframe::egui;

use eframe::{NativeOptions, Renderer};


#[cfg(target_os = "android")]
use egui_winit::winit::platform::android::activity::AndroidApp;

#[derive(Default)]
struct MyApp {
    name: String,
    label: String,
    age: u32,
    value: u32,
    version: String,
}


#[no_mangle]
pub extern fn rust_greeting() {
    // Get a string containing the passed pipeline launch syntax audiotestsrc wave=saw freq=205 ! autoaudiosink
    let pipeline_str = "audiotestsrc wave=saw freq=205 ! autoaudiosink";
    
    gst::init().unwrap();
    let gst_version_string = gst::version_string();
    
    // Let GStreamer create a pipeline from the parsed launch syntax on the cli.
    // In comparison to the launch_glib_main example, this is using the advanced launch syntax
    // parsing API of GStreamer. The function returns a Result, handing us the pipeline if
    // parsing and creating succeeded, and hands us detailed error information if something
    // went wrong. The error is passed as gst::ParseError. In this example, we separately
    // handle the NoSuchElement error, that GStreamer uses to notify us about elements
    // used within the launch syntax, that are not available (not installed).
    // Especially GUIs should probably handle this case, to tell users that they need to
    // install the corresponding gstreamer plugins.

    let mut context = gst::ParseContext::new();
    let pipeline =
        match gst::parse_launch_full(&pipeline_str, Some(&mut context), gst::ParseFlags::empty()) {
            Ok(pipeline) => pipeline,
            Err(err) => {
                if let Some(gst::ParseError::NoSuchElement) = err.kind::<gst::ParseError>() {
                    println!("Missing element(s): {:?}", context.missing_elements());
                } else {
                    println!("Failed to parse pipeline: {err}")
                }

                return
            }
        };
    let bus = pipeline.bus().unwrap();

    pipeline
        .set_state(gst::State::Playing)
        .expect("Unable to set the pipeline to the `Playing` state");

    for msg in bus.iter_timed(gst::ClockTime::NONE) {
        use gst::MessageView;

        match msg.view() {
            MessageView::Eos(..) => break,
            MessageView::Error(err) => {
                println!(
                    "Error from {:?}: {} ({:?})",
                    err.src().map(|s| s.path_string()),
                    err.error(),
                    err.debug()
                );
                break;
            }
            _ => (),
        }
    }

    pipeline
        .set_state(gst::State::Null)
        .expect("Unable to set the pipeline to the `Null` state");

    debug!("Using {} as player", gst::version_string());
    
    // let gst_version_string = gst::version_string();
    // CString::new(gst::version_string().to_owned()).unwrap().into_raw()
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
                        rust_greeting();
                    }
            ui.label(format!("Name '{}', Age {}, version '{}'", self.name, self.age, self.version));
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