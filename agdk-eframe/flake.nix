{
  description = "AGDK eframe Android build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        # Android SDK/NDK configuration
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          platformVersions = [ "33" "34" ];
          buildToolsVersions = [ "33.0.2" "34.0.0" ];
          ndkVersions = [ "25.2.9519653" ];
          includeNDK = true;
          includeSystemImages = false;
          includeEmulator = false;
          cmakeVersions = [ "3.22.1" ];
        };

        androidSdk = androidComposition.androidsdk;

        # Rust toolchain with Android targets
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
          targets = [
            "aarch64-linux-android"
            "armv7-linux-androideabi"
            "x86_64-linux-android"
            "i686-linux-android"
          ];
        };

        # Build OpenSSL for Android
        openssl-android = pkgs.stdenv.mkDerivation rec {
          pname = "openssl-android";
          version = "3.0.12";

          src = pkgs.fetchurl {
            url = "https://www.openssl.org/source/openssl-${version}.tar.gz";
            sha256 = "sha256-+Tyejt3l6RZhGd4xdV/Ie0qjSGNmL2fd/LoU0La2m2E=";
          };

          nativeBuildInputs = with pkgs; [
            perl
            androidSdk
          ];

          # Fix the Configure script execution issue
          preConfigure = ''
            patchShebangs Configure
            chmod +x Configure
          '';

          configurePhase = ''
            runHook preConfigure
            
            export ANDROID_NDK_ROOT=${androidSdk}/libexec/android-sdk/ndk/25.2.9519653
            export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
            
            mkdir -p $out/android-arm64
            
            perl ./Configure android-arm64 \
              --prefix=$out/android-arm64 \
              --openssldir=$out/android-arm64 \
              -D__ANDROID_API__=24 \
              no-shared \
              no-tests
              
            runHook postConfigure
          '';

          buildPhase = ''
            make -j$NIX_BUILD_CORES
          '';

          installPhase = ''
            make install_sw
          '';
        };

        # GStreamer for Android (using prebuilt binaries)
        gstreamer-android = pkgs.stdenv.mkDerivation rec {
          pname = "gstreamer-android";
          version = "1.22.12";

          src = pkgs.fetchurl {
            url = "https://gstreamer.freedesktop.org/data/pkg/android/${version}/gstreamer-1.0-android-universal-${version}.tar.xz";
            # IMPORTANT: Replace this with the actual hash by running:
            # nix-prefetch-url https://gstreamer.freedesktop.org/data/pkg/android/1.22.12/gstreamer-1.0-android-universal-1.22.12.tar.xz
            # nix hash to-sri --type sha256 
            sha256 = "sha256-vpLPR30UDCcLSAvYug4mseAcjbBCxGueI02HNSES5IU=";
          };

          # Override unpackPhase to handle multiple directories
          unpackPhase = ''
            runHook preUnpack
            
            # Extract the tarball
            tar -xf $src
            
            # Set source root to arm64 directory
            sourceRoot=arm64
            
            if [ ! -d "$sourceRoot" ]; then
              echo "Error: arm64 directory not found in GStreamer tarball!"
              echo "Available directories:"
              ls -la
              exit 1
            fi
            
            runHook postUnpack
          '';

          installPhase = ''
            mkdir -p $out/arm64
            cp -r * $out/arm64/
            
            # Create compatibility symlink for arm64-v8a
            ln -sf $out/arm64 $out/arm64-v8a
            
            # Also create a direct gst-android-build structure to match original paths
            mkdir -p $out/gst-android-build/arm64-v8a
            ln -sf $out/arm64/lib $out/gst-android-build/arm64-v8a/lib
            
            # Verify pkg-config files exist
            if [ -d "$out/arm64/lib/pkgconfig" ]; then
              echo "GStreamer pkg-config files found:"
              ls -la $out/arm64/lib/pkgconfig/*.pc | head -5
            else
              echo "Error: GStreamer pkg-config files not found!"
              exit 1
            fi
          '';
        };

        # Build script wrapper (matching original script)
        buildScript = pkgs.writeShellScriptBin "build-apk" ''
          #!/usr/bin/env bash
          set -e

          # Define OpenSSL root directory
          OPENSSL_ROOT_DIR="${openssl-android}"

          export OPENSSL_DIR=''${OPENSSL_ROOT_DIR}
          export OPENSSL_LIB_ROOT_DIR=''${OPENSSL_ROOT_DIR}
          export OPENSSL_INCLUDE_ROOT_DIR=''${OPENSSL_ROOT_DIR}
          export OPENSSL_LIB_DIR=''${OPENSSL_ROOT_DIR}/android-arm64/lib
          export AARCH64_LINUX_ANDROID_OPENSSL_LIB_DIR=''${OPENSSL_ROOT_DIR}/android-arm64/lib
          export OPENSSL_INCLUDE_DIR=''${OPENSSL_ROOT_DIR}/android-arm64/include
          export OPENSSL_STATIC=1

          export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
          export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653

          export PATH=$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin

          # Setup GStreamer pkg-config path
          if [ -d "${gstreamer-android}/gst-android-build/arm64-v8a/lib/pkgconfig" ]; then
            export PKG_CONFIG_PATH="${gstreamer-android}/gst-android-build/arm64-v8a/lib/pkgconfig"
          else
            export PKG_CONFIG_PATH="${gstreamer-android}/arm64/lib/pkgconfig"
          fi

          export JAVA_HOME="${pkgs.jdk17}"

          # Step 1: Delete all files in the specified directory
          rm -f app/src/main/jniLibs/arm64-v8a/libmain.so

          # Step 2: Build the Rust project with the specified RUSTFLAGS
          PKG_CONFIG_ALLOW_CROSS=1 RUSTFLAGS="-lffi" RUST_BACKTRACE=1 \
            cargo ndk -t arm64-v8a -o app/src/main/jniLibs/ build

          export JNI_LIBS="app/src/main/jniLibs/arm64-v8a"
          if [ -d $JNI_LIBS ]; then
              echo "Folder exists"
          else
              mkdir -p $JNI_LIBS
              echo "Folder created"
          fi

          # Step 4: Rename libagdk_eframe.so to libmain.so
          if [ -f "$JNI_LIBS/libagdk_eframe.so" ]; then
            mv "$JNI_LIBS/libagdk_eframe.so" "$JNI_LIBS/libmain.so"
          fi

          # Copy libc++_shared.so if needed
          LIBCXX_SHARED="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so"
          if [ -f "$LIBCXX_SHARED" ] && [ ! -f "$JNI_LIBS/libc++_shared.so" ]; then
            echo "Copying libc++_shared.so"
            cp "$LIBCXX_SHARED" "$JNI_LIBS/"
          fi

          # Step 5: Run Gradle commands
          ./gradlew clean assembleDebug installDebug

          adb shell am start -n co.realfit.agdkeframe/.MainActivity
          adb logcat | egrep '(agdkeframe|gst|actix_web|tracing_actix_web|RustStdoutStderr|main    :)'
        '';

        # Development shell environment
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            cargo-ndk
            cargo-apk
            androidSdk
            jdk17
            gradle
            pkg-config
            cmake
            openssl-android
            gstreamer-android
            libffi
            adb-sync
            scrcpy
            buildScript
          ];

          shellHook = ''
            echo "═══════════════════════════════════════════════════════════════"
            echo "         AGDK eframe Android Development Environment"
            echo "═══════════════════════════════════════════════════════════════"
            echo ""
            echo "Environment variables configured:"
            echo "  ANDROID_HOME    = ${androidSdk}/libexec/android-sdk"
            echo "  ANDROID_NDK_HOME = ${androidSdk}/libexec/android-sdk/ndk/25.2.9519653"
            echo "  JAVA_HOME       = ${pkgs.jdk17}"
            echo ""
            echo "Available commands:"
            echo "  build-apk       - Build, install and run the Android APK"
            echo "  cargo ndk       - Run cargo with Android NDK"
            echo "  cargo apk       - Run cargo apk commands"
            echo "  adb             - Android Debug Bridge"
            echo "  gradle          - Gradle build tool"
            echo "  scrcpy          - Screen mirroring for Android"
            echo ""
            echo "Quick start:"
            echo "  1. Connect Android device with USB debugging enabled"
            echo "  2. Run: build-apk"
            echo "═══════════════════════════════════════════════════════════════"

            # Export environment variables
            export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
            export ANDROID_SDK_ROOT="$ANDROID_HOME"
            export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/25.2.9519653"
            export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
            export JAVA_HOME="${pkgs.jdk17}"
            export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

            # Setup OpenSSL
            export OPENSSL_ROOT_DIR="${openssl-android}"
            export OPENSSL_DIR="$OPENSSL_ROOT_DIR"
            export OPENSSL_LIB_ROOT_DIR="$OPENSSL_ROOT_DIR"
            export OPENSSL_INCLUDE_ROOT_DIR="$OPENSSL_ROOT_DIR"
            export OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/android-arm64/lib"
            export AARCH64_LINUX_ANDROID_OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/android-arm64/lib"
            export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/android-arm64/include"
            export OPENSSL_STATIC=1

            # Setup GStreamer
            if [ -d "${gstreamer-android}/gst-android-build/arm64-v8a/lib/pkgconfig" ]; then
              export PKG_CONFIG_PATH="${gstreamer-android}/gst-android-build/arm64-v8a/lib/pkgconfig"
            else
              export PKG_CONFIG_PATH="${gstreamer-android}/arm64/lib/pkgconfig"
            fi

            # Rust Android targets
            rustup target add aarch64-linux-android 2>/dev/null || true

            # Install cargo-ndk and cargo-apk if not present
            if ! command -v cargo-ndk &> /dev/null; then
              echo "Installing cargo-ndk..."
              cargo install cargo-ndk
            fi
            if ! command -v cargo-apk &> /dev/null; then
              echo "Installing cargo-apk..."
              cargo install cargo-apk
            fi

            # Accept Android licenses
            yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true
          '';
        };

        # Package derivation for building the APK
        agdk-eframe-apk = pkgs.stdenv.mkDerivation {
          pname = "agdk-eframe";
          version = "0.1.0";

          src = ./.; # Adjust if flake.nix is not in project root

          nativeBuildInputs = with pkgs; [
            rustToolchain
            cargo-ndk
            cargo-apk
            androidSdk
            jdk17
            gradle
            pkg-config
            cmake
            openssl-android
            gstreamer-android
          ];

          buildInputs = with pkgs; [
            libffi
          ];

          configurePhase = ''
            export HOME=$TMPDIR

            # Setup all environment variables
            export OPENSSL_ROOT_DIR="${openssl-android}"
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

            # Setup GStreamer pkg-config
            if [ -d "${gstreamer-android}/gst-android-build/arm64-v8a/lib/pkgconfig" ]; then
              export PKG_CONFIG_PATH="${gstreamer-android}/gst-android-build/arm64-v8a/lib/pkgconfig"
            else
              export PKG_CONFIG_PATH="${gstreamer-android}/arm64/lib/pkgconfig"
            fi

            export JAVA_HOME="${pkgs.jdk17}"

            # Setup Gradle
            export GRADLE_USER_HOME=$TMPDIR/.gradle
            mkdir -p $GRADLE_USER_HOME

            # Accept licenses
            yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true
          '';

          buildPhase = ''
            # Clean
            rm -f app/src/main/jniLibs/arm64-v8a/libmain.so

            # Build Rust library
            PKG_CONFIG_ALLOW_CROSS=1 \
            RUSTFLAGS="-lffi" \
            RUST_BACKTRACE=1 \
            cargo ndk -t arm64-v8a -o app/src/main/jniLibs/ build --release

            # Handle directory creation and renaming
            export JNI_LIBS="app/src/main/jniLibs/arm64-v8a"
            mkdir -p "$JNI_LIBS"
            
            if [ -f "$JNI_LIBS/libagdk_eframe.so" ]; then
              mv "$JNI_LIBS/libagdk_eframe.so" "$JNI_LIBS/libmain.so"
            fi

            # Copy libc++_shared.so if needed
            LIBCXX_SHARED="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so"
            if [ -f "$LIBCXX_SHARED" ]; then
              cp "$LIBCXX_SHARED" "$JNI_LIBS/"
            fi

            # Build APK
            ./gradlew clean assembleRelease
          '';

          installPhase = ''
            mkdir -p $out/apk $out/lib/arm64-v8a
            cp app/build/outputs/apk/release/*.apk $out/apk/ 2>/dev/null || \
              cp app/build/outputs/apk/debug/*.apk $out/apk/ 2>/dev/null || \
              echo "Warning: No APK files found"
            cp app/src/main/jniLibs/arm64-v8a/*.so $out/lib/arm64-v8a/ 2>/dev/null || true
          '';
        };

      in
      {
        packages = {
          default = agdk-eframe-apk;
          apk = agdk-eframe-apk;
          openssl-android = openssl-android;
          gstreamer-android = gstreamer-android;
        };

        devShells.default = devShell;

        apps = {
          default = {
            type = "app";
            program = "${buildScript}/bin/build-apk";
          };
        };
      });
}
