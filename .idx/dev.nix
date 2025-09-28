# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use
  channel = "stable-25.05";

  # Packages to install in the environment
  packages = [
    # Rust Toolchain
    pkgs.rustup
    pkgs.cargo-watch
    pkgs.cargo-edit
    pkgs.cargo-outdated
    pkgs.cargo-ndk
    pkgs.cargo-apk

    # Android SDK/NDK
    pkgs.androidenv.androidPkgs.androidsdk

    # Java/JDK
    pkgs.jdk17
    pkgs.gradle

    # Core Build Tools
    pkgs.gcc
    pkgs.pkg-config
    pkgs.gnumake
    pkgs.cmake
    pkgs.perl # For OpenSSL

    # System Libraries
    pkgs.glib
    pkgs.glib.dev
    pkgs.openssl
    pkgs.openssl.dev
    pkgs.libffi

    # GStreamer & Plugins
    pkgs.gst_all_1.gstreamer
    pkgs.gst_all_1.gstreamer.dev
    pkgs.gst_all_1.gst-plugins-base
    pkgs.gst_all_1.gst-plugins-base.dev
    pkgs.gst_all_1.gst-plugins-good
    pkgs.gst_all_1.gst-plugins-bad
    pkgs.gst_all_1.gst-plugins-ugly
    pkgs.gst_all_1.gst-libav
    pkgs.gst_all_1.gst-devtools
    pkgs.gst_all_1.gst-editing-services

    # Multimedia Libraries
    pkgs.libva
    pkgs.libvpx
    pkgs.x264
    pkgs.x265

    # GUI Dependencies (for eframe)
    pkgs.libxkbcommon
    pkgs.libGL
    pkgs.wayland
    pkgs.xorg.libXcursor
    pkgs.xorg.libXrandr
    pkgs.xorg.libXi
    pkgs.xorg.libX11

    # Android Development Tools
    pkgs.adb-sync
    pkgs.scrcpy

    # Build Script
    (pkgs.writeShellScriptBin "build-apk" ''
      #!/usr/bin/env bash
      set -e

      # Setup environment
      export ANDROID_HOME="${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk"
      export ANDROID_SDK_ROOT="$ANDROID_HOME"
      export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/25.2.9519653"
      export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
      export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
      export JAVA_HOME="${pkgs.jdk17}"

      # OpenSSL configuration
      OPENSSL_ROOT_DIR="/home/$USER/Документы/android/rust-android-examples/depend/openssl"
      if [ -d "$OPENSSL_ROOT_DIR/android-arm64" ]; then
        export OPENSSL_DIR="$OPENSSL_ROOT_DIR"
        export OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/android-arm64/lib"
        export AARCH64_LINUX_ANDROID_OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/android-arm64/lib"
        export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/android-arm64/include"
      else
        echo "Warning: Prebuilt OpenSSL not found at $OPENSSL_ROOT_DIR, using system OpenSSL"
        OPENSSL_ROOT_DIR="${pkgs.openssl.dev}"
        export OPENSSL_DIR="$OPENSSL_ROOT_DIR"
        export OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/lib"
        export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/include"
      fi
      export OPENSSL_STATIC=1

      # GStreamer configuration
      GSTREAMER_ROOT="/home/$USER/Документы/android/rust-android-examples/gstreamer-android"
      if [ -d "$GSTREAMER_ROOT/gst-android-build/arm64-v8a/lib/pkgconfig" ]; then
        export PKG_CONFIG_PATH="$GSTREAMER_ROOT/gst-android-build/arm64-v8a/lib/pkgconfig"
      elif [ -d "$GSTREAMER_ROOT/arm64/lib/pkgconfig" ]; then
        export PKG_CONFIG_PATH="$GSTREAMER_ROOT/arm64/lib/pkgconfig"
      else
        echo "Warning: Prebuilt GStreamer not found at $GSTREAMER_ROOT, using system GStreamer"
        export PKG_CONFIG_PATH="${pkgs.lib.makeSearchPath "lib/pkgconfig" [
          pkgs.gst_all_1.gstreamer.dev
          pkgs.gst_all_1.gst-plugins-base.dev
        ]}"
      fi

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
        adb logcat -s main RustStdoutStderr
      fi
    '')
  ];

  # Environment variables
  env = {
    ANDROID_HOME = "${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk";
    ANDROID_NDK_HOME = "${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk/ndk/25.2.9519653";
    ANDROID_NDK_ROOT = "${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk/ndk/25.2.9519653";
    JAVA_HOME = "${pkgs.jdk17}";
    PATH = [ "${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin" ];
    RUST_BACKTRACE = "1";
    PKG_CONFIG_ALLOW_CROSS = "1";
    RUSTFLAGS = "-lffi";
  };

  idx = {
    # Enable previews for Android app
    previews = {
      enable = true;
      previews = {
        android = {
          command = [ "./gradlew" ":app:installDebug" ];
          cwd = ".";
          manager = "android";
          activity = "co.realfit.agdkeframe/.MainActivity";
          env = {
            ANDROID_HOME = "${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk";
            JAVA_HOME = "${pkgs.jdk17}";
          };
        };
      };
    };

    # Workspace lifecycle hooks
    workspace = {
      onCreate = {
        setup = ''
          echo "Setting up AGDK eframe Android environment..."
          rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android
          which cargo-ndk > /dev/null || cargo install cargo-ndk
          which cargo-apk > /dev/null || cargo install cargo-apk
          yes | ${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true
          echo "Setup complete! Run 'build-apk' to build and deploy your app."
        '';
        default.openFiles = [ "src/main.rs" "app/build.gradle" ];
      };

      onStart = {
        welcome = ''
          echo "AGDK eframe Android environment ready!"
          echo "Run 'build-apk' to build and deploy your app"
        '';
        default.openFiles = [ "src/main.rs" ];
      };
    };
  };
}
