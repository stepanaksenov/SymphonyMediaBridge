#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function pr() {
  echo -e ${GREEN}$1${NC}
}

mkdir -p el7/smb
pushd el7/smb

#source scl_source enable devtoolset-7
source scl_source enable llvm-toolset-7

export CC=/opt/rh/llvm-toolset-7/root/usr/bin/clang
export CXX=/opt/rh/llvm-toolset-7/root/usr/bin/clang++

pr "Generating versioninfo"
../../tools/scripts/versioninfo.sh

pr "Generating make files"
../../docker/el7/generate_makefile.sh $1
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

cp /usr/local/lib/libc++.so.1 libs
cp /usr/local/lib/libc++abi.so.1 libs
cp /usr/local/lib64/libssl.so.1.1 libs
cp /usr/local/lib64/libcrypto.so.1.1 libs
cp /usr/local/lib/libmicrohttpd.so.12 libs
cp /usr/local/lib/libopus.so.0 libs

popd
pr "Done building for CentOS7! Ready for packaging"
