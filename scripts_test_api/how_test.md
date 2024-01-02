# How to test api


1. Run app in debug mode

`
/home/alex/Документы/android/rust-android-examples/agdk-eframe/build_and_copy.sh
`

2. Test api

`
curl -X POST -H "Content-Type: application/json" -d '{"getinfo":{}}' http://192.168.3.40:8080/command
`

`
python scripts_test_api/crossfade.py source_uri, dest_uri

`

## How debug in android studio

How do I debug Rust code with the step-debugger in Android Studio

Uncomment the packagingOptions { doNotStrip "**/*.so" } line from the build.gradle file of the component you want to debug.

In the rust code, either:
Cause something to crash where you want the breakpoint. Note: Panics don't work here, unfortunately. (I have not found a convenient way to set a breakpoint to rust code, so unsafe { std::ptr::write_volatile(0 as *const _, 1u8) } usually is what I do).

If you manage to get an LLDB prompt, you can set a breakpoint using breakpoint set --name foo, or breakpoint set --file foo.rs --line 123. I don't know how to bring up this prompt reliably, so I often do step 1 to get it to appear, delete the crashing code, and then set the breakpoint using the CLI. This is admittedly suboptimal.

Click the Debug button in Android Studio, to display the "Select Deployment Target" window.

Make sure the debugger selection is set to "Both". This tends to unset itself, so make sure.

Click "Run", and debug away.
