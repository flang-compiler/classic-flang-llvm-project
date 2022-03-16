! REQUIRES: classic_flang
! REQUIRES: system-linux

! Check that the driver invokes flang1 correctly for preprocessed fixed-form
! Fortran code.

! RUN: %clang --driver-mode=flang -E -target x86_64-unknown-linux-gnu -c - </dev/null -### 2>&1 \
! RUN:   | FileCheck %s
! CHECK: "{{.*}}flang1"
! CHECK: "/dev/stdin"
! CHECK: "tmp.ilm"
