! REQUIRES: classic_flang
! REQUIRES: system-windows

! Check that the driver invokes flang1 correctly for preprocessed fixed-form
! Fortran code.

! RUN: %clang --driver-mode=flang -E -target x86_64-unknown-windows-gnu -c - < NUL -### 2>&1 \
! RUN:   | FileCheck %s
! CHECK: "{{.*}}flang1"
! CHECK: "nul"
! CHECK: "tmp.ilm"
