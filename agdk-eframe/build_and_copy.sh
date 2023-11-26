#!/bin/bash
# export OPENSSL_DIR=/usr
# export OPENSSL_DIR="/home/alex/Документы/android/rust-android-examples/agdk-eframe/ssl_1.1"
# export AARCH64_LINUX_ANDROID_OPENSSL_LIB_DIR="/home/alex/Документы/android/rust-android-examples/agdk-eframe/ssl_1.1/arm64-v8a"

export ANDROID_HOME=/home/alex/Android/Sdk
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653

export PATH=$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin
# export PKG_CONFIG_PATH=/home/alex/Документы/android/media/examples/android/libgstreamer_android_gen/gst-android-build/arm64-v8a/lib/pkgconfig
export PKG_CONFIG_PATH=/home/alex/Документы/android/rust-android-examples/gstreamer-android/gst-android-build/arm64-v8a/lib/pkgconfig
export JAVA_HOME=/opt/android-studio/jbr

# Step 1: Delete all files in the specified directory
rm -f app/src/main/jniLibs/arm64-v8a/*

# Step 2: Build the Rust project with the specified RUSTFLAGS
RUSTFLAGS="-lffi" cargo apk build

export JNI_LIBS="app/src/main/jniLibs/arm64-v8a"
# mkdir -p app/src/main/jniLibs/arm64-v8a/

if [ -d $JNI_LIBS ]; then
    echo "Folder exists"
else
    mkdir -p $JNI_LIBS
    echo "Folder created"
fi

# Step 3: Copy files from target/debug/apk/lib/arm64-v8a to the specified directory
cp target/debug/apk/lib/arm64-v8a/* app/src/main/jniLibs/arm64-v8a/

# Step 4: Rename libagdk_eframe.so to libmain.so
mv app/src/main/jniLibs/arm64-v8a/libagdk_eframe.so app/src/main/jniLibs/arm64-v8a/libmain.so

# Step 5: Run Gradle commands
./gradlew clean assembleDebug installDebug

adb shell am start -n co.realfit.agdkeframe/.MainActivity