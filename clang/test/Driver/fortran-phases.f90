! Test to see that the correct phases are run for the commandline input

! REQUIRES: classic_flang

! RUN: %flang -ccc-print-phases 2>&1 %s | FileCheck %s --check-prefix=LINK-NOPP
! RUN: %flang -ccc-print-phases -c 2>&1 %s | FileCheck %s --check-prefix=CONLY-NOPP
! RUN: %flang -ccc-print-phases -S 2>&1 %s | FileCheck %s --check-prefix=AONLY-NOPP
! RUN: %flang -ccc-print-phases -c -emit-llvm 2>&1 %s | FileCheck %s --check-prefix=LLONLY-NOPP
! RUN: %flang -ccc-print-phases -S -emit-llvm 2>&1 %s | FileCheck %s --check-prefix=LLONLY-NOPP
! RUN: %flang -ccc-print-phases -emit-flang-llvm 2>&1 %s | FileCheck %s --check-prefix=FLLONLY-NOPP
! RUN: %flang -ccc-print-phases -fsyntax-only 2>&1 %s | FileCheck %s --check-prefix=SONLY-NOPP
! RUN: %flang -ccc-print-phases -E 2>&1 %s | FileCheck %s --check-prefix=PPONLY-NOPP

! RUN: %flang -ccc-print-phases 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=LINK
! RUN: %flang -ccc-print-phases 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=LINK
! RUN: %flang -ccc-print-phases -c 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=CONLY
! RUN: %flang -ccc-print-phases -S 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=AONLY
! RUN: %flang -ccc-print-phases -c -emit-llvm 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=LLONLY
! RUN: %flang -ccc-print-phases -S -emit-llvm 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=LLONLY
! RUN: %flang -ccc-print-phases -emit-flang-llvm 2>&1 -x f95-cpp-input %s | FileCheck %s --check-prefix=FLLONLY
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
! CONLY-NOPP-NOT: {{.*}}: linker, {{{.*}}}, image

! AONLY-NOPP: 0: input, {{.*}}, f95
! AONLY-NOPP: 1: compiler, {0}, ir
! AONLY-NOPP: 2: backend, {1}, assembler
! AONLY-NOPP-NOT: {{.*}}: assembler, {{{.*}}}, object
! AONLY-NOPP-NOT: {{.*}}: linker, {{{.*}}}, image

! LLONLY-NOPP: 0: input, {{.*}}, f95
! LLONLY-NOPP: 1: compiler, {0}, ir
! LLONLY-NOPP-NOT: {{.*}}: backend, {{{.*}}}, assembler
! LLONLY-NOPP-NOT: {{.*}}: assembler, {{{.*}}}, object
! LLONLY-NOPP-NOT: {{.*}}: linker, {{{.*}}}, image

! FLLONLY-NOPP: 0: input, {{.*}}, f95
! FLLONLY-NOPP: 1: compiler, {0}, ir
! FLLONLY-NOPP-NOT: {{.*}}: backend, {{{.*}}}, assembler
! FLLONLY-NOPP-NOT: {{.*}}: assembler, {{{.*}}}, object
! FLLONLY-NOPP-NOT: {{.*}}: linker, {{{.*}}}, image

! SONLY-NOPP: 0: input, {{.*}}, f95
! SONLY-NOPP-NOT: {{.*}}: compiler, {{{.*}}}, ir
! SONLY-NOPP-NOT: {{.*}}: backend, {{{.*}}}, assembler
! SONLY-NOPP-NOT: {{.*}}: assembler, {{{.*}}}, object
! SONLY-NOPP-NOT: {{.*}}: linker, {{{.*}}}, image

! flang always preprocesses with -E regardless of file extension
! PPONLY-NOPP: 0: input, {{.*}}, f95
! PPONLY-NOPP: 1: preprocessor, {0}, f95
! PPONLY-NOPP-NOT: {{.*}}: compiler, {{{.*}}}, ir
! PPONLY-NOPP-NOT: {{.*}}: backend, {{{.*}}}, assembler
! PPONLY-NOPP-NOT: {{.*}}: assembler, {{{.*}}}, object
! PPONLY-NOPP-NOT: {{.*}}: linker, {{{.*}}}, image

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
! CONLY-NOT: {{.*}}: linker, {{{.*}}}, image

! AONLY: 0: input, {{.*}}, f95-cpp-input
! AONLY: 1: preprocessor, {0}, f95
! AONLY: 2: compiler, {1}, ir
! AONLY: 3: backend, {2}, assembler
! AONLY-NOT: {{.*}}: assembler, {{{.*}}}, object
! AONLY-NOT: {{.*}}: linker, {{{.*}}}, image

! LLONLY: 0: input, {{.*}}, f95-cpp-input
! LLONLY: 1: preprocessor, {0}, f95
! LLONLY: 2: compiler, {1}, ir
! LLONLY-NOT: {{.*}}: backend, {{{.*}}}, assembler
! LLONLY-NOT: {{.*}}: assembler, {{{.*}}}, object
! LLONLY-NOT: {{.*}}: linker, {{{.*}}}, image

! FLLONLY: 0: input, {{.*}}, f95-cpp-input
! FLLONLY: 1: preprocessor, {0}, f95
! FLLONLY: 2: compiler, {1}, ir
! FLLONLY-NOT: {{.*}}: backend, {{{.*}}}, assembler
! FLLONLY-NOT: {{.*}}: assembler, {{{.*}}}, object
! FLLONLY-NOT: {{.*}}: linker, {{{.*}}}, image

! SONLY: 0: input, {{.*}}, f95-cpp-input
! SONLY: 1: preprocessor, {0}, f95
! SONLY-NOT: {{.*}}: compiler, {{{.*}}}, ir
! SONLY-NOT: {{.*}}: backend, {{{.*}}}, assembler
! SONLY-NOT: {{.*}}: assembler, {{{.*}}}, object
! SONLY-NOT: {{.*}}: linker, {{{.*}}}, image

! PPONLY: 0: input, {{.*}}, f95-cpp-input
! PPONLY: 1: preprocessor, {0}, f95
! PPONLY-NOT: {{.*}}: compiler, {{{.*}}}, ir
! PPONLY-NOT: {{.*}}: backend, {{{.*}}}, assembler
! PPONLY-NOT: {{.*}}: assembler, {{{.*}}}, object
! PPONLY-NOT: {{.*}}: linker, {{{.*}}}, image

program hello
  write(*, *) "Hello"
end program hello
