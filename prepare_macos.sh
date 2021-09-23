#!/bin/bash

# This will install needed libraries from MacPorts

port=/opt/local/bin/port
lib=/opt/local/lib

if [[ ! -e $port ]]; then
    echo "MacPorts not installed!"
    exit 1
fi

if [[ $1 == undo ]]; then
    sudo mv ${lib}2/* ${lib}
    sudo rm -rf ${lib}2
elif [[ ! -d ${lib}2 ]]; then
    sudo $port install -N zlib +universal
    sudo $port install -N openssl +universal
    sudo $port install -N bzip2 +universal
    sudo $port install -N libpng +universal
    sudo $port install -N cmake
    sudo mkdir ${lib}2
    sudo mv $lib/libbz2.dylib $lib/libcrypto.dylib $lib/libz.dylib $lib/libpng*.dylib ${lib}2
fi

echo "Done!"

echo 'To compile ipsw-patch:
  mkdir new
  cd new
  /opt/local/bin/cmake ..
  make ipsw

To undo changes:
  ./prepare_macos.sh undo'
