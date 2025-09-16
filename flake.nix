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
            allowUnfree = true;
          };
        };

        # Import modules
        rustModule = import ./nix/modules/rust.nix { inherit pkgs rust-overlay; };
        androidModule = import ./nix/modules/android.nix { inherit pkgs; };
        gstreamerModule = import ./nix/modules/gstreamer.nix { inherit pkgs; };
        devToolsModule = import ./nix/modules/dev-tools.nix { inherit pkgs; };

        # Combine all packages
        allPackages =
          rustModule.packages ++
          androidModule.packages ++
          gstreamerModule.packages ++
          devToolsModule.packages;

        # Combine environment variables
        allEnvVars =
          rustModule.envVars //
          androidModule.envVars //
          gstreamerModule.envVars;

        # Combined shell hook
        combinedShellHook = ''
          ${androidModule.shellHook}
          ${gstreamerModule.shellHook}
          ${devToolsModule.shellHook}
          
          # Setup library paths
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath allPackages}:$LD_LIBRARY_PATH"
          
          # Create .env file if it doesn't exist
          if [ ! -f .env ]; then
            cat > .env << EOF
# Development environment variables
RUST_LOG=debug
GST_DEBUG=3
ANDROID_SDK_ROOT=${androidModule.androidSdk}/libexec/android-sdk
ANDROID_HOME=${androidModule.androidSdk}/libexec/android-sdk
EOF
            echo "Created .env file with default settings"
          fi
          
          # Show banner only in interactive terminals (not in VS Code)
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
            echo ""
            echo "【Device Status】"
            adb devices 2>/dev/null | tail -n +2 | grep -v '^$' | while read device status; do
              if [ ! -z "$device" ]; then
                echo "  Device: $device ($status)"
              fi
            done
            if ! adb devices 2>/dev/null | tail -n +2 | grep -q device; then
              echo "  No devices connected"
            fi
            echo "================================================"
          fi
        '';

      in
      {
        devShells = {
          # Full development environment
          default = pkgs.mkShell ({
            buildInputs = allPackages;
            nativeBuildInputs = with pkgs; [ pkg-config autoPatchelfHook ];
            shellHook = combinedShellHook;
          } // allEnvVars);
          
          # Minimal Rust-only environment
          minimal = pkgs.mkShell ({
            buildInputs = rustModule.packages ++ (with pkgs; [
              gcc
              pkg-config
              openssl
              openssl.dev
              git
            ]);
            shellHook = ''
              echo "🦀 Minimal Rust Development Environment"
              echo "This shell only includes basic Rust tooling"
            '';
          } // rustModule.envVars);
          
          # Android-focused environment
          android = pkgs.mkShell ({
            buildInputs =
              rustModule.packages ++
              androidModule.packages ++
              (with pkgs; [ git vscode ]);
            shellHook = ''
              ${androidModule.shellHook}

              if [ -z "$VSCODE_PID" ]; then
                echo "📱 Android Development Environment"
                echo "================================================"
                echo "Android SDK: $ANDROID_SDK_ROOT"
                echo "Java: $JAVA_HOME"
                adb devices 2>/dev/null | tail -n +2 | grep -v '^$' || echo "No devices"
                echo "================================================"
              fi
            '';
          } // (rustModule.envVars // androidModule.envVars));
        };
      });
}