{ pkgs }:
{
  gstreamer-android = pkgs.stdenv.mkDerivation rec {
    pname = "gstreamer-android";
    version = "1.22.12";

    src = pkgs.fetchurl {
      url = "https://gstreamer.freedesktop.org/data/pkg/android/${version}/gstreamer-1.0-android-universal-${version}.tar.xz";
      sha256 = "sha256-vpLPR30UDCcLSAvYug4mseAcjbBCxGueI02HNSES5IU=";
    };

    unpackPhase = ''
      runHook preUnpack
      tar -xf $src
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
      ln -sf $out/arm64 $out/arm64-v8a
      mkdir -p $out/gst-android-build/arm64-v8a
      ln -sf $out/arm64/lib $out/gst-android-build/arm64-v8a/lib
      if [ -d "$out/arm64/lib/pkgconfig" ]; then
        echo "GStreamer pkg-config files found:"
        ls -la $out/arm64/lib/pkgconfig/*.pc | head -5
      else
        echo "Error: GStreamer pkg-config files not found!"
        exit 1
      fi
    '';
  };
}
