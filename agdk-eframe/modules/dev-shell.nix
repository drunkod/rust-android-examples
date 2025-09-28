{ pkgs, rustToolchain, androidSdk, opensslAndroid, gstreamerAndroid, buildScript }:
{
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
      opensslAndroid
      gstreamerAndroid
      libffi
      adb-sync
      scrcpy
      buildScript
    ];

    shellHook = ''
      echo "═══════════════════════════════════════════════════════════════"
      echo "         AGDK eframe Android Development Environment"
      echo "═══════════════════════════════════════════════════════════════"
      echo "Environment:"
      echo "  ANDROID_HOME    = ${androidSdk}/libexec/android-sdk"
      echo "  ANDROID_NDK_HOME = ${androidSdk}/libexec/android-sdk/ndk/25.2.9519653"
      echo "  JAVA_HOME       = ${pkgs.jdk17}"
      echo "  PKG_CONFIG_PATH = ${gstreamerAndroid}/arm64/lib/pkgconfig"
      echo ""
      echo "Commands:"
      echo "  build-apk       - Build APK (default: release)"
      echo "  BUILD_MODE=debug build-apk - Build debug APK"
      echo "  INSTALL_AND_RUN=1 build-apk - Build, install, run"
      echo "  nix run .#install - Install APK"
      echo "  nix run .#run    - Run app"
      echo "  nix run .#logs   - Show logs"
      echo ""
      echo "Quick start:"
      echo "  1. Connect Android device (USB debugging enabled)"
      echo "  2. Run: build-apk"
      echo "═══════════════════════════════════════════════════════════════"
      export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
      export ANDROID_SDK_ROOT="$ANDROID_HOME"
      export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/25.2.9519653"
      export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
      export JAVA_HOME="${pkgs.jdk17}"
      export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
      export OPENSSL_ROOT_DIR="${opensslAndroid}"
      export OPENSSL_DIR="$OPENSSL_ROOT_DIR"
      export OPENSSL_LIB_ROOT_DIR="$OPENSSL_ROOT_DIR"
      export OPENSSL_INCLUDE_ROOT_DIR="$OPENSSL_ROOT_DIR"
      export OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/android-arm64/lib"
      export AARCH64_LINUX_ANDROID_OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/android-arm64/lib"
      export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/android-arm64/include"
      export OPENSSL_STATIC=1
      if [ -d "${gstreamerAndroid}/gst-android-build/arm64-v8a/lib/pkgconfig" ]; then
        export PKG_CONFIG_PATH="${gstreamerAndroid}/gst-android-build/arm64-v8a/lib/pkgconfig"
      else
        export PKG_CONFIG_PATH="${gstreamerAndroid}/arm64/lib/pkgconfig"
      fi
      rustup target add aarch64-linux-android 2>/dev/null || true
      if ! command -v cargo-ndk &> /dev/null; then
        echo "Installing cargo-ndk..."
        cargo install cargo-ndk
      fi
      if ! command -v cargo-apk &> /dev/null; then
        echo "Installing cargo-apk..."
        cargo install cargo-apk
      fi
      yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true
    '';
  };
}
