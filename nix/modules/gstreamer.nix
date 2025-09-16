{ pkgs }:

{
  packages = with pkgs; [
    # GStreamer and plugins
    gst_all_1.gstreamer
    gst_all_1.gstreamer.dev
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    gst_all_1.gst-devtools
    gst_all_1.gst-editing-services

    # Additional multimedia libraries
    libva
    libvpx
    x264
    x265

    # GUI dependencies for eframe
    libxkbcommon
    libGL
    wayland
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libX11
  ];

  envVars = {
    GST_DEBUG_DUMP_DOT_DIR = "./gst-dot-dumps";
  };

  shellHook = ''
    export PKG_CONFIG_PATH="${pkgs.gst_all_1.gstreamer.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
    export GST_PLUGIN_SYSTEM_PATH_1_0="${pkgs.gst_all_1.gstreamer}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0"
  '';
}
