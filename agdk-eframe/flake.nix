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
        # Configure nixpkgs with overlays
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        # Import modules
        androidSdkModule = import ./modules/android-sdk.nix { inherit pkgs; };
        rustToolchainModule = import ./modules/rust-toolchain.nix { inherit pkgs; };
        opensslAndroidModule = import ./modules/openssl-android.nix {
          inherit pkgs;
          androidSdk = androidSdkModule.androidSdk;
        };
        gstreamerAndroidModule = import ./modules/gstreamer-android.nix { inherit pkgs; };
        buildScriptModule = import ./modules/build-script.nix {
          inherit pkgs;
          androidSdk = androidSdkModule.androidSdk;
          opensslAndroid = opensslAndroidModule.openssl-android;
          gstreamerAndroid = gstreamerAndroidModule.gstreamer-android;
        };
        devShellModule = import ./modules/dev-shell.nix {
          inherit pkgs;
          rustToolchain = rustToolchainModule.rustToolchain;
          androidSdk = androidSdkModule.androidSdk;
          opensslAndroid = opensslAndroidModule.openssl-android;
          gstreamerAndroid = gstreamerAndroidModule.gstreamer-android;
          buildScript = buildScriptModule.buildScript;
        };
        apkModule = import ./modules/apk.nix {
          inherit pkgs;
          rustToolchain = rustToolchainModule.rustToolchain;
          androidSdk = androidSdkModule.androidSdk;
          opensslAndroid = opensslAndroidModule.openssl-android;
          gstreamerAndroid = gstreamerAndroidModule.gstreamer-android;
        };

      in
      {
        packages = {
          default = apkModule.agdk-eframe-apk;
          apk = apkModule.agdk-eframe-apk;
          openssl-android = opensslAndroidModule.openssl-android;
          gstreamer-android = gstreamerAndroidModule.gstreamer-android;
        };

        devShells.default = devShellModule.devShell;

        apps = {
          default = {
            type = "app";
            program = "${buildScriptModule.buildScript}/bin/build-apk";
          };
          install = {
            type = "app";
            program = toString (pkgs.writeShellScript "install-apk" ''
              adb install app/build/outputs/apk/*/app-*.apk
            '');
          };
          run = {
            type = "app";
            program = toString (pkgs.writeShellScript "run-app" ''
              adb shell am start -n co.realfit.agdkeframe/.MainActivity
            '');
          };
          logs = {
            type = "app";
            program = toString (pkgs.writeShellScript "show-logs" ''
              adb logcat -s main RustStdoutStderr
            '');
          };
        };
      });
}
