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