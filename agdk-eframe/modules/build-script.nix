{ pkgs, androidSdk, opensslAndroid, gstreamerAndroid }:
{
  buildScript = pkgs.writeShellScriptBin "build-apk" ''
    #!/usr/bin/env bash
    set -e

    # Setup environment
    export OPENSSL_ROOT_DIR="${opensslAndroid}"
    export OPENSSL_DIR="$OPENSSL_ROOT_DIR"
    export OPENSSL_LIB_ROOT_DIR="$OPENSSL_ROOT_DIR"
    export OPENSSL_INCLUDE_ROOT_DIR="$OPENSSL_ROOT_DIR"
    export OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/android-arm64/lib"
    export AARCH64_LINUX_ANDROID_OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/android-arm64/lib"
    export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/android-arm64/include"
    export OPENSSL_STATIC=1
    export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/25.2.9519653"
    export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
    export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
    if [ -d "${gstreamerAndroid}/gst-android-build/arm64-v8a/lib/pkgconfig" ]; then
      export PKG_CONFIG_PATH="${gstreamerAndroid}/gst-android-build/arm64-v8a/lib/pkgconfig"
    else
      export PKG_CONFIG_PATH="${gstreamerAndroid}/arm64/lib/pkgconfig"
    fi
    export JAVA_HOME="${pkgs.jdk17}"

    echo "Build environment:"
    echo "  PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
    echo "  OPENSSL_LIB_DIR=$OPENSSL_LIB_DIR"
    echo "  ANDROID_NDK_HOME=$ANDROID_NDK_HOME"

    # Clean
    echo "Cleaning..."
    rm -f app/src/main/jniLibs/arm64-v8a/*.so
    rm -rf target/debug/apk/lib/arm64-v8a/* 2>/dev/null || true
    rm -rf target/release/apk/lib/arm64-v8a/* 2>/dev/null || true

    # Build Rust
    echo "Building Rust project..."
    BUILD_MODE="''${BUILD_MODE:-release}"
    BUILD_FLAG=""
    TARGET_DIR="release"
    if [ "$BUILD_MODE" = "debug" ]; then
      BUILD_FLAG=""
      TARGET_DIR="debug"
    else
      BUILD_FLAG="--release"
    fi

    PKG_CONFIG_ALLOW_CROSS=1 \
    RUSTFLAGS="-lffi" \
    RUST_BACKTRACE=1 \
    cargo ndk -t arm64-v8a -o app/src/main/jniLibs/ build $BUILD_FLAG

    export JNI_LIBS="app/src/main/jniLibs/arm64-v8a"
    mkdir -p "$JNI_LIBS"
    if [ -f "$JNI_LIBS/libagdk_eframe.so" ]; then
      echo "Renaming libagdk_eframe.so to libmain.so"
      mv "$JNI_LIBS/libagdk_eframe.so" "$JNI_LIBS/libmain.so"
    fi

    # Copy libc++_shared.so
    LIBCXX_SHARED="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/24/libc++_shared.so"
    if [ -f "$LIBCXX_SHARED" ] && [ ! -f "$JNI_LIBS/libc++_shared.so" ]; then
      echo "Copying libc++_shared.so"
      cp "$LIBCXX_SHARED" "$JNI_LIBS/"
    fi

    # Build APK
    echo "Building APK..."
    if [ "$BUILD_MODE" = "release" ]; then
      ./gradlew clean assembleRelease
      APK_LOCATION="app/build/outputs/apk/release"
    else
      ./gradlew clean assembleDebug
      APK_LOCATION="app/build/outputs/apk/debug"
    fi

    echo "APK built successfully at: $APK_LOCATION"

    # Optional install/run
    if [ "''${INSTALL_AND_RUN:-0}" = "1" ]; then
      echo "Installing APK..."
      if [ "$BUILD_MODE" = "release" ]; then
        ./gradlew installRelease
      else
        ./gradlew installDebug
      fi
      echo "Starting application..."
      adb shell am start -n co.realfit.agdkeframe/.MainActivity
      echo "Showing logs..."
      adb logcat | egrep '(agdkeframe|gst|actix_web|tracing_actix_web|RustStdoutStderr|main    :)'
    fi
  '';
}
