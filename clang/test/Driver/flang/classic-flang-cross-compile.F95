! REQUIRES: classic_flang
! REQUIRES: host-x86_64

! Check if the cross-compiling flang1/flang2 binaries and include paths
! are used by Clang when cross-compiling.

! RUN: %clang --driver-mode=flang -target aarch64-unknown-linux-gnu %s -### 2>&1 \
! RUN:   | FileCheck %s

! RUN: %clang --driver-mode=flang -target aarch64-linux-gnu %s -### 2>&1 \
! RUN:   | FileCheck %s

! CHECK: aarch64-unknown-linux-gnu-flang1
! CHECK-SAME: include/aarch64-unknown-linux-gnu
! CHECK: aarch64-unknown-linux-gnu-flang2
