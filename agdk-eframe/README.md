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