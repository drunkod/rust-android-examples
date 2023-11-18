// Import the utils module at the top of your file
// mod utils;
mod daytime;
mod geoip;
mod smhi;

pub mod ui {
    slint::include_modules!();
}
use slint::ComponentHandle;

// use crate::utils;
// mod utils;
// use anyhow::{anyhow, Error};
// use derive_more::{Display, Error};

// use std::{env, process, thread};
// use gst::prelude::*;
// use log::{debug};
//add RUSTFLAGS="-lffi" with error dlopen failed: cannot locate symbol "ffi_type_void" referenced by

use std::os::raw::c_char;
use std::ffi::CString;

// #[derive(Debug, Display, Error)]
// #[display(fmt = "Missing element {_0}")]
// struct MissingElement(#[error(not(source))] String);

// #[derive(Debug, Display, Error)]
// #[display(fmt = "Received error from {src}: {error} (debug: {debug:?})")]
// struct ErrorMessage {
//     src: gst::glib::GString,
//     error: gst::glib::Error,
//     debug: Option<gst::glib::GString>,
// }

// use eframe::egui;

// use eframe::{NativeOptions, Renderer};


// #[cfg(target_os = "android")]
// use egui_winit::winit::platform::android::activity::AndroidApp;





// pub fn run<T, F: FnOnce() -> T + Send + 'static>(main: F) -> T
// where
//     T: Send + 'static,
// {
//     main()
// }


#[cfg(target_os = "android")]
#[no_mangle]
fn android_main(app: i_slint_backend_android_activity::AndroidApp) {
    android_logger::init_once(
        android_logger::Config::default().with_max_level(log::LevelFilter::Debug),
    );
    
    // let app_clone = app.clone();
    slint::platform::set_platform(Box::new(
        i_slint_backend_android_activity::AndroidPlatform::new(app)
    )).unwrap();

    // ... rest of your code ...
    // slint::slint!{
    //     export component MainWindow inherits Window {
    //         Text { text: "Hello World"; }
    //     }
    // }
    // slint::slint!(import { Recipe } from "../agdk-eframe/ui/button_native.slint";);

    // let recipe: Recipe = Recipe::new().unwrap();
    // // is a method that creates a Weak pointer from an existing reference. 
    // // Weak references do not count towards ownership and they do not affect whether 
    // // the Recipe is dropped or not. They are a way to safely share references to an object,
    // //  with the caveat that the referred object might have been dropped already.
    // let recipe_weak: slint::Weak<Recipe> = recipe.as_weak();

    // recipe.on_switch_pressed(move || {
    //     let recipe: Recipe = recipe_weak.upgrade().unwrap();
    //     let mut value: i32 = recipe.get_counter();
    //     value = value + 1;
    //     recipe.set_counter(value);
    //     // test audio audiotestsrc
    //     // let pipeline_str = "audiotestsrc wave=saw freq=205 ! autoaudiosink".to_owned().to_string();
    //     let pipeline_str: String = recipe.get_text().to_owned().to_string();

    //     // Call the launch_pipeline function with recipe_weak
    //     utils::launch_pipeline(pipeline_str, recipe_weak.clone());
    //     // let result = thread::spawn(move || {
    //     //     rust_greeting(pipeline_str)
    //     // }).join().unwrap();
    //     // let result: Result<(), Error> = run(|| rust_greeting(pipeline_str));
    //     // run(|| rust_greeting(pipeline_str));
    //     // thread::spawn(move || {
    //     //         rust_greeting(pipeline_str)
    //     //     }).join().unwrap();
    //     // match run(|| rust_greeting(pipeline_str))
    //     //  {
    //     //     Ok(r) => r,
    //     //     Err(e) => recipe.set_log(e.to_string().into()),
    //     // }
    //     // match result {
    //     //     Ok(_) => {
    //     //         // If rust_greeting returned Ok, everything went fine
    //     //         recipe.set_log("Pipeline ran successfully".into()); // Update log
    //     //     }
    //     //     Err(err_msg) => {
    //     //         // If rust_greeting returned an error, log the error message
    //     //         recipe.set_log(err_msg.to_string().into()); // Update log with the error message
    //     //     }
    //     // } 
    //     // let mut text = recipe.get_text();
    //     // rust_greeting(&text);
    //     // custom show_soft_input
    //     // app_clone.show_soft_input(true);
    // });    

    // recipe.run().unwrap();

    let window = ui::MainWindow::new().unwrap();

    geoip::refresh(window.as_weak());

    window.global::<ui::GeoIP>().on_refresh({
        let handle = window.as_weak();
        move || geoip::refresh(handle.clone())
    });
    window.global::<ui::DayTime>().on_refresh({
        let handle = window.as_weak();
        move |latitude, longitude, timezone| {
            daytime::refresh(latitude, longitude, timezone.to_string(), handle.clone())
        }
    });
    window.global::<ui::Smhi>().on_refresh({
        let handle = window.as_weak();
        move |latitude, longitude| smhi::refresh(latitude, longitude, handle.clone())
    });

    slint::Timer::default().start(
        slint::TimerMode::Repeated,
        std::time::Duration::from_secs(24 * 3600),
        {
            let handle = window.as_weak();
            move || geoip::refresh(handle.clone())
        },
    );

    slint::Timer::default().start(
        slint::TimerMode::Repeated,
        std::time::Duration::from_secs(3600),
        {
            let geoip = window.global::<ui::GeoIP>();
            let latitude = geoip.get_latitude();
            let longitude = geoip.get_longitude();
            let handle = window.as_weak();
            move || smhi::refresh(latitude, longitude, handle.clone())
        },
    );

    window.on_close({
        let handle = window.as_weak();
        move || handle.unwrap().window().hide().unwrap()
    });

    window.run().unwrap();   
    
    // MainWindow::new().unwrap().run().unwrap();
}
// #[cfg(not(target_os = "android"))]
// fn main() {
//     env_logger::builder()
//         .filter_level(log::LevelFilter::Warn) // Default Log Level
//         .parse_default_env()
//         .init();

//     _main(NativeOptions::default());
// }