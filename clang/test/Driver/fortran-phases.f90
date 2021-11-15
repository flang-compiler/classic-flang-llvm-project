! Test to see that the correct phases are run for the commandline input

! RUN: %flang -ccc-print-phases 2>&1 %s | FileCheck %s --check-prefix=LINK-NOPP
! RUN: %flang -ccc-print-phases -c 2>&1 %s | FileCheck %s --check-prefix=CONLY-NOPP
! RUN: %flang -ccc-print-phases -S 2>&1 %s | FileCheck %s --check-prefix=AONLY-NOPP
! RUN: %flang -ccc-print-phases -c -emit-llvm 2>&1 %s | FileCheck %s --check-prefix=LLONLY-NOPP
! RUN: %flang -ccc-print-phases -S -emit-llvm 2>&1 %s | FileCheck %s --check-prefix=LLONLY-NOPP
! RUN: %flang -ccc-print-phases -fsyntax-only 2>&1 %s | FileCheck %s --check-prefix=SONLY-NOPP
! RUN: %flang -ccc-print-phases -E 2>&1 %s | FileCheck %s --check-prefix=PPONLY-NOPP

! RUN: %flang -ccc-print-phases 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=LINK
! RUN: %flang -ccc-print-phases 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=LINK
! RUN: %flang -ccc-print-phases -c 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=CONLY
! RUN: %flang -ccc-print-phases -S 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=AONLY
! RUN: %flang -ccc-print-phases -c -emit-llvm 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=LLONLY
! RUN: %flang -ccc-print-phases -S -emit-llvm 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=LLONLY
! RUN: %flang -ccc-print-phases -fsyntax-only 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=SONLY
! RUN: %flang -ccc-print-phases -E 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=PPONLY

! LINK-NOPP: 0: input, {{.*}}, f95
! LINK-NOPP: 1: compiler, {0}, ir
! LINK-NOPP: 2: backend, {1}, assembler
! LINK-NOPP: 3: assembler, {2}, object
! LINK-NOPP: 4: linker, {3}, image

! CONLY-NOPP: 0: input, {{.*}}, f95
! CONLY-NOPP: 1: compiler, {0}, ir
! CONLY-NOPP: 2: backend, {1}, assembler
! CONLY-NOPP: 3: assembler, {2}, object
! CONLY-NOPP-NOT: 4: linker, {3}, image

! AONLY-NOPP: 0: input, {{.*}}, f95
! AONLY-NOPP: 1: compiler, {0}, ir
! AONLY-NOPP: 2: backend, {1}, assembler
! AONLY-NOPP-NOT: 3: assembler, {2}, object
! AONLY-NOPP-NOT: 4: linker, {3}, image

! LLONLY-NOPP: 0: input, {{.*}}, f95
! LLONLY-NOPP: 1: compiler, {0}, ir
! LLONLY-NOPP-NOT: 2: backend, {1}, assembler
! LLONLY-NOPP-NOT: 3: assembler, {2}, object
! LLONLY-NOPP-NOT: 4: linker, {3}, image

! SONLY-NOPP: 0: input, {{.*}}, f95
! SONLY-NOPP-NOT: 1: compiler, {0}, ir
! SONLY-NOPP-NOT: 2: backend, {1}, assembler
! SONLY-NOPP-NOT: 3: assembler, {2}, object
! SONLY-NOPP-NOT: 4: linker, {3}, image

! PPONLY-NOPP: 0: input, {{.*}}, f95
! PPONLY-NOPP: 1: compiler, {0}, ir
! PPONLY-NOPP-NOT: 2: backend, {1}, assembler
! PPONLY-NOPP-NOT: 3: assembler, {2}, object
! PPONLY-NOPP-NOT: 4: linker, {3}, image

! LINK: 0: input, {{.*}}, f95-cpp-input
! LINK: 1: preprocessor, {0}, f95
! LINK: 2: compiler, {1}, ir
! LINK: 3: backend, {2}, assembler
! LINK: 4: assembler, {3}, object
! LINK: 5: linker, {4}, image

! CONLY: 0: input, {{.*}}, f95-cpp-input
! CONLY: 1: preprocessor, {0}, f95
! CONLY: 2: compiler, {1}, ir
! CONLY: 3: backend, {2}, assembler
! CONLY: 4: assembler, {3}, object
! CONLY-NOT: 5: linker, {4}, image

! AONLY: 0: input, {{.*}}, f95-cpp-input
! AONLY: 1: preprocessor, {0}, f95
! AONLY: 2: compiler, {1}, ir
! AONLY: 3: backend, {2}, assembler
! AONLY-NOT: 4: assembler, {3}, object
! AONLY-NOT: 5: linker, {4}, image

! LLONLY: 0: input, {{.*}}, f95-cpp-input
! LLONLY: 1: preprocessor, {0}, f95
! LLONLY: 2: compiler, {1}, ir
! LLONLY-NOT: 3: backend, {2}, assembler
! LLONLY-NOT: 4: assembler, {3}, object
! LLONLY-NOT: 5: linker, {4}, image

! SONLY: 0: input, {{.*}}, f95-cpp-input
! SONLY: 1: preprocessor, {0}, f95
! SONLY-NOT: 2: compiler, {1}, ir
! SONLY-NOT: 3: backend, {2}, assembler
! SONLY-NOT: 4: assembler, {3}, object
! SONLY-NOT: 5: linker, {4}, image

! PPONLY: 0: input, {{.*}}, f95-cpp-input
! PPONLY: 1: preprocessor, {0}, f95
! PPONLY: 2: compiler, {1}, ir
! PPONLY-NOT: 3: backend, {2}, assembler
! PPONLY-NOT: 4: assembler, {3}, object
! PPONLY-NOT: 5: linker, {4}, image

program hello
  write(*, *) "Hello"
end program hello
