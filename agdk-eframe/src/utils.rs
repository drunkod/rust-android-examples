// utils.rs
    // use crate::shared::Recipe;
    use anyhow::{anyhow, Error};
    use derive_more::{Display, Error};

    use std::thread;
    use gst::prelude::*;

    use slint::Weak;
    // use crate::shared::Recipe;

    #[derive(Debug, Display, Error)]
    #[display(fmt = "Missing element {_0}")]
    struct MissingElement(#[error(not(source))] String);
    
    #[derive(Debug, Display, Error)]
    #[display(fmt = "Received error from {src}: {error} (debug: {debug:?})")]
    struct ErrorMessage {
        src: gst::glib::GString,
        error: gst::glib::Error,
        debug: Option<gst::glib::GString>,
    }


    pub fn launch_pipeline(pipeline_str: String, recipe_weak: Weak<Recipe> ) {
        // let recipe_clone_weak: slint::Weak<Recipe> = recipe_clone.as_weak();
        // Spawn a new thread
        thread::spawn(move || {
                        // Upgrade the weak reference to a strong one
                        let recipe: Recipe = match recipe_weak.upgrade() {
                            Some(recipe) => recipe,
                            None => return, // Recipe has been dropped
                        };
            // Now you can use the recipe  
                      
            gst::init().unwrap();
            let gst_version_string: gst::glib::GString = gst::version_string();

            let mut context: gst::ParseContext = gst::ParseContext::new();
            // Parse the pipeline
            let pipeline = gst::parse_launch_full(&pipeline_str, None, gst::ParseFlags::empty())
                .expect("Failed to parse pipeline");
            let pipeline: gst::Element = match gst::parse_launch_full(
                &pipeline_str,
                Some(&mut context),
                gst::ParseFlags::empty(),
            ) {
                Ok(pipeline) => pipeline,
                Err(err) => {
                    if let Some(gst::ParseError::NoSuchElement) = err.kind::<gst::ParseError>() {
                        return Err(MissingElement(context.missing_elements().join(",")).into());
                    } else {
                        return Err(err.into());
                    }
                }
            };

            // ... rest of your code ...
        });
    }


// #[no_mangle]
// pub extern fn rust_greeting(pipeline_str: String) -> Result<(), Error> {
//     // Get a string containing the passed pipeline launch syntax audiotestsrc wave=saw freq=205 ! autoaudiosink
//     // let pipeline_str = "audiotestsrc wave=saw freq=205 ! autoaudiosink";
    
//     gst::init().unwrap();
//     let gst_version_string: gst::glib::GString = gst::version_string();
    
//     // Let GStreamer create a pipeline from the parsed launch syntax on the cli.
//     // In comparison to the launch_glib_main example, this is using the advanced launch syntax
//     // parsing API of GStreamer. The function returns a Result, handing us the pipeline if
//     // parsing and creating succeeded, and hands us detailed error information if something
//     // went wrong. The error is passed as gst::ParseError. In this example, we separately
//     // handle the NoSuchElement error, that GStreamer uses to notify us about elements
//     // used within the launch syntax, that are not available (not installed).
//     // Especially GUIs should probably handle this case, to tell users that they need to
//     // install the corresponding gstreamer plugins.

//     let mut context: gst::ParseContext = gst::ParseContext::new();

//     let pipeline: gst::Element = match gst::parse_launch_full(
//         &pipeline_str,
//         Some(&mut context),
//         gst::ParseFlags::empty(),
//     ) {
//         Ok(pipeline) => pipeline,
//         Err(err) => {
//             if let Some(gst::ParseError::NoSuchElement) = err.kind::<gst::ParseError>() {
//                 return Err(MissingElement(context.missing_elements().join(",")).into());
//             } else {
//                 return Err(err.into());
//             }
//         }
//     };
//     let bus: gst::Bus = pipeline.bus().unwrap();
//     pipeline.set_state(gst::State::Playing)?;

//     for msg in bus.iter_timed(gst::ClockTime::NONE) {
//         use gst::MessageView;

//         match msg.view() {
//             MessageView::Eos(..) => break,
//             MessageView::Error(err) => {
//                 return Err(ErrorMessage {
//                     src: msg
//                         .src()
//                         .map(|s: &gst::Object| s.path_string())
//                         .unwrap_or_else(|| gst::glib::GString::from("UNKNOWN")),
//                     error: err.error(),
//                     debug: err.debug(),
//                 }
//                 .into());
//             }
//             _ => (),
//         }
//     }

//     pipeline.set_state(gst::State::Null)?;

//     Ok(())
// }    