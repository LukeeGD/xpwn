#!/bin/bash

# Compile ipsw-patch

if [[ $1 == "daibutsuCFW" ]]; then
    git clone https://github.com/LukeZGD/daibutsuCFW
    cd daibutsuCFW
    git pull --no-edit
    cp ../daibutsuCFW/src/xpwn/include/pref.h ../includes
    if [[ ! -e ../ipsw-patch/main.c.bak ]]; then
        mv ../ipsw-patch/main.c ../ipsw-patch/main.c.bak
    fi
    cp ../daibutsuCFW/src/xpwn/ipsw-patch/main.c ../ipsw-patch
    cd ..
elif [[ -e ipsw-patch/main.c.bak ]]; then
    rm -f ipsw-patch/main.c
    mv ipsw-patch/main.c.bak ipsw-patch/main.c
fi

if [[ $OSTYPE == "darwin"* ]]; then
    platform="macos"
    if [[ ! -d /opt/local/lib2 ]]; then
        echo "Run ./prepare_macos.sh first"
        exit 1
    fi
    cmake=/opt/local/bin/cmake

elif [[ $OSTYPE == "linux"* ]]; then
    platform="linux"
    . /etc/os-release 2>/dev/null
    if [[ $UBUNTU_CODENAME != "focal" ]]; then
        echo "Ubuntu 20.04 only"
        exit 1
    fi
    export BEGIN_LDFLAGS="-Wl,--allow-multiple-definition"
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig
    cmake=/usr/bin/cmake

    if [[ ! -e /usr/local/lib/libbz2.a || ! -e /usr/local/lib/libz.a ]]; then
        sudo apt update
        sudo apt install -y pkg-config libtool automake g++ cmake libssl-dev libusb-1.0-0-dev libreadline-dev libpng-dev git autopoint aria2

        mkdir tmp
        cd tmp
        git clone https://github.com/madler/zlib
        aria2c https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz

        tar -zxvf bzip2-1.0.8.tar.gz
        cd bzip2-1.0.8
        make LDFLAGS="$BEGIN_LDFLAGS"
        sudo make install
        cd ..

        cd zlib
        ./configure --static
        make LDFLAGS="$BEGIN_LDFLAGS"
        sudo make install
        cd ..

        cd ..
        rm -rf tmp
    fi

elif [[ $OSTYPE == "msys" ]]; then
    platform="win"
    cmake=/usr/bin/cmake
    pacman -Sy --noconfirm --needed cmake libbz2-devel make msys2-devel openssl-devel zlib-devel

    if [[ ! -e /usr/lib/libpng.a ]]; then
        mkdir tmp
        cd tmp
        git clone https://github.com/glennrp/libpng

        cd libpng
        ./configure
        make
        make install
        cd ..

        cd ..
        rm -rf tmp
    fi

else
    echo "./compile.sh <daibutsuCFW>"
    exit 1
fi

rm -rf bin
mkdir new bin
cd new
$cmake ..
make ipsw
cp ipsw-patch/ipsw ../bin/ipsw_$platform
cd ..
rm -rf new

echo "Done! Build at bin/ipsw_$platform"
