use eframe::NativeOptions;
#[cfg(target_os = "android")]
use egui_winit::winit::platform::android::activity::AndroidApp;

#[cfg(target_os = "android")]
#[no_mangle]
fn android_main(app: AndroidApp) {
    use log::Level;

    use egui_winit::winit::platform::android::EventLoopBuilderExtAndroid;
// Set the GStreamer debug level before initializing GStreamer
env::set_var("GST_DEBUG", "srtsink:8,giosrc:8");
env::set_var("RUST_BACKTRACE", "full");
// env::set_var("GST_DEBUG", "3"); // Levels are 0-5; 3 is a good starting point

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

    crate::_main(options).unwrap_or_else(|err| {
        log::error!("Failure while running EFrame application: {err:?}");
    });
}
