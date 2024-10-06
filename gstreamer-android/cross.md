
## Croscompile with nix pack 
https://nixos.wiki/wiki/Cross_Compiling

`
curl -L https://nixos.org/nix/install | sh
`
Create a file crossShell.nix as follows:

with import <nixpkgs> {
  crossSystem = {
    config = "aarch64-unknown-linux-gnu";
  };
};

mkShell {
  buildInputs = [ faac ]; # your dependencies here
}

run 
nix-shell crossShell.nix


find / -name 'faac.pc'

## Copy .so to build/dist/android_universal/arm64/lib :


 cp -r /usr/src/dir/59vds6bq4mf2g6s82ig73cqlngs5y7sx-faac-aarch64-linux-1.30/lib/libfaac.la /vendor/cerbero/build/dist/android_universal/arm64/lib

 cp -r /usr/src/dir/59vds6bq4mf2g6s82ig73cqlngs5y7sx-faac-aarch64-linux-1.30/lib/libfaac.so /vendor/cerbero/build/dist/android_universal/arm64/lib

 cp -r /usr/src/dir/59vds6bq4mf2g6s82ig73cqlngs5y7sx-faac-aarch64-linux-1.30/lib/libfaac.so.0 /vendor/cerbero/build/dist/android_universal/arm64/lib

cp -r /usr/src/dir/59vds6bq4mf2g6s82ig73cqlngs5y7sx-faac-aarch64-linux-1.30/lib/libfaac.so.0.0.0 /vendor/cerbero/build/dist/android_universal/arm64/lib

cp -r /usr/src/dir/59vds6bq4mf2g6s82ig73cqlngs5y7sx-faac-aarch64-linux-1.30/include/ /vendor/cerbero/build/dist/android_universal/arm64

## Cross config/cross-android-universal.cbc

cd /vendor/cerbero && ./cerbero-uninstalled -c config/cross-android-universal.cbc package gstreamer-1.0

cp -r /vendor/cerbero/gstreamer-1.0-android-universal-1.22.5-runtime.tar.xz  /usr/src