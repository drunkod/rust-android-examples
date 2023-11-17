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

work in vk live:
        text: "videotestsrc is-live=true ! videoconvert ! x264enc bitrate=1000 tune=zerolatency ! video/x-h264 ! h264parse ! video/x-h264 ! queue ! flvmux name=mux ! rtmp2sink location=rtmp://ovsu.mycdn.me/input/ audiotestsrc is-live=true ! audioconvert ! audioresample ! audio/x-raw,rate=48000 ! avenc_aac bitrate=96000 ! audio/mpeg ! aacparse ! audio/mpeg, mpegversion=4 ! mux.";

        text: "srtsrc uri=srt://192.168.3.70:8888?latency=2000 ! queue ! tsdemux name=demux demux. ! queue ! decodebin ! videoconvert ! videoscale ! video/x-raw,width=640,height=360 ! queue ! compositor name=videomix   sink_0::alpha=1 sink_1::alpha=1   ! decodebin   ! videoconvert   ! openh264enc ! video/x-h264 ! h264parse   ! queue   ! flvmux streamable=1 name=mux demux. ! queue   ! decodebin   ! audioconvert ! audioresample ! queue   ! audiomixer name=audiomix   ! audioconvert ! audioresample ! avenc_aac   ! queue   ! mux. srtsrc uri=srt://192.168.3.36:8889?latency=2000 ! queue ! tsdemux name=demux2 demux2. ! queue ! decodebin ! videoconvert ! videoscale ! video/x-raw,width=320,height=180   ! queue   ! videomix.     demux2.   ! queue   ! decodebin   ! audioconvert ! audioresample ! queue ! audiomix. mux. ! queue   ! rtmp2sink location=rtmp://ovsu.mycdn.me/input/";

        srtsrc uri=srt://192.168.3.70:8888?latency=2000 ! queue   ! tsdemux name=demux demux.  
         ! queue   ! decodebin   ! videoconvert   ! videoscale ! video/x-raw,width=1280,height=720     ! queue   ! compositor name=videomix   sink_0::alpha=1 sink_1::alpha=1   ! decodebin   ! videoconvert   ! x264enc bitrate=2500 tune=zerolatency  pass=17  ! video/x-h264 ! h264parse   
         ! queue   ! flvmux streamable=1 name=mux     demux.   
         ! queue   ! decodebin   ! audioconvert ! audioresample     
         ! queue   ! audiomixer name=audiomix   ! audioconvert ! audioresample ! avenc_aac bitrate=96000 ! audio/mpeg ! aacparse ! audio/mpeg, mpegversion=4 
         ! queue   ! mux.     srtsrc uri=srt://192.168.3.36:8889?latency=2000
               ! queue   ! tsdemux name=demux2     demux2.
                  ! queue   ! decodebin   ! videoconvert   ! videoscale ! video/x-raw,width=620,height=360   ! queue   ! videomix.     demux2.   
                  ! queue   ! decodebin   ! audioconvert ! audioresample   ! queue   ! audiomix.       mux.   ! queue   ! rtmp2sink location=rtmp://