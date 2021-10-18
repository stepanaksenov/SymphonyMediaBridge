#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function pr() {
  echo -e ${GREEN}$1${NC}
}

mkdir -p ubuntu-focal/smb
pushd ubuntu-focal/smb

export CC=clang
export CXX=clang++

pr "Generating versioninfo"
../../tools/scripts/versioninfo.sh

pr "Generating make files"
../../docker/ubuntu-focal/generate_makefile.sh $1
if [ $? != 0 ]; then
    pr "Could not generate make file."; exit 1
fi

pr "Building ..."
make clean
if [ $? != 0 ]; then
    pr "Could not make clean."; exit 1
fi

make -j8
if [ $? != 0 ]; then
    pr "Could not make."; exit 1
fi

pr "Collect libs required for running"
if [ ! -d libs ]; then
  mkdir libs
fi

cp /usr/local/lib/libssl.so.1.1 libs
cp /usr/local/lib/libcrypto.so.1.1 libs
cp /usr/local/lib/libmicrohttpd.so.12 libs
cp /usr/local/lib/libopus.so.0 libs

popd
pr "Done building for Ubuntu Focal! Ready for packaging"
