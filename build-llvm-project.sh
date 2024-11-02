#!/bin/bash

# Initialize our own variables:
TARGET="X86"
BUILD_TYPE="Release"
INSTALL_PREFIX="/usr/local"
CROSS_TARGETS=""
NPROC=1
USE_CCACHE="0"
DO_INSTALL="0"
USE_SUDO="0"
C_COMPILER_PATH="/usr/bin/gcc"
CXX_COMPILER_PATH="/usr/bin/g++"
LLVM_EXTRA_PROJECTS=""
EXTRA_CMAKE_OPTS=""
VERBOSE=""

set -e # Exit script on first error.

function print_usage {
    echo "Usage: ./build-llvm-project.sh [options]";
    echo "";
    echo "Build and install classic-flang-llvm-project (including clang, lld, and openmp).";
    echo "Run this script in a directory with project sources.";
    echo "Example:";
    echo "  $ git clone https://github.com/flang-compiler/classic-flang-llvm-project";
    echo "  $ cd classic-flang-llvm-project";
    echo "  $ ./build-llvm-project.sh -t X86 -p /opt/classic-flang/ -i -s";
    echo "";
    echo "Options:";
    echo "  -t  Target to build for (X86, AArch64, PowerPC). Default: X86";
    echo "  -d  Set the CMake build type. Default: Release";
    echo "  -p  Install prefix. Default: /usr/local";
    echo "  -X  Cross-compile OpenMP for given list of target triples. Default: none";
    echo "  -n  Number of parallel jobs. Default: 1";
    echo "  -c  Use ccache. Default: 0 - do not use ccache";
    echo "  -i  Install the build. Default 0 - just build, do not install";
    echo "  -s  Use sudo to install. Default: 0 - do not use sudo";
    echo "  -a  C compiler path. Default: /usr/bin/gcc";
    echo "  -b  C++ compiler path. Default: /usr/bin/g++";
    echo "  -e  List of additional LLVM sub-projects to build. Default: none";
    echo "  -x  Extra CMake options. Default: ''";
    echo "  -v  Enable verbose output";
}

while getopts "t:d:p:X:n:cisa:b:e:x:v?" opt; do
    case "$opt" in
        t) TARGET=$OPTARG;;
        d) BUILD_TYPE=$OPTARG;;
        p) INSTALL_PREFIX=$OPTARG;;
        X) CROSS_TARGETS=$OPTARG;;
        n) NPROC=$OPTARG;;
        c) USE_CCACHE="1";;
        i) DO_INSTALL="1";;
        s) USE_SUDO="1";;
        a) C_COMPILER_PATH=$OPTARG;;
        b) CXX_COMPILER_PATH=$OPTARG;;
        e) LLVM_EXTRA_PROJECTS=$OPTARG;;
        x) EXTRA_CMAKE_OPTS="$OPTARG";;
        v) VERBOSE="1";;
        ?) print_usage; exit 0;;
    esac
done

CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE"

if [ $USE_CCACHE == "1" ]; then
  echo "Build using ccache"
  CMAKE_OPTIONS="$CMAKE_OPTIONS \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
fi

# Build and install.
mkdir -p build && cd build
if [ -n "$VERBOSE" ]; then
  set -x
fi
cmake $CMAKE_OPTIONS \
    -DCMAKE_C_COMPILER=$C_COMPILER_PATH \
    -DCMAKE_CXX_COMPILER=$CXX_COMPILER_PATH \
    -DLLVM_ENABLE_CLASSIC_FLANG=ON \
    -DLLVM_ENABLE_PROJECTS="clang;lld;openmp;$LLVM_EXTRA_PROJECTS" \
    -DLLVM_TARGETS_TO_BUILD="$TARGET" \
    $EXTRA_CMAKE_OPTS \
    ../llvm
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

# Cross-compile OpenMP libraries if requested.
IFS=';' read -ra CROSS_TARGET_LIST <<< "$CROSS_TARGETS"
for T in ${CROSS_TARGET_LIST[@]}; do
  mkdir -p "build/openmp-$T"
  pushd "build/openmp-$T"
  CMAKE_OPTIONS="$CMAKE_OPTIONS \
      -DCMAKE_AR=$INSTALL_PREFIX/bin/llvm-ar \
      -DCMAKE_ASM_COMPILER=$INSTALL_PREFIX/bin/clang \
      -DCMAKE_ASM_COMPILER_TARGET=$T \
      -DCMAKE_C_COMPILER=$INSTALL_PREFIX/bin/clang \
      -DCMAKE_C_COMPILER_TARGET=$T \
      -DCMAKE_CXX_COMPILER=$INSTALL_PREFIX/bin/clang++ \
      -DCMAKE_CXX_COMPILER_TARGET=$T \
      -DCMAKE_RANLIB=$INSTALL_PREFIX/bin/llvm-ranlib \
      -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld"
  if [ -n "$VERBOSE" ]; then
    set -x
  fi
  cmake $CMAKE_OPTIONS \
      -DLLVM_DEFAULT_TARGET_TRIPLE=$T \
      -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
      -DLLVM_ENABLE_RUNTIMES="openmp" \
      -DLIBOMP_OMPT_SUPPORT=OFF \
      -DOPENMP_ENABLE_LIBOMPTARGET=OFF \
      -DOPENMP_ENABLE_OMPT_TOOLS=OFF \
      -DOPENMP_LLVM_TOOLS_DIR=$PWD/../bin \
      $EXTRA_CMAKE_OPTS \
      ../../runtimes
  set +x
  make -j$NPROC VERBOSE=$VERBOSE
  if [ $DO_INSTALL -eq 1 ]; then
    if [ $USE_SUDO -eq 1 ]; then
      echo "Install with sudo"
      sudo make install
    else
      echo "Install without sudo"
      make install
    fi
  fi
  popd
done
