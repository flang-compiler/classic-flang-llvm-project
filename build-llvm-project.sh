#!/bin/bash

# Initialize our own variables:
TARGET="X86"
BUILD_TYPE="Release"
INSTALL_PREFIX="/usr/local"
NPROC=1
USE_CCACHE="0"
DO_INSTALL="0"
USE_SUDO="0"
C_COMPILER_PATH="/usr/bin/gcc"
CXX_COMPILER_PATH="/usr/bin/g++"
LLVM_ENABLE_PROJECTS="clang;openmp"
VERBOSE=""

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
    echo "  -d  Set the CMake build type. Default: Release";
    echo "  -p  Install prefix. Default: /usr/local";
    echo "  -n  Number of parallel jobs. Default: 1";
    echo "  -c  Use ccache. Default: 0 - do not use ccache";
    echo "  -i  Install the build. Default 0 - just build, do not install";
    echo "  -s  Use sudo to install. Default: 0 - do not use sudo";
    echo "  -a  C compiler path. Default: /usr/bin/gcc";
    echo "  -b  C++ compiler path. Default: /usr/bin/g++";
    echo "  -e  List of the LLVM sub-projects to build. Default: clang;openmp";
    echo "  -v  Enable verbose output";
}
while getopts "t:d:p:n:c?i?s?a:b:e:v" opt; do
    case "$opt" in
        t)  TARGET=$OPTARG;;
        d)  BUILD_TYPE=$OPTARG;;
        p)  INSTALL_PREFIX=$OPTARG;;
        n)  NPROC=$OPTARG;;
        c)  USE_CCACHE="1";;
        i)  DO_INSTALL="1";;
        s)  USE_SUDO="1";;
        a)  C_COMPILER_PATH=$OPTARG;;
        b)  CXX_COMPILER_PATH=$OPTARG;;
        e)  LLVM_ENABLE_PROJECTS=$OPTARG;;
        v)  VERBOSE="1";;
        ?) print_usage; exit 0;;
    esac
done

CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_C_COMPILER=$C_COMPILER_PATH \
    -DCMAKE_CXX_COMPILER=$CXX_COMPILER_PATH \
    -DLLVM_TARGETS_TO_BUILD=$TARGET \
    -DLLVM_ENABLE_CLASSIC_FLANG=ON \
    -DFLANG_BUILD_NEW_DRIVER=OFF"
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
if [ -n "$VERBOSE" ]; then
  set -x
fi
cmake $CMAKE_OPTIONS -DLLVM_ENABLE_PROJECTS=$LLVM_ENABLE_PROJECTS ../llvm
set +x
make -j$NPROC VERBOSE=$VERBOSE
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

