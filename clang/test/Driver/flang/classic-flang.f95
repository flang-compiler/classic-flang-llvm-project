! REQUIRES: classic_flang

! Check that the driver invokes flang1 correctly for preprocessed free-form
! Fortran code. Also check that the backend is invoked correctly.

! RUN: %clang --driver-mode=flang -target x86_64-unknown-linux-gnu -c %s -### 2>&1 \
! RUN:   | FileCheck --check-prefix=CHECK-OBJECT %s
! CHECK-OBJECT: "flang1"
! CHECK-OBJECT-NOT: "-preprocess"
! CHECK-OBJECT-SAME: "-freeform"
! CHECK-OBJECT-NEXT: "flang2"
! CHECK-OBJECT-SAME: "-asm" [[LLFILE:.*.ll]]
! CHECK-OBJECT-NEXT: {{clang.* "-cc1"}}
! CHECK-OBJECT-SAME: "-o" "classic-flang.o"
! CHECK-OBJECT-SAME: "-x" "ir"
! CHECK-OBJECT-SAME: [[LLFILE]]

! Check that the driver invokes flang1 correctly when preprocessing is
! explicitly requested.

! RUN: %clang --driver-mode=flang -target x86_64-unknown-linux-gnu -E %s -### 2>&1 \
! RUN:   | FileCheck --check-prefix=CHECK-PREPROCESS %s
! CHECK-PREPROCESS: "flang1"
! CHECK-PREPROCESS-SAME: "-preprocess"
! CHECK-PREPROCESS-SAME: "-es"
! CHECK-PREPROCESS-SAME: "-pp"
! CHECK-PREPROCESS-NOT: "flang1"
! CHECK-PREPROCESS-NOT: "flang2"
! CHECK-PREPROCESS-NOT: {{clang.* "-cc1"}}
! CHECK-PREPROCESS-NOT: {{clang.* "-cc1as"}}

! Check that the backend job (clang -cc1) is not combined into the compile job
! (flang2) even if -integrated-as is specified.

! RUN: %clang --driver-mode=flang -target x86_64-unknown-linux-gnu -integrated-as -S %s -### 2>&1 \
! RUN:   | FileCheck --check-prefix=CHECK-ASM %s
! CHECK-ASM: "flang1"
! CHECK-ASM-NEXT: "flang2"
! CHECK-ASM-SAME: "-asm" [[LLFILE:.*.ll]]
! CHECK-ASM-NEXT: {{clang.* "-cc1"}}
! CHECK-ASM-SAME: "-o" "classic-flang.s"
! CHECK-ASM-SAME: "-x" "ir"
! CHECK-ASM-SAME: [[LLFILE]]
