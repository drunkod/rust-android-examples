This tests using `GameActivity` with egui, winit and wgpu.

This is based on a re-worked winit backend here:
https://github.com/rib/winit/tree/android-activity

```
export ANDROID_NDK_HOME="path/to/ndk"
export ANDROID_HOME="path/to/sdk"

rustup target add aarch64-linux-android
cargo install cargo-ndk

cargo ndk -t arm64-v8a -o app/src/main/jniLibs/  build
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

RUSTFLAGS="-lffi" cargo apk build

adb install /home/alex/Документы/android/rust-android-examples/agdk-eframe/target/debug/apk/myapp.apk

```