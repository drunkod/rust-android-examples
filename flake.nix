# flake.nix
{
  description = "AGDK eframe Android development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import overlays from .idx
        androidOverlay = import ./.idx/overlays/android.nix {
          pkgs = import nixpkgs { inherit system; };
        };

        # Apply overlays to create extended pkgs
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ androidOverlay ];
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        # Use the extended pkgs (with overlays applied)
        extendedPkgs = pkgs;

        # Import modules from .idx
        packages = import ./.idx/modules/packages.nix { inherit extendedPkgs; };
        devTools = import ./.idx/modules/dev-tools.nix { pkgs = extendedPkgs; };
        environmentRaw = import ./.idx/modules/environment.nix {
          inherit extendedPkgs;
          lib = pkgs.lib;
        };

        # Import setup module
        setupModule = import ./.idx/modules/setup-android.nix {
          inherit pkgs extendedPkgs;
        };
        # Extract actual values from lib.mkForce wrappers
        environment = pkgs.lib.mapAttrs
          (name: value:
            if value ? _type && value._type == "override" then
              value.content
            else
              value
          )
          environmentRaw;

        # Use setup script from module
        setupScript = setupModule.package;

        # Build script that can be used directly from anywhere
        buildScript = pkgs.writeShellScriptBin "build-apk" ''
          #!/usr/bin/env bash
          set -e
          
          # Auto-detect project directory
          if [ -f "Cargo.toml" ]; then
            PROJECT_DIR="$(pwd)"
          elif [ -f "agdk-eframe/Cargo.toml" ]; then
            PROJECT_DIR="$(pwd)/agdk-eframe"
          else
            echo "Error: Cannot find project directory with Cargo.toml"
            exit 1
          fi
          
          echo "Building in: $PROJECT_DIR"
          cd "$PROJECT_DIR"
          
          # Run the project's build script
          if [ -f "./build-apk" ]; then
            ./build-apk "$@"
          else
            echo "Error: build-apk script not found. Run setup-android-env first."
            exit 1
          fi
        '';

        # Convert environment variables for shell
        envVars = builtins.concatStringsSep "\n" (
          pkgs.lib.mapAttrsToList
            (name: value:
              if builtins.isList value then
                "export ${name}=\"${builtins.concatStringsSep ":" value}:\$${name}\""
              else
                "export ${name}=\"${toString value}\""
            )
            environment
        );

      in
      {
        # Development shells
        devShells = {
          # Default shell with everything
          default = pkgs.mkShell {
            buildInputs = packages
              ++ devTools.packages
              ++ [ setupScript buildScript ];

            shellHook = ''
              ${envVars}

              # Dev tools shell hook (includes VS Code setup)
              ${devTools.shellHook} 
             
              # Setup Rust default toolchain immediately
              export PATH="${extendedPkgs.rustup}/bin:$PATH"
              if ! rustup default 2>/dev/null | grep -q stable; then
                echo "Setting up Rust stable toolchain..."
                rustup install stable 2>/dev/null || true
                rustup default stable 2>/dev/null || true
              fi
              
              echo "╔══════════════════════════════════════════════════════════╗"
              echo "║     AGDK eframe Android Development Environment         ║"
              echo "╚══════════════════════════════════════════════════════════╝"
              echo ""
              echo "Environment:"
              echo "  • Android SDK: $ANDROID_HOME"
              echo "  • Android NDK: $ANDROID_NDK_HOME"
              echo "  • Java Home:   $JAVA_HOME"
              echo "  • Rust:        $(rustc --version 2>/dev/null || echo 'Not configured')"
              echo ""
              echo "Available commands:"
              echo "  • setup-android-env  - Initial setup (run once)"
              echo "  • build-apk         - Build the APK"
              echo "  • code-dev          - Launch VS Code with Nix support"
              echo "  • dev-help          - Show full command reference"
              echo "  • scrcpy -Sw -K     - Mirror Android device screen"
              echo "  • cargo watch       - Auto-rebuild on changes"
              echo ""
              echo "Build options:"
              echo "  • BUILD_MODE=debug build-apk    - Debug build"
              echo "  • BUILD_MODE=release build-apk  - Release build (default)"
              echo "  • INSTALL_AND_RUN=1 build-apk   - Build, install and run"
              echo ""
              echo "Project directory: ./agdk-eframe"
              echo ""
              
              # Check for proxy settings
              if [ -n "''${https_proxy:-}" ] || [ -n "''${HTTPS_PROXY:-}" ]; then
                echo "Note: Proxy detected. Downloads will use proxy settings."
              fi
              
              # Auto-setup if not already done
              if [ -d "agdk-eframe" ]; then
                if [ ! -f "agdk-eframe/build-apk" ]; then
                  echo "Running initial setup..."
                  setup-android-env
                else
                  echo "Setup already complete. Ready to build!"
                fi
              else
                echo "Note: agdk-eframe directory not found."
                echo "Run 'setup-android-env' when ready to set up the project."
              fi
            '';
          };

          # Minimal shell without auto-setup
          minimal = pkgs.mkShell {
            buildInputs = with pkgs; [
              rustup
              cargo-watch
              git
              jdk17
              gradle
            ] ++ devTools.packages; # Include dev tools here too

            shellHook = ''
              echo "═══════════════════════════════════════════"
              echo "  Minimal Rust Development Environment"
              echo "═══════════════════════════════════════════"
              export PATH="${pkgs.rustup}/bin:$PATH"
              rustup default stable 2>/dev/null || rustup install stable
              echo "Rust version: $(rustc --version)"
              echo ""
              echo "Type 'dev-help' for available commands"
            '';
          };

          # Android-focused shell
          android = pkgs.mkShell {
            buildInputs = packages
              ++ devTools.packages  # Include dev tools
              ++ [ buildScript setupScript ];

            shellHook = ''
              ${envVars}

              ${devTools.shellHook}              
              export PATH="${extendedPkgs.rustup}/bin:$PATH"
              
              echo "═══════════════════════════════════════════"
              echo "  📱 Android Development Environment"
              echo "═══════════════════════════════════════════"
              echo ""
              echo "Android SDK: $ANDROID_SDK_ROOT"
              echo "Android NDK: $ANDROID_NDK_HOME"
              echo "Java:        $JAVA_HOME"
              echo ""
              echo "Commands:"
              echo "  • setup-android-env - Setup project"
              echo "  • build-apk        - Build Android app"
              echo "  • adb devices      - List devices"
              echo "  • adb logcat       - View device logs"
              echo "  • scrcpy -Sw -K    - Mirror device screen"
              echo "  • code-dev         - Open VS Code"
              echo "  • dev-help         - Full command reference"
              echo ""
              
              # Check for connected devices
              if command -v adb >/dev/null 2>&1; then
                DEVICES=$(adb devices 2>/dev/null | tail -n +2 | grep -v "^$" | wc -l)
                if [ "$DEVICES" -gt 0 ]; then
                  echo "Connected devices:"
                  adb devices | tail -n +2 | grep -v "^$" | sed 's/^/  • /'
                else
                  echo "No Android devices connected"
                fi
              fi
            '';
          };

          # Developer-focused shell with emphasis on tools
          developer = pkgs.mkShell {
            buildInputs = devTools.packages ++ [ setupScript buildScript ];

            shellHook = ''
              ${devTools.shellHook}
              
              echo "╔══════════════════════════════════════════════════════════╗"
              echo "║           Developer Tools Environment                    ║"
              echo "╚══════════════════════════════════════════════════════════╝"
              echo ""
              echo "IDE & Editors:"
              echo "  • code-dev         - VS Code with Nix integration"
              echo ""
              echo "Debugging Tools:"
              echo "  • gdb              - GNU debugger"
              echo "  • valgrind         - Memory debugging"
              echo "  • lldb             - LLVM debugger"
              echo ""
              echo "Android Tools:"
              echo "  • adb              - Android Debug Bridge"
              echo "  • scrcpy           - Screen mirroring"
              echo ""
              echo "Development Utilities:"
              echo "  • cargo watch      - Auto-rebuild Rust projects"
              echo "  • jq               - JSON processor"
              echo "  • nixpkgs-fmt      - Nix code formatter"
              echo ""
              echo "Type 'dev-help' for quick reference"
              echo ""
            '';
          };
        };

        # Packages that can be built
        packages = {
          inherit setupScript buildScript;

          # You can also expose the androidSdk if needed
          androidSdk = extendedPkgs.androidSdk;

          # Default package
          default = setupScript;
        };

        # Apps that can be run directly
        apps = {
          setup = {
            type = "app";
            program = "${setupScript}/bin/setup-android-env";
          };

          build = {
            type = "app";
            program = "${buildScript}/bin/build-apk";
          };

          # Default app
          default = {
            type = "app";
            program = "${setupScript}/bin/setup-android-env";
          };
        };
      });
}
