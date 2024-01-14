good wiki gstreamer

https://www.francescpinyol.cat/gstreamer.html

test gsreamer students
https://github.com/smartcomputerlab/M1-Internet-Multimedia-with-RK3588/tree/main

// Set the GStreamer debug level before initializing GStreamer
env::set_var("GST_DEBUG", "3"); // Levels are 0-5; 3 is a good starting point

For example:

std::env::set_var("GST_DEBUG", "souphttpsrc:6");

This will set the debug level to 6 (LOG) only for the souphttpsrc element.