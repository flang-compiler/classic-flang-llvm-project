! REQUIRES: classic_flang

! Check that the driver invokes flang1 correctly when flang invokes with -dM option

! RUN: %clang --driver-mode=flang -dM -target x86_64-unknown-linux-gnu -c %s -### 2>&1 \
! RUN:   | FileCheck %s
! CHECK: "{{.*}}flang1"
! CHECK: "-list-macros"
