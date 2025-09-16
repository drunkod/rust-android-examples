{
  description = "Development environment for agdk-eframe (Rust + GStreamer + eframe)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true; # Required for vscode and Android SDK
          };
        };

        # Define the Rust toolchain
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
          targets = [ 
            "aarch64-linux-android" 
            "armv7-linux-androideabi" 
            "x86_64-linux-android" 
            "i686-linux-android"
          ];
        };

        # Android SDK composition
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          toolsVersion = "26.1.1";
          platformToolsVersion = "36.0.1";
          buildToolsVersions = [ "34.0.0" "33.0.2" ];
          includeEmulator = true;
          emulatorVersion = "36.2.4";
          platformVersions = [ "29" "30" "31" "32" "33" "34" "35" ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          cmakeVersions = [ "4.1.0" ];
          includeNDK = true;
          ndkVersions = [ "25.1.8937393" ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
        };

        androidSdk = androidComposition.androidsdk;

        buildInputs = with pkgs; [
          # Shell and completions
          bashInteractive
          bash-completion
          
          # Rust toolchain
          rustToolchain
          cargo-watch
          cargo-edit
          cargo-outdated
          
          # Build tools
          gcc
          pkg-config
          cmake
          
          # Version control and IDE
          git
          vscode
          
          # Android development
          androidSdk
          openjdk17
          scrcpy
          android-tools
          sqlite
          python3
          nodejs
          jq
          
          # GLib and GTK dependencies
          glib
          glib.dev
          
          # OpenSSL
          openssl
          openssl.dev
          
          # GStreamer and plugins
          gst_all_1.gstreamer
          gst_all_1.gstreamer.dev
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-ugly
          gst_all_1.gst-libav
          gst_all_1.gst-devtools
          gst_all_1.gst-editing-services
          
          # Additional multimedia libraries often needed with GStreamer
          libva
          libvpx
          x264
          x265
          
          # GUI dependencies for eframe
          libxkbcommon
          libGL
          wayland
          xorg.libXcursor
          xorg.libXrandr
          xorg.libXi
          xorg.libX11
          
          # Development tools
          gdb
          valgrind
          lldb
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config
          autoPatchelfHook
        ];

        # Environment variables for the development shell
        shellHook = ''
          # Source bash completion if available
          if [ -f ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh ]; then
            source ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh
          fi
          
          # Only show banner in interactive terminals (not in VS Code)
          if [ -t 1 ] && [[ $- == *i* ]] && [ -z "$VSCODE_PID" ]; then
            echo "🦀 Rust + GStreamer + Android Development Environment"
            echo "================================================"
            echo "Rust version: $(rustc --version)"
            echo "Cargo version: $(cargo --version)"
            echo "GStreamer version: $(gst-launch-1.0 --version | head -n 1)"
            echo ""
            echo "【Android SDK】"
            echo "  SDK: $ANDROID_SDK_ROOT"
            echo "  Java: $JAVA_HOME"
            echo "  NDK: Available in SDK"
            echo ""
            echo "【Available tools】"
            echo "  cargo build              - Build the project"
            echo "  cargo run                - Run the project"
            echo "  cargo watch -x run       - Auto-rebuild on changes"
            echo "  gst-launch-1.0          - Test GStreamer pipelines"
            echo "  gst-inspect-1.0         - Inspect GStreamer elements"
            echo "  code .                  - Open VS Code in current directory"
            echo "  scrcpy                  - Mirror Android device screen"
            echo "  adb devices             - List connected Android devices"
            echo "  emulator                - Android emulator"
            echo ""
            
            # Check for connected Android devices
            if command -v adb &> /dev/null; then
              echo "【Device Status】"
              adb devices 2>/dev/null | tail -n +2 | grep -v '^$' | while read device status; do
                if [ ! -z "$device" ]; then
                  echo "  Device: $device ($status)"
                fi
              done
              if ! adb devices 2>/dev/null | tail -n +2 | grep -q device; then
                echo "  No devices connected"
              fi
              echo ""
            fi
            
            echo "================================================"
          fi
          
          # Export Android paths
          export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
          export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
          export PATH="${androidSdk}/libexec/android-sdk/emulator:${androidSdk}/libexec/android-sdk/platform-tools:$PATH"
          
          # Set up pkg-config paths
          export PKG_CONFIG_PATH="${pkgs.glib.dev}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.gst_all_1.gstreamer.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
          
          # Set up GStreamer plugin paths
          export GST_PLUGIN_SYSTEM_PATH_1_0="${pkgs.gst_all_1.gstreamer}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0"
          
          # Set up library paths
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
          
          # Library path for SQLite and other Android SDK libs
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.sqlite ]}:$LD_LIBRARY_PATH"
          
          # For Wayland support
          # export WAYLAND_DISPLAY=wayland-1
          # export XDG_RUNTIME_DIR=/tmp
          
          # Rust backtrace for better error messages
          export RUST_BACKTRACE=1
          
          # Android NDK 
          export ANDROID_NDK_HOME="${androidSdk}/libexec/android-sdk/ndk"
          
          # Create a .env file template if it doesn't exist
          if [ ! -f .env ]; then
            cat > .env << EOF
# Development environment variables
RUST_LOG=debug
GST_DEBUG=3
ANDROID_SDK_ROOT=${androidSdk}/libexec/android-sdk
ANDROID_HOME=${androidSdk}/libexec/android-sdk
EOF
            echo "Created .env file with default settings"
          fi
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;
          
          # Android environment variables
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          JAVA_HOME = "${pkgs.openjdk17}";
          
          # Rust and GStreamer environment variables
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          GST_DEBUG_DUMP_DOT_DIR = "./gst-dot-dumps";
          
          inherit shellHook;
        };

        # Optional: Define a minimal shell without all the multimedia deps
        devShells.minimal = pkgs.mkShell {
          buildInputs = with pkgs; [
            bashInteractive
            rustToolchain
            gcc
            pkg-config
            openssl
            openssl.dev
            git
          ];
          
          shellHook = ''
            echo "🦀 Minimal Rust Development Environment"
            echo "This shell only includes basic Rust tooling without GStreamer and Android SDK"
          '';
        };

        # Android-focused development shell
        devShells.android = pkgs.mkShell {
          buildInputs = with pkgs; [
            bashInteractive
            bash-completion
            rustToolchain
            androidSdk
            openjdk17
            scrcpy
            android-tools
            sqlite
            git
            vscode
          ];
          
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          JAVA_HOME = "${pkgs.openjdk17}";
          
          shellHook = ''
            # Source bash completion
            if [ -f ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh ]; then
              source ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh
            fi
            
            if [ -z "$VSCODE_PID" ]; then
              echo "📱 Android Development Environment"
              echo "================================================"
              echo "Android SDK: $ANDROID_SDK_ROOT"
              echo "Java: $JAVA_HOME"
              echo ""
            fi
            
            export PATH="${androidSdk}/libexec/android-sdk/emulator:${androidSdk}/libexec/android-sdk/platform-tools:$PATH"
            
            # Check for connected devices only if not in VS Code
            if [ -z "$VSCODE_PID" ] && command -v adb &> /dev/null; then
              echo "Connected devices:"
              adb devices 2>/dev/null | tail -n +2 | grep -v '^$' || echo "  No devices"
              echo "================================================"
            fi
          '';
        };
      });
}