{ pkgs }:
{
  androidSdk = pkgs.androidenv.androidPkgs.androidsdk.overrideAttrs (old: {
    # Attempt to specify NDK 25.2.9519653 if possible
    ndkVersions = [ "25.2.9519653" ];
    platformVersions = [ "33" "34" ];
    buildToolsVersions = [ "33.0.2" "34.0.0" ];
    cmakeVersions = [ "3.22.1" ];
    includeNDK = true;
    includeEmulator = false;
    includeSystemImages = false;
  });
}
