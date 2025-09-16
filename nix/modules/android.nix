{ pkgs }:

let
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
in
{
  packages = [
    androidSdk
    pkgs.openjdk17
    pkgs.scrcpy
    pkgs.android-tools
    pkgs.sqlite
  ];

  envVars = {
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_NDK_HOME = "${androidSdk}/libexec/android-sdk/ndk";
    JAVA_HOME = "${pkgs.openjdk17}";
  };

  shellHook = ''
    export PATH="${androidSdk}/libexec/android-sdk/emulator:${androidSdk}/libexec/android-sdk/platform-tools:$PATH"
  '';

  inherit androidSdk;
}
