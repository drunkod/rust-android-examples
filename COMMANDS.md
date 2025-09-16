# Development Environment Commands Reference

## Getting Started

```bash
# Enter the development shell
~/nixstatic develop --impure

# Or use standard nix
nix develop
```

## Available Shells

| Shell | Command | Description |
|-------|---------|-------------|
| Default | `nix develop` | Full environment with Rust, GStreamer, Android SDK |
| Minimal | `nix develop .#minimal` | Just Rust and basic tools |
| Android | `nix develop .#android` | Android-focused without GStreamer |

## IDE Commands

| Command | Description | Example |
|---------|-------------|---------|
| `code-dev` | Launch VS Code with proper environment | `code-dev .` |
| `code-dev <file>` | Open specific file | `code-dev src/main.rs` |
| `code-dev <folder>` | Open folder | `code-dev ~/projects` |

## Rust Development

| Command | Description | Example |
|---------|-------------|---------|
| `cargo build` | Build the project | `cargo build --release` |
| `cargo run` | Run the project | `cargo run --bin myapp` |
| `cargo test` | Run tests | `cargo test` |
| `cargo watch` | Auto-rebuild on changes | `cargo watch -x run` |
| `cargo watch -x test` | Auto-test on changes | `cargo watch -x test` |
| `cargo edit` | Add/remove dependencies | `cargo add serde` |
| `cargo outdated` | Check for outdated deps | `cargo outdated` |
| `rust-analyzer` | Language server | (used by VS Code) |

## Android Development

| Command | Description | Example |
|---------|-------------|---------|
| `adb devices` | List connected devices | `adb devices -l` |
| `adb shell` | Open device shell | `adb shell` |
| `adb install` | Install APK | `adb install app.apk` |
| `adb logcat` | View device logs | `adb logcat` |
| `adb push/pull` | Transfer files | `adb push file.txt /sdcard/` |
| `scrcpy` | Mirror device screen | `scrcpy -Sw -K` |
| `emulator` | Start Android emulator | `emulator -avd device_name` |

### Scrcpy Options

| Option | Description |
|--------|-------------|
| `-S` | Turn screen off while mirroring |
| `-w` | Stay awake (prevent sleep) |
| `-K` | Use UHID keyboard |
| `--max-fps 30` | Limit FPS |
| `--bit-rate 2M` | Set bitrate |
| `--max-size 1024` | Limit resolution |
| `-r file.mp4` | Record to file |

## GStreamer Commands

| Command | Description | Example |
|---------|-------------|---------|
| `gst-launch-1.0` | Test pipelines | `gst-launch-1.0 videotestsrc ! autovideosink` |
| `gst-inspect-1.0` | Inspect elements | `gst-inspect-1.0 videotestsrc` |
| `gst-discoverer-1.0` | Analyze media files | `gst-discoverer-1.0 video.mp4` |
| `gst-play-1.0` | Play media files | `gst-play-1.0 video.mp4` |

## Git Commands

| Command | Description | Example |
|---------|-------------|---------|
| `git status` | Check status | `git status` |
| `git add` | Stage changes | `git add .` |
| `git commit` | Commit changes | `git commit -m "message"` |
| `git push` | Push to remote | `git push origin main` |
| `git pull` | Pull from remote | `git pull origin main` |

## Development Tools

| Command | Description | Example |
|---------|-------------|---------|
| `gdb` | GNU debugger | `gdb ./target/debug/myapp` |
| `lldb` | LLVM debugger | `lldb ./target/debug/myapp` |
| `valgrind` | Memory checker | `valgrind ./target/debug/myapp` |
| `pkg-config` | Library info | `pkg-config --libs gstreamer-1.0` |

## Nix Tools

| Command | Description | Example |
|---------|-------------|---------|
| `nil` | Nix language server | (used by VS Code) |
| `nixpkgs-fmt` | Format nix files | `nixpkgs-fmt flake.nix` |
| `nix flake check` | Check flake | `nix flake check` |
| `nix flake update` | Update inputs | `nix flake update` |

## Environment Variables

Check current environment:
```bash
echo $ANDROID_SDK_ROOT
echo $JAVA_HOME
echo $RUST_SRC_PATH
echo $GST_PLUGIN_SYSTEM_PATH_1_0
```

## Quick Workflows

### Start Android Development
```bash
# Enter shell
~/nixstatic develop --impure

# Check devices
adb devices

# Start mirroring
scrcpy -Sw -K

# Open VS Code
code-dev .
```

### Build and Test Rust Project
```bash
# Enter shell
nix develop

# Build project
cargo build --release

# Run tests
cargo test

# Watch for changes
cargo watch -x "test && run"
```

### Debug with GStreamer
```bash
# Set debug level
export GST_DEBUG=3

# Test pipeline
gst-launch-1.0 videotestsrc ! autovideosink

# Inspect element
gst-inspect-1.0 videotestsrc
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| VS Code won't open | Use `code-dev .` inside nix shell |
| Device not found | Check `adb devices`, may need USB debugging |
| GStreamer plugin missing | Check `GST_PLUGIN_SYSTEM_PATH_1_0` |
| Rust target missing | Targets are pre-configured for Android |
