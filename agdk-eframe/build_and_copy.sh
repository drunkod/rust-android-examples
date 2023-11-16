#!/bin/bash

# Step 1: Delete all files in the specified directory
rm -f app/src/main/jniLibs/arm64-v8a/*

# Step 2: Build the Rust project with the specified RUSTFLAGS
RUSTFLAGS="-lffi" cargo apk build

# Step 3: Copy files from target/debug/apk/lib/arm64-v8a to the specified directory
cp target/debug/apk/lib/arm64-v8a/* app/src/main/jniLibs/arm64-v8a/

# Step 4: Rename libagdk_eframe.so to libmain.so
mv app/src/main/jniLibs/arm64-v8a/libagdk_eframe.so app/src/main/jniLibs/arm64-v8a/libmain.so

# Step 5: Run Gradle commands
./gradlew clean assembleDebug installDebug

adb shell am start -n co.realfit.agdkeframe/.MainActivity