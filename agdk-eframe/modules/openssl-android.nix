{ pkgs, androidSdk }:
{
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
}
