#!/usr/bin/env bash

### check architecture:

# uname -m returns arm64 or x86_64
# but let's change x86_64 into x64 for convinience
ARCH=`uname -m`
if [[ $ARCH == "x86_64" ]]
then
    ARCH="x64"
fi

function debug_echo {
    echo "------------------------------------------------------------------"
    echo "[debug] $1"
    echo "------------------------------------------------------------------"
}

debug_echo "architecture is $ARCH"

### check dependencies:

function check_dep {
    command -v $1 &> /dev/null || (debug_echo "Install $1 first, now exiting.." && exit 101)
}

# cmake and ninja
check_dep cmake
check_dep ninja

# skia
check_dep curl
mkdir -p buildroot/skia
cd buildroot
curl -O -L "https://github.com/aseprite/skia/releases/latest/download/Skia-macOS-Release-$ARCH.zip"
unzip -d ./skia Skia-macOS-Release-$ARCH.zip

### check source:

# latest release url
check_dep jq
curl -s https://api.github.com/repos/aseprite/aseprite/releases/latest -o latest.json
FILE_NAME=`jq -r ".assets[0].name" latest.json`
BASE_URL="https://github.com/aseprite/aseprite/releases/latest/download"
URL=$BASE_URL/$FILE_NAME

# download, extract
curl -O -L $URL
unzip -d aseprite $FILE_NAME

### build:

mkdir -p aseprite/build
cd aseprite/build

if
    [ "$ARCH" = "arm64" ]
then
    cmake \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DCMAKE_OSX_ARCHITECTURES=arm64 \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
        -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
        -DLAF_BACKEND=skia \
        -DSKIA_DIR="../../skia" \
        -DSKIA_LIBRARY_DIR="../../skia/out/Release-arm64" \
        -DSKIA_LIBRARY="../../skia/out/Release-arm64/libskia.a" \
        -DPNG_ARM_NEON:STRING=on \
        -G Ninja \
        ..
else
    cmake \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DCMAKE_OSX_ARCHITECTURES=x86_64 \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
        -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
        -DLAF_BACKEND=skia \
        -DSKIA_DIR="../../skia" \
        -DSKIA_LIBRARY_DIR="../../skia/out/Release-x64" \
        -DSKIA_LIBRARY="../../skia/out/Release-x64/libskia.a" \
        -G Ninja \
        ..
fi

# https://github.com/aseprite/aseprite/issues/3257
# turn it off for now??
sed -i "" 's/ENABLE_LIBB2:BOOL=ON/ENABLE_LIBB2:BOOL=OFF/g' ./CMakeCache.txt

ninja aseprite

# make an .app
cp -r ../../../Aseprite.app.template ./Aseprite.app
cp bin/aseprite Aseprite.app/Contents/MacOS/
cp -r bin/data Aseprite.app/Contents/Resources

VERSION=`jq -r ".tag_name" ../../latest.json | sed 's/^v//'`
sed -i "" "s/1.2.34.1/$VERSION/" Aseprite.app/Contents/Info.plist

### publish:

xattr -r -d com.apple.quarantine ./Aseprite.app
cp -r ./Aseprite.app /Applications/
