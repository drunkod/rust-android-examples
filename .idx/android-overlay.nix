# .idx/android-overlay.nix
{ pkgs }:

self: super: {
  androidSdk =
    let
      android-nixpkgs = import (fetchTarball "https://github.com/tadfisher/android-nixpkgs/archive/main.tar.gz") { inherit pkgs; };
    in
    android-nixpkgs.sdk (sdkPkgs: with sdkPkgs; [
      cmdline-tools-latest
      build-tools-34-0-0
      build-tools-33-0-2
      platform-tools
      platforms-android-34
      platforms-android-33
      cmake-3-22-1
      ndk-25-2-9519653
    ]);
}