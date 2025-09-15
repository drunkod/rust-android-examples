{
  description = "Development environment for agdk-eframe (Rust + GStreamer + eframe)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

        # Android NDK (optional, uncomment if needed)
        # androidNdk = pkgs.androidenv.androidPkgs_9_0.ndk-bundle;

        buildInputs = with pkgs; [
          # Rust toolchain
          rustToolchain
          cargo-watch
          cargo-edit
          cargo-outdated
          
          # Build tools
          gcc
          pkg-config
          cmake
          
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
          echo "🦀 Rust + GStreamer Development Environment"
          echo "================================================"
          echo "Rust version: $(rustc --version)"
          echo "Cargo version: $(cargo --version)"
          echo "GStreamer version: $(gst-launch-1.0 --version | head -n 1)"
          echo ""
          echo "Useful commands:"
          echo "  cargo build              - Build the project"
          echo "  cargo run                - Run the project"
          echo "  cargo watch -x run       - Auto-rebuild on changes"
          echo "  gst-launch-1.0          - Test GStreamer pipelines"
          echo "  gst-inspect-1.0         - Inspect GStreamer elements"
          echo "================================================"
          
          # Set up pkg-config paths
          export PKG_CONFIG_PATH="${pkgs.glib.dev}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.gst_all_1.gstreamer.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
          
          # Set up GStreamer plugin paths
          export GST_PLUGIN_SYSTEM_PATH_1_0="${pkgs.gst_all_1.gstreamer}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0"
          
          # Set up library paths
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
          
          # For Wayland support
          export WAYLAND_DISPLAY=wayland-1
          export XDG_RUNTIME_DIR=/tmp
          
          # Rust backtrace for better error messages
          export RUST_BACKTRACE=1
          
          # Android NDK (uncomment if using Android development)
          # export ANDROID_NDK_HOME="/path/to/your/ndk"
          
          # Create a .env file template if it doesn't exist
          if [ ! -f .env ]; then
            cat > .env << EOF
# Development environment variables
RUST_LOG=debug
GST_DEBUG=3
EOF
            echo "Created .env file with default settings"
          fi
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs shellHook;
          
          # Additional environment variables
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          GST_DEBUG_DUMP_DOT_DIR = "./gst-dot-dumps";
        };

        # Optional: Define a minimal shell without all the multimedia deps
        devShells.minimal = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            gcc
            pkg-config
            openssl
            openssl.dev
          ];
          
          shellHook = ''
            echo "🦀 Minimal Rust Development Environment"
            echo "This shell only includes basic Rust tooling without GStreamer"
          '';
        };
      });
}
