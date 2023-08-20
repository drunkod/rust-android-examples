



```
Add gst demon 
https://developer.ridgerun.com/wiki/index.php/GStreamer_Daemon_-_Building_GStreamer_Daemon

```
sudo ./autogen.sh
mkdir build
cd build
wget https://gstreamer.freedesktop.org/data/pkg/android/1.22.5/gstreamer-1.0-android-universal-1.22.5.tar.xz
tar -xJvf gstreamer-1.0-android-universal-1.22.5.tar.xz
sudo PKG_CONFIG_PATH=/workspace/gstd-1.x/gst-build/arm64/lib/pkgconfig ../configure --host=aarch64-linux-gnu
sudo ./configure --host=aarch64-linux-gnu
sudo make
```

download ndk https://github.com/android/ndk/wiki/Unsupported-Downloads

sudo apt-get install \
automake \
libtool \
pkg-config \
libgstreamer1.0-dev \
libgstreamer-plugins-base1.0-dev \
libglib2.0-dev \
libjson-glib-dev \
gtk-doc-tools \
libncursesw5-dev \
libdaemon-dev \
libjansson-dev \
libsoup2.4-dev \
python3-pip \
libedit-dev

sudo apt-get install libdaemon-dev
create /home/alex/Документы/android/rust-android-examples/agdk-eframe/android_arm64_api28.txt
and copy gst_for_android to /workspace/gstd-1.x/ndk/android-ndk-r25c/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include
and /workspace/gstd-1.x/ndk/android-ndk-r25c/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib

meson

```
pip3 install meson
PKG_CONFIG_PATH=/workspace/gstd-1.x/gst-build/arm64/lib/pkgconfig meson setup /workspace/gstd-1.x/ndk/gst-build
ninja -C /workspace/gstd-1.x/ndk/gst-build
```
compile to arm64 jansson
```
sudo apt-get update
sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

wget https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.gz
tar -xzvf jansson-2.14.tar.gz
cd jansson-2.14
sudo CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ ./configure --host=aarch64-linux-gnu
sudo make
sudo make install DESTDIR=/workspace/gstd-1.x/ndk/test/temp_dir
sudo cp /workspace/gstd-1.x/ndk/test/temp_dir/usr/local/include/jansson_config.h /workspace/gstd-1.x/ndk/arm64/include
sudo cp /workspace/gstd-1.x/ndk/test/temp_dir/usr/local/include/jansson.h /workspace/gstd-1.x/ndk/arm64/include
sudo cp /workspace/gstd-1.x/ndk/test/temp_dir/usr/local/lib/libjansson.a /workspace/gstd-1.x/ndk/arm64/lib
sudo cp /workspace/gstd-1.x/ndk/test/temp_dir/usr/local/lib/libjansson.la /workspace/gstd-1.x/ndk/arm64/lib
sudo cp /workspace/gstd-1.x/ndk/test/temp_dir/usr/local/lib/libjansson.so /workspace/gstd-1.x/ndk/arm64/lib
sudo cp /workspace/gstd-1.x/ndk/test/temp_dir/usr/local/lib/libjansson.so.4 /workspace/gstd-1.x/ndk/arm64/lib
sudo cp /workspace/gstd-1.x/ndk/test/temp_dir/usr/local/lib/libjansson.so.4.14.0 /workspace/gstd-1.x/ndk/arm64/lib
sudo cp /workspace/gstd-1.x/ndk/test/temp_dir/usr/local/lib/pkgconfig/jansson.pc /workspace/gstd-1.x/ndk/arm64/lib/pkgconfig
sudo sed -i 's#^prefix=.*#prefix=${pcfiledir}/../..#' /workspace/gstd-1.x/ndk/arm64/lib/pkgconfig/jansson.pc

```
compile demon

```
.......

wget https://git.savannah.gnu.org/cgit/config.git/plain/config.sub -O config.sub
chmod +x config.sub
#disable SETPGRP
sed -i 's/^AC_FUNC_SETPGRP/# AC_FUNC_SETPGRP/' configure.ac
sudo autoconf
sudo CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ ./configure --host=aarch64-linux-gnu
sudo make
sudo make install DESTDIR=/workspace/gstd-1.x/ndk/test/demon_dir
sudo cp -r /workspace/gstd-1.x/ndk/test/demon_dir/usr/local/stow/libdaemon-0.14/include/libdaemon /workspace/gstd-1.x/ndk/arm64/include
sudo cp -r /workspace/gstd-1.x/ndk/test/demon_dir/usr/local/stow/libdaemon-0.14/lib/. /workspace/gstd-1.x/ndk/arm64/lib
sudo sed -i 's#^prefix=.*#prefix=${pcfiledir}/../..#' /workspace/gstd-1.x/ndk/arm64/lib/pkgconfig/libdaemon.pc

```

check undefined libs pkgconfig
```
export PKG_CONFIG_LIBDIR=/workspace/gstd-1.x/ndk/arm64/lib/pkgconfig
pkg-config --cflags --libs libedit
sudo cp /usr/lib/x86_64-linux-gnu/pkgconfig/libedit.pc /workspace/gstd-1.x/ndk/arm64/lib/pkgconfig
```

how compile libs with nix

https://matthewbauer.us/blog/beginners-guide-to-cross.html

ln -s  /home/alex/Документы/android/gstd-build/libgstd/.libs/libgstd-1.0.so /home/alex/Документы/android/media/examples/android/libgstreamer_android_gen/out/Gstreamer-1.22.5/lib/arm64-v8a/libgstd-1.0.so

