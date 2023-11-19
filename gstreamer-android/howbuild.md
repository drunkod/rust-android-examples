gha
https://github.com/acxz/qgroundcontrol/blob/gst/.github/workflows/android_64_release.yml
https://github.com/yulin-li/ActionPipelines/tree/master/.github/workflows

https://github.com/Meonardo/GenLibGStreamerAndroid/blob/master/build.sh

Builder on QMAKE
https://github.com/acxz/qgroundcontrol/blob/gst/qgroundcontrol.pro

Docker images with Qt, GStreamer, NDK specifically to build projects on CI
gstreamer-qt-docker with cerbero Builder
https://github.com/franzos/gstreamer-qt-docker

`
cd /vendor/cerbero
gstreamer-1.0-android-universal-1.22.2-runtime.tar.xz 
gstreamer-1.0-android-universal-1.22.2.tar.xzcat
copy file from docker
docker cp <containerId>:/vendor/cerbero/gstreamer-1.0-android-universal-1.22.2.tar.xz .
`

* Create folder `jniLibs` inside `app\src\main`. (`jniLibs` should be at the same level as the `java` folder)
* Create four folders inside `jniLibs` with names `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64` respectively.
* Create `libgstreamer_android.so` for each Application Binary Interface (ABI) using the information provided in  [Compressed audio input with the Speech SDK on Android](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/ai-services/speech-service/includes/how-to/compressed-audio-input/gstreamer-android.md)
* Place the `libgstreamer_android.so` inside `jniLibs\arm64-v8a` and the other folders respectively. 

# Android build
http://ci.nnstreamer.ai/nnstreamer/ci/daily-build/daily-build.sh
