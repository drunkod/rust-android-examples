{ pkgs }:

let
  helpScript = pkgs.writeShellScriptBin "dev-help" ''
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║          Development Environment Quick Reference             ║
╚══════════════════════════════════════════════════════════════╝

🚀 Quick Start:
  dev-help          - Show this help
  code-dev .        - Open VS Code
  cargo run         - Run Rust project
  scrcpy -Sw -K     - Mirror Android device

📱 Android:
  adb devices       - List devices
  adb shell         - Device shell
  scrcpy            - Screen mirror

🦀 Rust:
  cargo build       - Build project
  cargo test        - Run tests
  cargo watch       - Auto-rebuild

🎬 GStreamer:
  gst-launch-1.0    - Test pipelines
  gst-inspect-1.0   - Inspect elements

💡 Tips:
  • Use Tab for command completion
  • Check COMMANDS.md for full reference
  • Exit shell with 'exit' or Ctrl+D

Current Environment:
  Rust: $(rustc --version 2>/dev/null | cut -d' ' -f2 || echo "not available")
  Android SDK: $([ -n "$ANDROID_SDK_ROOT" ] && echo "✓ configured" || echo "✗ not set")
  Devices: $(adb devices 2>/dev/null | tail -n +2 | grep -c device || echo "0") connected

EOF
  '';
in
{
  package = helpScript;
}
