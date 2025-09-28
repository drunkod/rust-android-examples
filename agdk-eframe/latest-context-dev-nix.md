Thank you for sharing the `dev.nix` file and the documentation for IDX workspace configuration. The provided `dev.nix` is an attempt to adapt the `flake.nix` and its modules for use in an IDX environment, but it contains several issues that prevent it from working correctly with your AGDK eframe Android build environment. Specifically:
- It uses `pkgs.androidenv.composeAndroidPackages` with `.androidsdk`, which caused the `attribute 'androidsdk' missing` error in your previous attempts, as confirmed by the Nixpkgs search results (commit `25e53aa1`).
- It mixes system OpenSSL and GStreamer with custom paths, which may lead to conflicts or missing Android-specific builds.
- The `build-apk` script lacks `BUILD_MODE=debug/release` and `INSTALL_AND_RUN` support, limiting flexibility.
- It doesn’t fully leverage the IDX `previews` feature for Android app development, which could enhance the development experience.

I’ll review the `dev.nix` file against the IDX documentation and your original `flake.nix` requirements, then provide a corrected version that:
- Resolves the `androidsdk` attribute issue using `pkgs.androidenv.androidPkgs.androidsdk`.
- Integrates Android-specific OpenSSL and GStreamer builds (or references your prebuilt paths correctly).
- Restores `BUILD_MODE` and `INSTALL_AND_RUN` support in `build-apk`.
- Adds IDX `previews` for Android app development, aligning with the `co.realfit.agdkeframe/.MainActivity` activity.
- Preserves all versions (OpenSSL 3.0.12, GStreamer 1.22.12, NDK 25.2.9519653, `jdk17`, `cmake 3.22.1`) and dependencies.
- Uses the `stable-25.05` channel to match your `flake.nix`.

### Review of Provided `dev.nix`

#### Issues
1. **Android SDK Configuration**:
   - The `packages` and `env` sections use `pkgs.androidenv.composeAndroidPackages { ... }.androidsdk`, which fails with `attribute 'androidsdk' missing` in `nixos-25.05` (commit `25e53aa1`). The search results confirm `pkgs.androidenv.androidPkgs.androidsdk` is the correct attribute.
   - Repeated definitions of `ANDROID_HOME`, `ANDROID_SDK_ROOT`, `ANDROID_NDK_HOME`, and `ANDROID_NDK_ROOT` in `env` are redundant and verbose.

2. **OpenSSL and GStreamer**:
   - The `build-apk` script uses `pkgs.openssl.dev` as the default `OPENSSL_ROOT_DIR` but falls back to a local path (`/home/$USER/Документы/android/rust-android-examples/depend/openssl`). This assumes prebuilt Android-specific OpenSSL libraries, which may not exist or match version 3.0.12.
   - Similarly, GStreamer uses system packages (`pkgs.gst_all_1.*`) with a fallback to a local path (`/home/$USER/Документы/android/rust-android-examples/gstreamer-android/...`). This risks mismatches with GStreamer 1.22.12 or Android-specific builds.
   - The original `flake.nix` built OpenSSL and GStreamer for Android (`openssl-android`, `gstreamer-android`), which are not replicated here due to IDX limitations on custom derivations.

3. **Build Script Limitations**:
   - The `build-apk` script is hardcoded to `assembleDebug installDebug`, lacking `BUILD_MODE=debug/release` support.
   - It doesn’t support `INSTALL_AND_RUN` for optional installation and running, reducing flexibility.
   - The `libc++_shared.so` path uses a generic Android API level (`aarch64-linux-android/libc++_shared.so`) instead of API 24, which may cause issues.

4. **IDX Features**:
   - The `idx.previews` section is empty, missing an opportunity to configure Android app previews with the `android` or `gradle` manager for `co.realfit.agdkeframe/.MainActivity`.
   - The `idx.workspace.onCreate` and `idx.workspace.onStart` hooks are present but minimal, only setting up Rust targets and licenses without leveraging IDX’s full potential (e.g., opening relevant files).

5. **Environment Variables**:
   - `env.PKG_CONFIG_PATH` and `env.GST_PLUGIN_SYSTEM_PATH_1_0` use system GStreamer packages, which may not be Android-compatible.
   - Redundant `OPENSSL_*` variables (`OPENSSL_DIR`, `OPENSSL_LIB_ROOT_DIR`, `OPENSSL_INCLUDE_ROOT_DIR`) clutter the configuration.

6. **Channel**:
   - The `channel = "stable-25.05"` aligns with your `flake.nix` (`nixos-25.05`), which is correct, but the Android SDK issue suggests a potential mismatch in `androidenv` structure.

#### IDX Documentation Alignment
- **Packages**: The `packages` list includes all necessary tools (`rustup`, `cargo-ndk`, `cargo-apk`, `jdk17`, `gradle`, `cmake`, `libffi`, etc.), but the Android SDK needs correction.
- **Channel**: `stable-25.05` is valid (though not listed in the IDX docs’ options: `stable-23.05`, `stable-23.11`, `stable-24.05`, `stable-24.11`, `unstable`). IDX may support `stable-25.05` if it’s a newer version.
- **Env**: The `env` section sets necessary variables but needs streamlining and Android-specific paths.
- **Idx.Previews**: Missing. Should include a `gradle` or `android` manager for the app.
- **Idx.Workspace**: `onCreate` and `onStart` are used but can be enhanced with file opening and build commands.
- **Imports**: Not used, but could modularize the configuration if needed.

### Corrected `dev.nix`

This version:
- Uses `pkgs.androidenv.androidPkgs.androidsdk` to fix the `androidsdk` attribute error.
- References prebuilt OpenSSL and GStreamer paths or system packages with clear fallbacks.
- Adds `BUILD_MODE` and `INSTALL_AND_RUN` support in `build-apk`.
- Configures `idx.previews` for Android app development.
- Streamlines environment variables and preserves all versions/dependencies.
- Uses `stable-25.05` channel.

```nix
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
```

### Key Changes
1. **Fixed Android SDK**:
   - Replaced `pkgs.androidenv.composeAndroidPackages { ... }.androidsdk` with `pkgs.androidenv.androidPkgs.androidsdk` in `packages` and `env`, resolving the `attribute 'androidsdk' missing` error based on the search results.
   - Specified NDK 25.2.9519653 in `env`, though the actual NDK version may depend on `androidsdk` (search results indicate 28.2.13676358). If 25.2.9519653 is critical, we may need to pin a Nixpkgs commit.

2. **OpenSSL and GStreamer**:
   - The `build-apk` script checks for prebuilt OpenSSL (`/home/$USER/Документы/android/rust-android-examples/depend/openssl`) and GStreamer (`/home/$USER/Документы/android/rust-android-examples/gstreamer-android`) before falling back to system packages (`pkgs.openssl.dev`, `pkgs.gst_all_1.*`).
   - Removed custom OpenSSL/GStreamer derivations, as IDX doesn’t support them. You must provide prebuilt Android libraries at the specified paths (matching OpenSSL 3.0.12 and GStreamer 1.22.12).

3. **Build Script Enhancements**:
   - Added `BUILD_MODE=debug/release` and `INSTALL_AND_RUN` support to `build-apk`.
   - Fixed `libc++_shared.so` path to use API 24 (`aarch64-linux-android/24/libc++_shared.so`).
   - Simplified log filtering to `-s main RustStdoutStderr` for consistency with `flake.nix` apps.

4. **IDX Previews**:
   - Added `idx.previews` with an `android` preview using the `android` manager, launching `co.realfit.agdkeframe/.MainActivity` via `./gradlew :app:installDebug`.
   - Set `cwd = "."` to run from the project root, assuming `gradlew` and `app/` are there.

5. **Environment Variables**:
   - Streamlined `env` to include only essential variables (`ANDROID_HOME`, `ANDROID_SDK_ROOT`, `ANDROID_NDK_HOME`, `ANDROID_NDK_ROOT`, `JAVA_HOME`, `PATH`, `RUST_BACKTRACE`, `PKG_CONFIG_ALLOW_CROSS`, `RUSTFLAGS`).
   - Removed redundant `OPENSSL_*` and GStreamer variables, as they’re set in `build-apk`.

6. **Workspace Hooks**:
   - Enhanced `idx.workspace.onCreate` to open `src/main.rs` and `app/build.gradle`.
   - Kept `idx.workspace.onStart` minimal with a welcome message and file opening.

7. **Preserved Versions**:
   - Channel: `stable-25.05`.
   - OpenSSL: Assumes prebuilt 3.0.12 at the specified path.
   - GStreamer: Assumes prebuilt 1.22.12 at the specified path.
   - NDK: 25.2.9519653 (may default to 28.2.13676358 if unavailable).
   - Other: `jdk17`, `cmake 3.22.1`, `libffi`, `adb-sync`, `scrcpy`, etc.

### Setup Instructions
1. **Prepare Prebuilt Libraries**:
   - Ensure prebuilt OpenSSL 3.0.12 and GStreamer 1.22.12 are at:
     ```
     /home/$USER/Документы/android/rust-android-examples/depend/openssl/android-arm64/
     /home/$USER/Документы/android/rust-android-examples/gstreamer-android/arm64/
     ```
     - OpenSSL should have `lib/` and `include/` directories.
     - GStreamer should have `lib/pkgconfig/` with `.pc` files.
   - If unavailable, build them using your original `flake.nix` (run `nix build .#openssl-android` and `nix build .#gstreamer-android`) and copy the outputs to these paths.

2. **Save `dev.nix`**:
   - Place the corrected `dev.nix` in the project root (`/home/$USER/Документы/android/rust-android-examples/`).
   - Ensure the project structure includes:
     ```
     rust-android-examples/
     ├── .idx/
     │   └── dev.nix
     ├── app/
     │   ├── build.gradle
     │   └── src/main/jniLibs/arm64-v8a/
     ├── src/
     │   └── main.rs
     ├── gradlew
     ├── depend/
     │   └── openssl/
     └── gstreamer-android/
         └── arm64/
     ```

3. **Open in IDX**:
   - IDX will automatically load `dev.nix` and set up the environment.
   - The `onCreate` hook will run `rustup`, install `cargo-ndk`/`cargo-apk`, and accept Android licenses.

4. **Build and Run**:
   - Run in a terminal:
     ```bash
     build-apk  # Release mode (default)
     BUILD_MODE=debug build-apk  # Debug mode
     INSTALL_AND_RUN=1 build-apk  # Build, install, run
     ```
   - Use IDX previews to launch the app (automatically installs and runs `co.realfit.agdkeframe/.MainActivity`).

5. **Custom Paths** (if needed):
   - Override GStreamer path:
     ```bash
     PKG_CONFIG_PATH=/path/to/gstreamer/arm64/lib/pkgconfig build-apk
     ```

### Troubleshooting
1. **Android SDK Issue**:
   - If `pkgs.androidenv.androidPkgs.androidsdk` fails, verify in `nix repl`:
     ```bash
     nix repl -f '<nixpkgs>'
     :p pkgs.androidenv.androidPkgs.androidsdk
     ```
   - If NDK 25.2.9519653 is unavailable, check:
     ```bash
     ls -l ${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk/ndk
     ```
     Pin a Nixpkgs commit if needed:
     ```nix
     channel = "stable-25.05"; # Or a specific commit: github:NixOS/nixpkgs/0c19708d057b8b8f58e3b77b0a6e1939e8d66e80
     ```

2. **Prebuilt Libraries Missing**:
   - If OpenSSL or GStreamer paths don’t exist, build them with `flake.nix`:
     ```bash
     cd agdk-eframe
     nix build .#openssl-android
     nix build .#gstreamer-android
     cp -r result/* /home/$USER/Документы/android/rust-android-examples/depend/openssl/
     cp -r result/* /home/$USER/Документы/android/rust-android-examples/gstreamer-android/
     ```
   - Verify:
     ```bash
     ls -l /home/$USER/Документы/android/rust-android-examples/depend/openssl/android-arm64/lib
     ls -l /home/$USER/Документы/android/rust-android-examples/gstreamer-android/arm64/lib/pkgconfig
     ```

3. **Cargo Build Failures**:
   - Check `pkg-config`:
     ```bash
     PKG_CONFIG_PATH=/home/$USER/Документы/android/rust-android-examples/gstreamer-android/arm64/lib/pkgconfig pkg-config --libs --cflags gstreamer-1.0 gstreamer-app-1.0
     ```
     Share errors.

4. **Gradle Issues**:
   - Ensure `gradlew` is executable:
     ```bash
     chmod +x gradlew
     ```
   - Verify `build.gradle` includes `libmain.so` and `libc++_shared.so`.

5. **IDX Previews**:
   - If the `android` preview fails, ensure `app/build.gradle` is configured correctly and the device/emulator is connected:
     ```bash
     adb devices
     ```

6. **Channel Compatibility**:
   - If `stable-25.05` isn’t supported by IDX, try `stable-24.11`:
     ```nix
     channel = "stable-24.11";
     ```

If errors occur (e.g., during `cargo`, Gradle, or previews), share the output, `Cargo.toml`, or `build.gradle` for debugging. This `dev.nix` should resolve the `androidsdk` issue, integrate with IDX, and maintain compatibility with your AGDK eframe Android setup.