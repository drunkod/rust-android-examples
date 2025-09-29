# .idx/modules/workspace.nix
{ extendedPkgs }:

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

        # Import the setup scripts
        ${import ./scripts/setup-openssl.nix { inherit extendedPkgs; }}
        ${import ./scripts/setup-gstreamer.nix { inherit extendedPkgs; }}
        ${import ./scripts/create-build-script.nix { inherit extendedPkgs; }}

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