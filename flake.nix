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
        environmentRaw = import ./.idx/modules/environment.nix {
          inherit extendedPkgs;
          lib = pkgs.lib;
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

        # Create setup script with better error handling and path detection
        setupScript = pkgs.writeShellScriptBin "setup-android-env" ''
                    #!/usr/bin/env bash
                    set -e

                    echo "Setting up AGDK eframe Android environment..."

                    # Determine base directory
                    BASE_DIR="$(pwd)"
                    PROJECT_DIR="$BASE_DIR/agdk-eframe"
          
                    mkdir -p "$PROJECT_DIR"
          
                    # Detect Android SDK path from environment
                    ANDROID_SDK_PATH="$ANDROID_HOME"
                    if [ -z "$ANDROID_SDK_PATH" ]; then
                      if [ -d "${extendedPkgs.androidSdk}/share/android-sdk" ]; then
                        ANDROID_SDK_PATH="${extendedPkgs.androidSdk}/share/android-sdk"
                      else
                        ANDROID_SDK_PATH="${extendedPkgs.androidSdk}/libexec/android-sdk"
                      fi
                    fi
          
                    echo "Android SDK detected at: $ANDROID_SDK_PATH"
          
                    # Setup Rust - First set default toolchain
                    export PATH="${extendedPkgs.rustup}/bin:$PATH"
                    echo "Setting up Rust toolchain..."
                    rustup default stable || {
                      echo "Installing stable Rust toolchain..."
                      rustup install stable
                      rustup default stable
                    }
          
                    # Add Android targets
                    echo "Adding Android targets..."
                    rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android

                    # Install cargo tools
                    echo "Installing cargo tools..."
                    which cargo-ndk > /dev/null 2>&1 || {
                      echo "Installing cargo-ndk..."
                      cargo install cargo-ndk
                    }
                    which cargo-apk > /dev/null 2>&1 || {
                      echo "Installing cargo-apk..."
                      cargo install cargo-apk
                    }

                    # Accept Android licenses
                    echo "Accepting Android licenses..."
                    yes | $ANDROID_SDK_PATH/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true

                    # Setup OpenSSL with correct NDK path
                    OPENSSL_DEST="$PROJECT_DIR/depend/openssl"
                    if [ ! -d "$OPENSSL_DEST/android-arm64" ]; then
                      echo "Setting up OpenSSL 3.0.12..."
                      mkdir -p "$OPENSSL_DEST"
            
                      # Try downloading from GitHub (more reliable)
                      OPENSSL_URL="https://github.com/openssl/openssl/archive/refs/tags/openssl-3.0.12.tar.gz"
            
                      echo "Downloading OpenSSL from GitHub..."
                      DOWNLOAD_SUCCESS=0
                      for attempt in 1 2 3; do
                        echo "Download attempt $attempt/3..."
                        if curl -L --connect-timeout 30 --max-time 300 "$OPENSSL_URL" -o /tmp/openssl.tar.gz; then
                          DOWNLOAD_SUCCESS=1
                          break
                        fi
                        sleep 2
                      done
            
                      if [ "$DOWNLOAD_SUCCESS" -eq 1 ] && [ -f /tmp/openssl.tar.gz ]; then
                        tar -xzf /tmp/openssl.tar.gz -C /tmp
              
                        # GitHub archive has different directory name
                        cd /tmp/openssl-openssl-3.0.12 2>/dev/null || cd /tmp/openssl-3.0.12
              
                        export ANDROID_NDK_ROOT="$ANDROID_SDK_PATH/ndk/25.2.9519653"
                        echo "Using NDK at: $ANDROID_NDK_ROOT"
              
                        # Verify NDK exists
                        if [ ! -d "$ANDROID_NDK_ROOT" ]; then
                          echo "Error: NDK not found at $ANDROID_NDK_ROOT"
                          echo "Available NDK versions:"
                          ls -la "$ANDROID_SDK_PATH/ndk/" 2>/dev/null || echo "No NDK directory found"
                          exit 1
                        fi
              
                        ./Configure android-arm64 --prefix="$OPENSSL_DEST/android-arm64" -D__ANDROID_API__=24 no-shared no-tests
                        make -j$(nproc)
                        make install_sw
                        cd "$BASE_DIR"
                        rm -rf /tmp/openssl* 2>/dev/null || true
                        echo "OpenSSL setup complete!"
                      else
                        echo "WARNING: Could not download OpenSSL."
                        echo "Creating placeholder directory to continue..."
                        mkdir -p "$OPENSSL_DEST/android-arm64/lib"
                        mkdir -p "$OPENSSL_DEST/android-arm64/include"
                      fi
                    else
                      echo "OpenSSL already set up at $OPENSSL_DEST"
                    fi

                    # Setup GStreamer
                    GSTREAMER_DEST="$PROJECT_DIR/gstreamer-android"
                    if [ ! -d "$GSTREAMER_DEST/arm64/lib/pkgconfig" ]; then
                      echo "Setting up GStreamer 1.22.12..."
                      mkdir -p "$GSTREAMER_DEST"
            
                      GSTREAMER_URL="https://gstreamer.freedesktop.org/data/pkg/android/1.22.12/gstreamer-1.0-android-universal-1.22.12.tar.xz"
            
                      echo "Downloading GStreamer (this may take a while)..."
                      DOWNLOAD_SUCCESS=0
                      for attempt in 1 2 3; do
                        echo "Download attempt $attempt/3..."
                        if curl -L --connect-timeout 30 --max-time 600 "$GSTREAMER_URL" -o /tmp/gstreamer.tar.xz; then
                          DOWNLOAD_SUCCESS=1
                          break
                        fi
                        sleep 2
                      done
            
                      if [ "$DOWNLOAD_SUCCESS" -eq 1 ] && [ -f /tmp/gstreamer.tar.xz ]; then
                        tar -xf /tmp/gstreamer.tar.xz -C "$GSTREAMER_DEST"
                        rm -rf /tmp/gstreamer.tar.xz
                        echo "GStreamer setup complete!"
                      else
                        echo "WARNING: Could not download GStreamer."
                        echo "Creating placeholder directory to continue..."
                        mkdir -p "$GSTREAMER_DEST/arm64/lib/pkgconfig"
                      fi
                    else
                      echo "GStreamer already set up at $GSTREAMER_DEST"
                    fi

                    # Create build script with environment detection
                    echo "Creating build script at: $PROJECT_DIR/build-apk"
                    cat > "$PROJECT_DIR/build-apk" << 'EOFSCRIPT'
          #!/usr/bin/env bash
          set -e

          # Get script directory
          SCRIPT_DIR="$( cd "$( dirname "''${BASH_SOURCE[0]}" )" && pwd )"
          PROJECT_DIR="$SCRIPT_DIR"

          echo "Building in: $PROJECT_DIR"
          cd "$PROJECT_DIR"

          # Check if running in Nix shell
          if [ -z "$ANDROID_HOME" ] || [ -z "$ANDROID_SDK_ROOT" ]; then
            echo "Error: Android SDK environment variables not set."
            echo "Please run this script from within the Nix development shell:"
            echo "  nix develop"
            echo "  ./build-apk"
            exit 1
          fi

          # Verify required tools are available
          command -v rustup >/dev/null 2>&1 || { echo "Error: rustup not found. Please run from Nix shell."; exit 1; }
          command -v cargo >/dev/null 2>&1 || { echo "Error: cargo not found. Please run from Nix shell."; exit 1; }
          command -v gradle >/dev/null 2>&1 || { echo "Error: gradle not found. Please run from Nix shell."; exit 1; }

          # Export all necessary environment variables
          export NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1

          # Use project-local dependencies
          export OPENSSL_DIR="$PROJECT_DIR/depend/openssl"
          export OPENSSL_LIB_DIR="$OPENSSL_DIR/android-arm64/lib"
          export AARCH64_LINUX_ANDROID_OPENSSL_LIB_DIR="$OPENSSL_DIR/android-arm64/lib"
          export OPENSSL_INCLUDE_DIR="$OPENSSL_DIR/android-arm64/include"
          export OPENSSL_STATIC=1
          export PKG_CONFIG_PATH="$PROJECT_DIR/gstreamer-android/arm64/lib/pkgconfig"

          echo "Build environment:"
          echo "  PROJECT_DIR=$PROJECT_DIR"
          echo "  ANDROID_HOME=$ANDROID_HOME"
          echo "  ANDROID_NDK_HOME=$ANDROID_NDK_HOME"
          echo "  JAVA_HOME=$JAVA_HOME"
          echo "  Rust version: $(rustc --version)"

          # Clean previous builds
          echo "Cleaning previous builds..."
          rm -f app/src/main/jniLibs/arm64-v8a/*.so
          rm -rf target/debug/apk/lib/arm64-v8a/* 2>/dev/null || true
          rm -rf target/release/apk/lib/arm64-v8a/* 2>/dev/null || true

          # Determine build mode
          BUILD_MODE="''${BUILD_MODE:-release}"
          BUILD_FLAG=""
          TARGET_DIR="release"

          if [ "$BUILD_MODE" = "debug" ]; then
            BUILD_FLAG=""
            TARGET_DIR="debug"
            echo "Building in DEBUG mode..."
          else
            BUILD_FLAG="--release"
            echo "Building in RELEASE mode..."
          fi

          # Ensure we have the Android target
          echo "Checking Rust Android targets..."
          rustup target list --installed | grep -q aarch64-linux-android || {
            echo "Installing aarch64-linux-android target..."
            rustup target add aarch64-linux-android
          }

          # Build Rust library for Android
          echo "Building Rust library for Android..."
          PKG_CONFIG_ALLOW_CROSS=1 \
          RUSTFLAGS="-lffi" \
          RUST_BACKTRACE=1 \
          cargo ndk -t arm64-v8a -o app/src/main/jniLibs/ build $BUILD_FLAG

          # Handle library naming
          JNI_LIBS="app/src/main/jniLibs/arm64-v8a"
          mkdir -p "$JNI_LIBS"

          # Rename library if needed
          if [ -f "$JNI_LIBS/libagdk_eframe.so" ]; then
            echo "Renaming libagdk_eframe.so to libmain.so..."
            mv "$JNI_LIBS/libagdk_eframe.so" "$JNI_LIBS/libmain.so"
          elif [ ! -f "$JNI_LIBS/libmain.so" ]; then
            echo "Warning: Neither libagdk_eframe.so nor libmain.so found in $JNI_LIBS"
            echo "Available libraries:"
            ls -la "$JNI_LIBS"
          fi

          # Copy libc++_shared.so if needed
          LIBCXX_SHARED="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/24/libc++_shared.so"
          if [ -f "$LIBCXX_SHARED" ] && [ ! -f "$JNI_LIBS/libc++_shared.so" ]; then
            echo "Copying libc++_shared.so..."
            cp "$LIBCXX_SHARED" "$JNI_LIBS/"
          fi

          # Build APK
          echo "Building Android APK..."
          if [ "$BUILD_MODE" = "release" ]; then
            ./gradlew clean assembleRelease
            APK_LOCATION="app/build/outputs/apk/release"
          else
            ./gradlew clean assembleDebug
            APK_LOCATION="app/build/outputs/apk/debug"
          fi

          # Check if APK was built successfully
          if [ -d "$APK_LOCATION" ]; then
            echo ""
            echo "✅ APK built successfully!"
            echo "APK location: $APK_LOCATION"
            echo "Available APKs:"
            ls -lh "$APK_LOCATION"/*.apk 2>/dev/null || echo "No APK files found"
          else
            echo "❌ Error: APK directory not found at $APK_LOCATION"
            exit 1
          fi

          # Optional: Install and run
          if [ "''${INSTALL_AND_RUN:-0}" = "1" ]; then
            echo ""
            echo "Installing APK to device..."
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

          echo ""
          echo "Done! To install and run:"
          echo "  INSTALL_AND_RUN=1 ./build-apk"
          EOFSCRIPT
                    chmod +x "$PROJECT_DIR/build-apk"
          
                    # Create convenience symlink in base directory
                    if [ -w "$BASE_DIR" ]; then
                      ln -sf "$PROJECT_DIR/build-apk" "$BASE_DIR/build-agdk-eframe" 2>/dev/null || true
                    fi

                    echo ""
                    echo "✅ Setup complete!"
                    echo ""
                    echo "Next steps:"
                    echo "  1. cd agdk-eframe"
                    echo "  2. ./build-apk"
                    echo ""
                    echo "Build options:"
                    echo "  BUILD_MODE=debug ./build-apk    # Debug build"
                    echo "  INSTALL_AND_RUN=1 ./build-apk   # Install and run on device"
        '';

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
            buildInputs = packages ++ [ setupScript buildScript ];

            shellHook = ''
              ${envVars}
              
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
            ];

            shellHook = ''
              echo "═══════════════════════════════════════════"
              echo "  Minimal Rust Development Environment"
              echo "═══════════════════════════════════════════"
              export PATH="${pkgs.rustup}/bin:$PATH"
              rustup default stable 2>/dev/null || rustup install stable
              echo "Rust version: $(rustc --version)"
            '';
          };

          # Android-focused shell
          android = pkgs.mkShell {
            buildInputs = packages ++ [ buildScript setupScript ];

            shellHook = ''
              ${envVars}
              
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
