# WORK 1.22.7 WITH 21.4.7075529
export ANDROID_HOME=/home/alex/Android/Sdk
# export NDK_HOME=$ANDROID_HOME/ndk/25.2.9519653
export NDK_HOME=$ANDROID_HOME/ndk/21.4.7075529

# VERSION=1.23.0.1
VERSION=1.22.8

export PKG_CONFIG_PATH=/home/alex/Загрузки/gstreamer-1.0-android-arm64-${VERSION}/arm64/lib/pkgconfig
# export PKG_CONFIG_PATH=/nix/store/31s9l69j5n3q8kj39y75lpq2xp80vrm1-user-environment/lib/pkgconfig:/home/alex/Загрузки/gstreamer-1.0-android-arm64-${VERSION}/arm64/lib/pkgconfig

# Set the version and date
DATE=`date "+%Y%m%d-%H%M%S"`
echo $VERSION
# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/nix/store/6czxkwcga5x2raqswhxpqc47ycdr7d40-user-environment/lib/pkgconfig
# export GSTREAMER_ROOT_ANDROID=/home/alex/Загрузки/gstreamer-1.0-android-universal-${VERSION}
export GSTREAMER_ROOT_ANDROID=/home/alex/Загрузки/gstreamer-1.0-android-arm64-${VERSION}
  # removes files with names matching the pattern *pc-e* from the pkgconfig directory
  rm -rf gst-android-build
  rm -rf src

# Check if the GSTREAMER_ROOT_ANDROID environment variable is defined
if [[ -z "${GSTREAMER_ROOT_ANDROID}" ]]; then
  echo "You must define an environment variable called GSTREAMER_ROOT_ANDROID and point it to the folder where you extracted the GStreamer binaries"
  exit 1
fi

# Clean previous output and create a new output directory
# rm -rf ./out
# mkdir ./out

# Loop through different target architectures
for TARGET in arm64
do
  NDK_APPLICATION_MK="jni/${TARGET}.mk"
  echo "\n\n=== Building GStreamer ${VERSION} for target ${TARGET} with ${NDK_APPLICATION_MK} ==="

  ${NDK_HOME}/ndk-build NDK_APPLICATION_MK=$NDK_APPLICATION_MK

  if [ $TARGET = "armv7" ]; then
    LIB="armeabi-v7a"
  elif [ $TARGET = "arm64" ]; then
    LIB="arm64-v8a"
  elif [ $TARGET = "x86_64" ]; then
    LIB="x86_64"
  else
    LIB="x86"
  fi;

  # Define the output library directory for the current target
  GST_LIB='gst-android-build'

  # Copy necessary files to the output library directory

  cp -r $GSTREAMER_ROOT_ANDROID/${TARGET}/* ${GST_LIB}/${LIB}
  cp -r libs/${LIB}/libgstreamer_android.so ${GST_LIB}/${LIB}

  echo 'Processing '${GST_LIB}'/'${LIB}'/lib/pkgconfig'
  cd ${GST_LIB}/${LIB}/lib
  # sed -i -e 's?prefix=.*?prefix='${GSTREAMER_ROOT_ANDROID}'/'${TARGET}'?g' pkgconfig/*
  sed -i -e 's?libdir=.*?libdir='`pwd`'?g' pkgconfig/*
  sed -i -e 's?.* -L${.*?Libs: -L${libdir} -lgstreamer_android?g' pkgconfig/*
  sed -i -e 's?Libs:.*?Libs: -L${libdir} -lgstreamer_android?g' pkgconfig/*
  sed -i -e 's?Libs.private.*?Libs.private: -lgstreamer_android?g' pkgconfig/*
  # removes files with names matching the pattern *pc-e* from the pkgconfig directory
  rm -rf pkgconfig/*pc-e*

  cd ../../../
  # Create the output directory and copy the processed library
  mkdir -p ./out/Gstreamer-$VERSION-$DATE/lib/$LIB/
  cp -r ${GST_LIB}/${LIB}/libgstreamer_android.so  ./out/Gstreamer-$VERSION-$DATE/lib/$LIB/

  cp -r ${GST_LIB}/${LIB}/libgstreamer_android.so ${GST_LIB}/${LIB}/lib/
    cp -r ${GST_LIB}/${LIB}/gstreamer_android.c ${GST_LIB}/${LIB}/lib/
      cp -r ${GST_LIB}/${LIB}/gstreamer_android.o ${GST_LIB}/${LIB}/lib/
  # cp -r ${GST_LIB}/${LIB}/libgstreamer_for_android.so  ./out/Gstreamer-$VERSION/$TARGET/lib/

  # rm -rf ${GST_LIB}
done

rm -rf libs obj

echo "\n*** Done ***\n`ls out`"
echo "\n\nYou need to add ${PWD}/${GST_LIB}/${LIB}/lib/pkgconfig to your PKG_CONFIG_PATH.\n\n" \
"i.e. export PKG_CONFIG_PATH=${PWD}/${GST_LIB}/${LIB}/lib/pkgconfig"