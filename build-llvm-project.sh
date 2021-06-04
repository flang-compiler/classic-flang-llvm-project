#!/bin/bash

# Initialize our own variables:
TARGET="X86"
INSTALL_PREFIX="/usr/local"
NPROC=1
USE_CCACHE="0"
DO_INSTALL="0"
USE_SUDO="0"
C_COMPILER_PATH="/usr/bin/gcc"
CXX_COMPILER_PATH="/usr/bin/g++"

set -e # Exit script on first error.

function print_usage {
    echo "Usage: ./build-llvm-project.sh [options]";
    echo "";
    echo "Build and install classic-flang-llvm-project.";
    echo "Run this script in a directory with project sources.";
    echo "Example:";
    echo "  $ git clone https://github.com/flang-compiler/classic-flang-llvm-project";
    echo "  $ cd classic-flang-llvm-project";
    echo "  $ .github/workflows/build-llvm-project.sh -t X86 -p /install/prefix/ \\";
    echo "  $ -a /usr/bin/gcc-10 -b /usr/bin/g++-10 -i -s";
    echo "";
    echo "Options:";
    echo "  -t  Target to build for (X86, AArch64, PowerPC). Default: X86";
    echo "  -p  Install prefix. Default: /usr/local";
    echo "  -n  Number of parallel jobs. Default: 1";
    echo "  -c  Use ccache. Default: 0 - do not use ccache";
    echo "  -i  Install the build. Default 0 - just build, do not install";
    echo "  -s  Use sudo to install. Default: 0 - do not use sudo";
    echo "  -a  C compiler path. Default: /usr/bin/gcc";
    echo "  -b  C++ compiler path. Default: /usr/bin/g++";
}
while getopts "t:p:n:c?i?s?a:b:" opt; do
    case "$opt" in
        t)  TARGET=$OPTARG;;
        p)  INSTALL_PREFIX=$OPTARG;;
        n)  NPROC=$OPTARG;;
        c)  USE_CCACHE="1";;
        i)  DO_INSTALL="1";;
        s)  USE_SUDO="1";;
        a)  C_COMPILER_PATH=$OPTARG;;
        b)  CXX_COMPILER_PATH=$OPTARG;;
        ?) print_usage; exit 0;;
    esac
done

CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$C_COMPILER_PATH \
    -DCMAKE_CXX_COMPILER=$CXX_COMPILER_PATH \
    -DLLVM_TARGETS_TO_BUILD=$TARGET \
    -DLLVM_ENABLE_CLASSIC_FLANG=ON"
# Warning: the -DLLVM_ENABLE_PROJECTS option is specified with cmake
# to avoid issues with nested quotation marks

if [ $USE_CCACHE == "1" ]; then
  echo "Build using ccache"
  CMAKE_OPTIONS="$CMAKE_OPTIONS \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
fi

# Build and install
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DLLVM_ENABLE_PROJECTS="clang;openmp" ../llvm
make -j$NPROC
if [ $DO_INSTALL == "1" ]; then
  if [ $USE_SUDO == "1" ]; then
    echo "Install with sudo"
    sudo make install
  else
    echo "Install without sudo"
    make install
  fi
fi
cd ..

