# .idx/modules/environment.nix
{ lib, extendedPkgs }:

{
  ANDROID_HOME = lib.mkForce "${extendedPkgs.androidSdk}/libexec/android-sdk";
  ANDROID_SDK_ROOT = lib.mkForce "${extendedPkgs.androidSdk}/libexec/android-sdk";
  ANDROID_NDK_HOME = "${extendedPkgs.androidSdk}/libexec/android-sdk/ndk/25.2.9519653";
  ANDROID_NDK_ROOT = "${extendedPkgs.androidSdk}/libexec/android-sdk/ndk/25.2.9519653";
  JAVA_HOME = "${extendedPkgs.jdk17}";
  PATH = [
    "${extendedPkgs.androidSdk}/libexec/android-sdk/cmdline-tools/latest/bin"
    "${extendedPkgs.androidSdk}/libexec/android-sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin"
    "${extendedPkgs.rustup}/bin"
  ];
  RUST_BACKTRACE = "1";
  PKG_CONFIG_ALLOW_CROSS = "1";
  RUSTFLAGS = "-lffi";
  NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE = "1";
}