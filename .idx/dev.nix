# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-25.05"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    # === Rust Toolchain ===
    pkgs.rustup
    pkgs.cargo-watch
    pkgs.cargo-edit
    pkgs.cargo-outdated

    # === Core Build Tools ===
    pkgs.gcc
    pkgs.pkg-config
    pkgs.gnumake # <-- The fix for the libffi error

    # === System Libraries ===
    pkgs.glib
    pkgs.glib.dev
    pkgs.openssl
    pkgs.openssl.dev

    # === GStreamer & Plugins ===
    pkgs.gst_all_1.gstreamer
    pkgs.gst_all_1.gstreamer.dev
    pkgs.gst_all_1.gst-plugins-base
    pkgs.gst_all_1.gst-plugins-base.dev
    pkgs.gst_all_1.gst-plugins-good
    pkgs.gst_all_1.gst-plugins-bad
    pkgs.gst_all_1.gst-plugins-ugly
    pkgs.gst_all_1.gst-libav
    pkgs.gst_all_1.gst-devtools
    pkgs.gst_all_1.gst-editing-services

    # === Additional Multimedia Libraries ===
    pkgs.libva
    pkgs.libvpx
    pkgs.x264
    pkgs.x265

    # === GUI Dependencies (for eframe) ===
    pkgs.libxkbcommon
    pkgs.libGL
    pkgs.wayland
    pkgs.xorg.libXcursor
    pkgs.xorg.libXrandr
    pkgs.xorg.libXi
    pkgs.xorg.libX11
  ];

  # Sets environment variables in the workspace
  env = {
    PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" [
      pkgs.gst_all_1.gstreamer.dev
      pkgs.gst_all_1.gst-plugins-base.dev
      pkgs.glib.dev
      pkgs.openssl.dev
    ];

    GST_PLUGIN_SYSTEM_PATH_1_0 = pkgs.lib.makeSearchPath "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);
  };
  
  idx = {
    # Workspace lifecycle hooks
    workspace = {};
  };
}