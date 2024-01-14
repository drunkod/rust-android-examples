## TODO

- [ ] Support newer Android SDK's
- [ ] Support different GStreamer versions
- [ ] How create cerbero recipe
- [ ] Add docker repo builder for custom cerbero recipe
- [ ] Add srt receiver
- [ ] Add diagram how work rtmp distanathion
- [ ] Synchronized Audio
- [ ] How Working app in background (freeze video bitrate from 2000kb to 300-500kb )
- [ ] Add image from base64 encode, from memory without storage
- [ ] research ges-launch-1.0 --load project.xges -o project.mp4 # encode
- [ ] research add overlay with Overlay implemented with OpenCV, PyCairo
- [ ] research souphttpsrc work
- [+] research giosrc work

- [ ] research wpe-and-gstreamer work
https://base-art.net/Articles/web-augmented-graphics-overlay-broadcasting-with-wpe-and-gstreamer/

https://lifestyletransfer.com/how-to-watch-youtube-videos-with-gstreamer/


https://lifestyletransfer.com/how-to-draw-kitten-on-video-faster-with-gstreamer/
https://github.com/jackersson/gst-overlay

https://www.jamesh.id.au/talks/plug-2021-05/ges-slides.pdf
rendered to a video from presentation
https://github.com/plugorgau/bbb-render

 RTP Server for Broadcasting Network-Clock Synchronized Audio
https://github.com/zweiund40GmbH/micast-broadcaster

This tests using `GameActivity` with egui, winit and wgpu.

This is based on a re-worked winit backend here:
https://github.com/rib/winit/tree/android-activity

```
export ANDROID_NDK_HOME="path/to/ndk"
export ANDROID_HOME="path/to/sdk"

rustup target add aarch64-linux-android
cargo install cargo-ndk

RUSTFLAGS="-lffi" cargo ndk -t arm64-v8a -o app/src/main/jniLibs/ build
./gradlew build
./gradlew installDebug
adb shell am start -n co.realfit.agdkeframe/.MainActivity
```
```
rustup target add aarch64-linux-android
cargo install cargo-apk

export ANDROID_HOME=/home/alex/Android/Sdk
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653

export PKG_CONFIG_PATH=/home/alex/Документы/android/media/examples/android/libgstreamer_android_gen/gst-android-build/arm64-v8a/lib/pkgconfig

export JAVA_HOME=/opt/android-studio/jbr
#17 ver
RUSTFLAGS="-lffi" cargo apk build

./gradlew clean assembleDebug installDebug
adb shell am start -n co.realfit.agdkeframe/.MainActivity
adb logcat | egrep '(agdkeframe|gst)'
adb logcat | egrep '(actix_web|tracing_actix_web|RustStdoutStderr|main)'
# logcat output by the tags "main" and "RustStdoutStderr",
adb logcat -s main RustStdoutStderr
```

## How test actix_web from curl

```
curl -X POST -H "Content-Type: application/json" -d '{"action":"do_something", "value":10}' http://192.168.3.40:8080/command

```
## Commands

```
`createvideogenerator`, `createsource`, `createdestination`, `createmixer`, `connect`, `start`, `reschedule`, `remove`, `disconnect`, `getinfo`, `addcontrolpoint`, `removecontrolpoint`
```

## Error

```
11-29 13:28:00.736  5787  5812 I RustStdoutStderr: (<unknown>:5787): GLib-GObject-WARNING **: 13:28:00.736: cannot register existing type 'GstAppSrc'
11-29 13:28:00.736  5787  5812 I RustStdoutStderr: 
11-29 13:28:00.736  5787  5812 I RustStdoutStderr: (<unknown>:5787): GLib-GObject-WARNING **: 13:28:00.736: cannot add private field to invalid (non-instantiatable) type '<invalid>'
11-29 13:28:00.737  5787  5812 I RustStdoutStderr: 
11-29 13:28:00.737  5787  5812 I RustStdoutStderr: (<unknown>:5787): GLib-GObject-CRITICAL **: 13:28:00.737: g_type_add_interface_static: assertion 'G_TYPE_IS_INSTANTIATABLE (instance_type)' failed
11-29 13:28:00.737  5787  5812 I RustStdoutStderr: 
11-29 13:28:00.737  5787  5812 I RustStdoutStderr: (<unknown>:5787): GLib-CRITICAL **: 13:28:00.737: g_once_init_leave: assertion 'result != 0' failed
11-29 13:28:00.737  5787  5812 I RustStdoutStderr: Failed to downcast to AppSrc. Error: Element { inner: TypedObjectRef { inner: 0x74e433c8a0, type: GstAppSrc } }
```
The error messages suggest that the type 'GstAppSrc' is already registered and cannot be registered again. This could be due to the 'GstAppSrc' type being created multiple times in the same process.

Here are a few possibilities:

You're trying to create a 'GstAppSrc' object after it's already been created. In this case, you should try reusing the existing 'GstAppSrc' object instead of creating a new one.

Your code could be running in a multi-threaded environment where multiple threads are attempting to create a 'GstAppSrc' at the same time. If this is the case, you need to ensure that the 'GstAppSrc' creation is thread-safe.

If you're using a library that also uses GStreamer, it might be registering 'GstAppSrc' before your code does. You need to check if this is happening and if so, consult the library's documentation or source code to figure out how to handle it.

The error message "Failed to downcast to AppSrc. Error: Element { inner: TypedObjectRef { inner: 0x74e433c8a0, type: GstAppSrc } }" suggests that the downcast operation failed. The 'Element' you're trying to downcast might not be of type 'GstAppSrc'. You can check the type of the 'Element' before downcasting to make sure it's the correct type.

```
        if element.is::<gst_app::AppSrc>() {
            match element.downcast::<gst_app::AppSrc>() {
                Ok(appsrc) => {
                    println!("Successfully created and downcasted video appsrc");
                    Some(appsrc)
                },
                Err(err) => {
                    println!("Failed to downcast to AppSrc. Error: {:?}", err);
                    None
                }
            }
        } else {
            println!("Element is not of type AppSrc");
            None
        }
```
After Add to gstreamer-android/jni/Android.mk 
Successfully created and downcasted video appsrc

```
GSTREAMER_EXTRA_DEPS      := ... gstreamer-app-1.0
```

## Error rtmp node crash after send command Start

Create_command with json: Start { id: "centricular-output", cue_time: None, end_time: None }

Ok(Info(Info { nodes: {"centricular-output": Destination(DestinationInfo { family: Rtmp { uri: "rtmps://dc4-1.rtmp.t.me/s/4018499832:im0paW2eEZTVdPI_JN2VaQ" }, audio_slot_id: Some("channel-1->centricular-output_1f2379bb-7bb5-47a5-8d3b-d2ba4717d6eb"), video_slot_id: Some("channel-1->centricular-output_1f2379bb-7bb5-47a5-8d3b-d2ba4717d6eb"), cue_time: None, end_time: None, state: Initial }), "channel-1": Mixer(MixerInfo { slots: {}, video_consumer_slot_ids: Some([]), audio_consumer_slot_ids: Some([]), cue_time: Some(2023-11-30T06:47:51.491984981Z), end_time: None, state: Started, settings: {"fallback-image": String(""), "height": Number(720), "fallback-timeout": Number(500), "sample-rate": Number(44100), "width": Number(1280)}, control_points: {}, slot_settings: {}, slot_control_points: {} })} }))

[alex@fedora agdk-eframe]$ python ../scripts/crossfade.py source_uri dest_uridest_uri
Ok(Success)
Ok(Info(Info { nodes: {"channel-1": Mixer(MixerInfo { slots: {}, video_consumer_slot_ids: Some([]), audio_consumer_slot_ids: Some([]), cue_time: Some(2023-11-30T06:47:51.491984981Z), end_time: None, state: Started, settings: {"fallback-image": String(""), "sample-rate": Number(44100), "width": Number(1280), "height": Number(720), "fallback-timeout": Number(500)}, control_points: {}, slot_settings: {}, slot_control_points: {} })} }))

11-30 12:19:48.124  5144  5173 I RustStdoutStderr: #21 Create_command with json: Start { id: "centricular-output", cue_time: None, end_time: None }
11-30 12:19:48.129  5144  5173 I RustStdoutStderr: RTMP connection established to uri: rtmps://dc4-1.rtmp.t.me/s/4018499832:im0paW2eEZTVdPI_JN2VaQ
11-30 12:19:48.155  5144  5173 I RustStdoutStderr: Video pipeline successfully linked