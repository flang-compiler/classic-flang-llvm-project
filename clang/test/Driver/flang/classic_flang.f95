! Check that the driver can invoke flang1 and flang2 to compile Fortran with
! --driver-mode=flang (default when the file extension is .f95).

! REQUIRES: classic_flang

! RUN: %clang -target x86_64-unknown-linux-gnu -integrated-as -c %s -### 2>&1 \
! RUN:   | FileCheck --check-prefix=CHECK-OBJECT %s
! CHECK-OBJECT: flang1
! CHECK-OBJECT: flang2
! CHECK-OBJECT-SAME: "-asm" [[LLFILE:.*.ll]]
! CHECK-OBJECT-NOT: cc1as
! CHECK-OBJECT: clang
! CHECK-OBJECT-SAME: -cc1
! CHECK-OBJECT-SAME: "-o" "classic_flang.o"
! CHECK-OBJECT-SAME: "-x" "ir"
! CHECK-OBJECT-SAME: [[LLFILE]]

! RUN: %clang -target x86_64-unknown-linux-gnu -integrated-as -S %s -### 2>&1 \
! RUN:   | FileCheck --check-prefix=CHECK-ASM %s
! CHECK-ASM: flang1
! CHECK-ASM: flang2
! CHECK-ASM-SAME: "-asm" [[LLFILE:.*.ll]]
! CHECK-ASM-NOT: cc1as
! CHECK-ASM: clang
! CHECK-ASM-SAME: -cc1
! CHECK-ASM-SAME: "-o" "classic_flang.s"
! CHECK-ASM-SAME: "-x" "ir"
! CHECK-ASM-SAME: [[LLFILE]]
