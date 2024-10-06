Additional tips
Make sure that the -lunwind and -l:libunwind.a libraries are present in the NDK's sources/cxx-stl/llvm-libc++/libs/arm64-v8a directory.

Try rebuilding the NDK using the following command:




ndk-build NDK_APPLICATION_MK=path/to/Application.mk
If you are still getting the error, you can try to manually link the -lunwind and -l:libunwind.a libraries to your project. You can do this by adding the following lines to your Application.mk file:




APP_STL := c++_static
APP_CPPFLAGS += -I${NDK_HOME}/sources/cxx-stl/llvm-libc++/include
APP_LDFLAGS += -L${NDK_HOME}/sources/cxx-stl/llvm-libc++/libs/arm64-v8a -lunwind
Once you have made these changes, try rebuilding your project again.