{ pkgs, rustToolchain, androidSdk, opensslAndroid, gstreamerAndroid }:
{
  agdk-eframe-apk = pkgs.stdenv.mkDerivation {
    pname = "agdk-eframe";
    version = "0.1.0";
    src = ./../..; # Points to rust-android-examples/ from agdk-eframe/modules/

    nativeBuildInputs = with pkgs; [
      rustToolchain
      cargo-ndk
      cargo-apk
      androidSdk
      jdk17
      gradle
      pkg-config
      cmake
      opensslAndroid
      gstreamerAndroid
    ];

    buildInputs = with pkgs; [ libffi ];

    configurePhase = ''
      export HOME=$TMPDIR
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
      export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
      if [ -d "${gstreamerAndroid}/gst-android-build/arm64-v8a/lib/pkgconfig" ]; then
        export PKG_CONFIG_PATH="${gstreamerAndroid}/gst-android-build/arm64-v8a/lib/pkgconfig"
      else
        export PKG_CONFIG_PATH="${gstreamerAndroid}/arm64/lib/pkgconfig"
      fi
      export JAVA_HOME="${pkgs.jdk17}"
      export GRADLE_USER_HOME=$TMPDIR/.gradle
      mkdir -p $GRADLE_USER_HOME
      yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true
    '';

    buildPhase = ''
      rm -f app/src/main/jniLibs/arm64-v8a/*.so
      rm -rf target/debug/apk/lib/arm64-v8a/* 2>/dev/null || true
      rm -rf target/release/apk/lib/arm64-v8a/* 2>/dev/null || true
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
        mv "$JNI_LIBS/libagdk_eframe.so" "$JNI_LIBS/libmain.so"
      fi
      LIBCXX_SHARED="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/24/libc++_shared.so"
      if [ -f "$LIBCXX_SHARED" ]; then
        cp "$LIBCXX_SHARED" "$JNI_LIBS/"
      fi
      if [ "$BUILD_MODE" = "release" ]; then
        ./gradlew clean assembleRelease
      else
        ./gradlew clean assembleDebug
      fi
    '';

    installPhase = ''
      mkdir -p $out/apk $out/lib/arm64-v8a
      cp app/build/outputs/apk/*/*.apk $out/apk/ 2>/dev/null || echo "Warning: No APK files found"
      cp app/src/main/jniLibs/arm64-v8a/*.so $out/lib/arm64-v8a/ 2>/dev/null || true
    '';
  };
}
