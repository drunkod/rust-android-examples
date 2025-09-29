# /home/user/rust-android-examples/.idx/dev.nix
{ pkgs, lib, ... }:
let
   # Import the Android overlay
  androidOverlay = import ./android-overlay.nix { inherit pkgs; };
  # Extend pkgs with the overlay
  extendedPkgs = pkgs.extend androidOverlay;
in
{
  # Import environment setup
  imports = [
    {
      # Which nixpkgs channel to use
      channel = "stable-25.05";

      # Packages to install in the environment
      packages = with extendedPkgs; [
        # Rust Toolchain
        rustup
        cargo-watch
        cargo-edit
        cargo-outdated
        cargo-ndk
        cargo-apk

        # Android SDK/NDK
        androidSdk

        # Java/JDK
        jdk17
        gradle

        # Core Build Tools
        gcc
        pkg-config
        gnumake
        cmake
        perl

        # System Libraries
        glib
        glib.dev
        openssl
        openssl.dev
        libffi

        # GStreamer & Plugins
        gst_all_1.gstreamer
        gst_all_1.gstreamer.dev
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-base.dev
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gst_all_1.gst-devtools
        gst_all_1.gst-editing-services

        # Multimedia Libraries
        libva
        libvpx
        x264
        x265

        # GUI Dependencies (for eframe)
        libxkbcommon
        libGL
        wayland
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXi
        xorg.libX11

        # Android Development Tools
        adb-sync
        scrcpy
      ];

      # Environment variables 2 
      env = {
        ANDROID_HOME = lib.mkForce "${extendedPkgs.androidSdk}/libexec/android-sdk";
        ANDROID_SDK_ROOT = lib.mkForce "${extendedPkgs.androidSdk}/libexec/android-sdk";
        ANDROID_NDK_HOME = "${extendedPkgs.androidSdk}/libexec/android-sdk/ndk/25.2.9519653";
        ANDROID_NDK_ROOT = "${extendedPkgs.androidSdk}/libexec/android-sdk/ndk/25.2.9519653";
        JAVA_HOME = "${extendedPkgs.jdk17}";
        PATH = [
          "${extendedPkgs.androidSdk}/libexec/android-sdk/cmdline-tools/latest/bin"
          "${extendedPkgs.androidSdk}/libexec/android-sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin"
          "${extendedPkgs.rustup}/bin"
        ];
        RUST_BACKTRACE = "1";
        PKG_CONFIG_ALLOW_CROSS = "1";
        RUSTFLAGS = "-lffi";
        NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE = "1";
      };
    }

    # Module for IDX previews
    {
      idx.previews = {
        enable = true;
        previews = {
          android = {
            command = [ "./gradlew" ":app:installDebug" ];
            cwd = ".";
            manager = "android";
            activity = "co.realfit.agdkeframe/.MainActivity";
            env = {
              ANDROID_HOME = "${extendedPkgs.androidSdk}/libexec/android-sdk";
              JAVA_HOME = "${extendedPkgs.jdk17}";
              NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE = "1";
            };
          };
        };
      };
    }

    # Module for workspace hooks
    {
      idx.workspace = {
        onCreate = {
          setup = ''
            echo "Setting up AGDK eframe Android environment..."

            # Determine base directory based on permissions
            BASE_DIR="/home/user/rust-android-examples"
            if [ ! -w "/home/user" ]; then
              echo "Warning: /home/user not writable, falling back to /root/rust-android-examples"
              BASE_DIR="/root/rust-android-examples"
              mkdir -p "$BASE_DIR"
              sudo chown -R $(whoami) "$BASE_DIR" 2>/dev/null || true
            else
              if [ ! -w "$BASE_DIR" ]; then
                echo "Fixing permissions for $BASE_DIR..."
                sudo chown -R $(whoami) "$BASE_DIR" 2>/dev/null || true
              fi
            fi

            # Setup Rust targets
            export PATH="${extendedPkgs.rustup}/bin:$PATH"
            rustup --version || { echo "Error: Rustup not available"; exit 1; }
            rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android

            # Install cargo tools
            which cargo-ndk > /dev/null || cargo install cargo-ndk
            which cargo-apk > /dev/null || cargo install cargo-apk

            # Accept Android licenses
            yes | ${extendedPkgs.androidSdk}/libexec/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true

            # Setup OpenSSL
            OPENSSL_DEST="$BASE_DIR/depend/openssl"
            if [ ! -d "$OPENSSL_DEST/android-arm64" ]; then
              echo "Setting up prebuilt OpenSSL 3.0.12..."
              mkdir -p "$OPENSSL_DEST"
              curl -L https://www.openssl.org/source/openssl-3.0.12.tar.gz -o /tmp/openssl.tar.gz
              tar -xzf /tmp/openssl.tar.gz -C /tmp
              cd /tmp/openssl-3.0.12
              export ANDROID_NDK_ROOT="${extendedPkgs.androidSdk}/libexec/android-sdk/ndk/25.2.9519653"
              ./Configure android-arm64 --prefix="$OPENSSL_DEST/android-arm64" -D__ANDROID_API__=24 no-shared no-tests
              make -j$(nproc)
              make install_sw
              cd -
              rm -rf /tmp/openssl-3.0.12 /tmp/openssl.tar.gz
              if [ ! -d "$OPENSSL_DEST/android-arm64" ]; then
                echo "Error: Failed to setup OpenSSL at $OPENSSL_DEST/android-arm64"
                exit 1
              fi
            fi

            # Setup GStreamer
            GSTREAMER_DEST="$BASE_DIR/gstreamer-android"
            if [ ! -d "$GSTREAMER_DEST/arm64/lib/pkgconfig" ]; then
              echo "Setting up prebuilt GStreamer 1.22.12..."
              mkdir -p "$GSTREAMER_DEST"
              curl -L https://gstreamer.freedesktop.org/data/pkg/android/1.22.12/gstreamer-1.0-android-universal-1.22.12.tar.xz -o /tmp/gstreamer.tar.xz
              tar -xf /tmp/gstreamer.tar.xz -C "$GSTREAMER_DEST"
              mv "$GSTREAMER_DEST/arm64" "$GSTREAMER_DEST/arm64-tmp" 2>/dev/null || true
              mv "$GSTREAMER_DEST/arm64-tmp" "$GSTREAMER_DEST/arm64" 2>/dev/null || true
              rm -rf /tmp/gstreamer.tar.xz
              if [ ! -d "$GSTREAMER_DEST/arm64/lib/pkgconfig" ]; then
                echo "Error: Failed to setup GStreamer at $GSTREAMER_DEST/arm64"
                exit 1
              fi
            fi

            # Create build-apk script
            cat > "$BASE_DIR/build-apk" << 'EOF'
            #!/usr/bin/env bash
            set -e
            export NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1
            export ANDROID_HOME="${extendedPkgs.androidSdk}/libexec/android-sdk"
            export ANDROID_SDK_ROOT="$ANDROID_HOME"
            export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/25.2.9519653"
            export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
            export PATH="${extendedPkgs.rustup}/bin:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
            export JAVA_HOME="${extendedPkgs.jdk17}"
            export OPENSSL_DIR="$BASE_DIR/depend/openssl"
            export OPENSSL_LIB_DIR="$OPENSSL_DIR/android-arm64/lib"
            export AARCH64_LINUX_ANDROID_OPENSSL_LIB_DIR="$OPENSSL_DIR/android-arm64/lib"
            export OPENSSL_INCLUDE_DIR="$OPENSSL_DIR/android-arm64/include"
            export OPENSSL_STATIC=1
            export PKG_CONFIG_PATH="$BASE_DIR/gstreamer-android/arm64/lib/pkgconfig"
            echo "Build environment:"
            echo "  PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
            echo "  OPENSSL_LIB_DIR=$OPENSSL_LIB_DIR"
            echo "  ANDROID_NDK_HOME=$ANDROID_NDK_HOME"
            echo "Cleaning..."
            rm -f app/src/main/jniLibs/arm64-v8a/*.so
            rm -rf target/debug/apk/lib/arm64-v8a/* 2>/dev/null || true
            rm -rf target/release/apk/lib/arm64-v8a/* 2>/dev/null || true
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
            LIBCXX_SHARED="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/24/libc++_shared.so"
            if [ -f "$LIBCXX_SHARED" ] && [ ! -f "$JNI_LIBS/libc++_shared.so" ]; then
              echo "Copying libc++_shared.so"
              cp "$LIBCXX_SHARED" "$JNI_LIBS/"
            fi
            echo "Building APK..."
            if [ "$BUILD_MODE" = "release" ]; then
              ./gradlew clean assembleRelease
              APK_LOCATION="app/build/outputs/apk/release"
            else
              ./gradlew clean assembleDebug
              APK_LOCATION="app/build/outputs/apk/debug"
            fi
            echo "APK built successfully at: $APK_LOCATION"
            if [ "''${INSTALL_AND_RUN:-0}" = "1" ]; then
              #tes2
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
            EOF
            chmod +x "$BASE_DIR/build-apk"

            echo "Setup complete! Run '$BASE_DIR/build-apk' to build and deploy your app."
            echo "If license errors persist, run: export NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1"
          '';
          default.openFiles = [ "src/main.rs" "app/build.gradle" ];
        };

        onStart = {
          welcome = ''
            echo "AGDK eframe Android environment ready!"
            echo "Run '/home/user/rust-android-examples/build-apk' or '/root/rust-android-examples/build-apk' to build and deploy your app"
            echo "Use 'BUILD_MODE=debug /home/user/rust-android-examples/build-apk' for debug builds"
            echo "Use 'INSTALL_AND_RUN=1 /home/user/rust-android-examples/build-apk' to install and run the app"
            echo "If license errors persist, run: export NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1"
          '';
          default.openFiles = [ "src/main.rs" ];
        };
      };
    }
  ];
}
