{ pkgs, rust-overlay }:

let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" "rust-analyzer" ];
    targets = [
      "aarch64-linux-android"
      "armv7-linux-androideabi"
      "x86_64-linux-android"
      "i686-linux-android"
    ];
  };
in
{
  packages = [
    rustToolchain
    pkgs.cargo-watch
    pkgs.cargo-edit
    pkgs.cargo-outdated
  ];

  envVars = {
    RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
    RUST_BACKTRACE = "1";
  };

  inherit rustToolchain;
}
