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

    # Java/JDK
    pkgs.jdk17
    pkgs.gradle

    # Core Build Tools
    pkgs.gcc
    pkgs.pkg-config
    pkgs.gnumake
    pkgs.cmake
    pkgs.perl

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
  ];

  # Environment variables
  env = {
    JAVA_HOME = "${pkgs.jdk17}";
    RUST_BACKTRACE = "1";
    PKG_CONFIG_ALLOW_CROSS = "1";
    RUSTFLAGS = "-lffi";
  };

  idx = {
    previews = {
      enable = true;
      previews = {
        android = {
          command = [ "echo" "Android SDK not included. Please install manually or enable androidenv in dev.nix." ];
          cwd = ".";
          manager = "android";
          activity = "co.realfit.agdkeframe/.MainActivity";
          env = {
            JAVA_HOME = "${pkgs.jdk17}";
          };
        };
      };
    };

    workspace = {
      onCreate = {
        setup = ''
          echo "Setting up minimal AGDK eframe environment for testing (Android SDK excluded)..."

          # Fix permissions for /home/user/rust-android-examples
          if [ ! -w "/home/user/rust-android-examples" ]; then
            echo "Fixing permissions for /home/user/rust-android-examples..."
            sudo chown -R $(whoami) /home/user/rust-android-examples 2>/dev/null || true
          fi

          # Setup Rust targets
          rustup target add aarch64-linux-android

          # Install cargo tools
          which cargo-ndk > /dev/null || cargo install cargo-ndk
          which cargo-apk > /dev/null || cargo install cargo-apk

          # Setup OpenSSL
          OPENSSL_DEST="/home/user/rust-android-examples/depend/openssl"
          if [ ! -d "$OPENSSL_DEST/android-arm64" ]; then
            echo "Setting up prebuilt OpenSSL 3.0.12..."
            mkdir -p "$OPENSSL_DEST"
            curl -L https://www.openssl.org/source/openssl-3.0.12.tar.gz -o /tmp/openssl.tar.gz
            tar -xzf /tmp/openssl.tar.gz -C /tmp
            cd /tmp/openssl-3.0.12
            # Note: Android NDK not available, building for host (for testing only)
            ./Configure linux-x86_64 --prefix="$OPENSSL_DEST/android-arm64" no-shared no-tests
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
          GSTREAMER_DEST="/home/user/rust-android-examples/gstreamer-android"
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

          # Create build-apk script (simplified for testing)
          cat > /home/user/rust-android-examples/build-apk << 'EOF'
          #!/usr/bin/env bash
          set -e
          export JAVA_HOME="${pkgs.jdk17}"
          export OPENSSL_DIR="/home/user/rust-android-examples/depend/openssl"
          export OPENSSL_LIB_DIR="$OPENSSL_DIR/android-arm64/lib"
          export OPENSSL_INCLUDE_DIR="$OPENSSL_DIR/android-arm64/include"
          export OPENSSL_STATIC=1
          export PKG_CONFIG_PATH="/home/user/rust-android-examples/gstreamer-android/arm64/lib/pkgconfig"
          echo "Build environment:"
          echo "  PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
          echo "  OPENSSL_LIB_DIR=$OPENSSL_LIB_DIR"
          echo "Note: Android SDK/NDK not included in this environment."
          echo "To build the Android app, install the Android SDK and set:"
          echo "  export ANDROID_HOME=/path/to/android-sdk"
          echo "  export ANDROID_NDK_HOME=/path/to/android-sdk/ndk/25.2.9519653"
          echo "Then run:"
          echo "  cargo ndk -t arm64-v8a -o app/src/main/jniLibs/ build --release"
          echo "  ./gradlew clean assembleRelease"
          echo "For debug builds, use: BUILD_MODE=debug ./build-apk"
          echo "To install and run, use: INSTALL_AND_RUN=1 ./build-apk"
          if [ "''${INSTALL_AND_RUN:-0}" = "1" ]; then
            echo "Error: Cannot install/run without Android SDK. Please set ANDROID_HOME."
            exit 1
          fi
          EOF
          chmod +x /home/user/rust-android-examples/build-apk

          echo "Setup complete! Run './build-apk' to check the environment."
          echo "Note: Android SDK/NDK not included. Install manually for full build."
        '';
        default.openFiles = [ "src/main.rs" "app/build.gradle" ];
      };

      onStart = {
        welcome = ''
          echo "Minimal AGDK eframe environment ready (Android SDK excluded)!"
          echo "Run './build-apk' to check the environment"
          echo "Android SDK/NDK not included. Install manually and set ANDROID_HOME."
        '';
        default.openFiles = [ "src/main.rs" ];
      };
    };
  };
}