! REQUIRES: aarch64-registered-target
! REQUIRES: classic_flang
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a -c %s 2>&1 | FileCheck --check-prefix=CHECK-ATTRS-NEON %s
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve -c %s 2>&1 | FileCheck --check-prefix=CHECK-ATTRS-SVE %s
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+nosve -c %s 2>&1 | FileCheck --check-prefix=CHECK-ATTRS-NOSVE %s
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve+nosve -c %s 2>&1 | FileCheck --check-prefix=CHECK-ATTRS-SVE-REVERT %s
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2+nosve2 -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-REVERT
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-aes -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-AES
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-sm4 -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-SM4
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-sha3 -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-SHA3
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-bitperm+nosve2-bitperm -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-BITPERM-REVERT
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2 -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-IMPLY
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+nosve+sve2 -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-CONFLICT-REV
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve+sve2 -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE-SVE2
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-bitperm -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-BITPERM
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+nosve+sve2-aes -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE-SUBFEATURE-CONFLICT-REV
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-sm4+nosve2 -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-SUBFEATURE-CONFLICT
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-bitperm+nosve2-aes -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-SUBFEATURE-MIX
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-sm4+nosve2-sm4 -c %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-SM4-REVERT
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-sha3+nosve2-sha3 %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-SHA3-REVERT
! RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve2-aes+nosve2-aes %s 2>&1 | FileCheck %s --check-prefix=CHECK-SVE2-AES-REVERT

! CHECK-ATTRS-NEON: "{{.*}}flang2"
! CHECK-ATTRS-NEON-SAME: "-target_features" "+v8a,+fp-armv8,+neon"
! CHECK-ATTRS-SVE: "{{.*}}flang2"
! CHECK-ATTRS-SVE-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve"
! CHECK-ATTRS-NOSVE: "{{.*}}flang2"
! CHECK-ATTRS-NOSVE-SAME: "-target_features" "+v8a,+fp-armv8,+neon"
! CHECK-ATTRS-SVE-REVERT: "{{.*}}flang2"
! CHECK-ATTRS-SVE-REVERT-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,-sve"
! CHECK-SVE2-REVERT: "{{.*}}flang2"
! CHECK-SVE2-REVERT-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,-sve2"
! CHECK-SVE2-AES:  "{{.*}}flang2"
! CHECK-SVE2-AES-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2-aes,+sve2"
! CHECK-SVE2-SM4: "{{.*}}flang2"
! CHECK-SVE2-SM4-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2-sm4,+sve2"
! CHECK-SVE2-SHA3: "{{.*}}flang2"
! CHECK-SVE2-SHA3-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2-sha3,+sve2"
! CHECK-SVE2-BITPERM-REVERT: "{{.*}}flang2"
! CHECK-SVE2-BITPERM-REVERT-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,-sve2-bitperm,+sve2"
! CHECK-SVE2-IMPLY: "{{.*}}flang2"
! CHECK-SVE2-IMPLY-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2"
! CHECK-SVE2-CONFLICT-REV: "{{.*}}flang2"
! CHECK-SVE2-CONFLICT-REV-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2"
! CHECK-SVE-SVE2: "{{.*}}flang2"
! CHECK-SVE-SVE2-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2"
! CHECK-SVE2-BITPERM: "{{.*}}flang2"
! CHECK-SVE2-BITPERM-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2-bitperm,+sve2"
! CHECK-SVE-SUBFEATURE-CONFLICT-REV: "{{.*}}flang2"
! CHECK-SVE-SUBFEATURE-CONFLICT-REV-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2-aes,+sve2"
! CHECK-SVE2-SUBFEATURE-CONFLICT:  "{{.*}}flang2"
! CHECK-SVE2-SUBFEATURE-CONFLICT-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,-sve2-sm4,-sve2"
! CHECK-SVE2-SUBFEATURE-MIX: "{{.*}}flang2"
! CHECK-SVE2-SUBFEATURE-MIX-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,+sve2-bitperm,+sve2"
! CHECK-SVE2-SM4-REVERT: "{{.*}}flang2"
! CHECK-SVE2-SM4-REVERT-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,-sve2-sm4,+sve2"
! CHECK-SVE2-SHA3-REVERT: "{{.*}}flang2"
! CHECK-SVE2-SHA3-REVERT-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,-sve2-sha3,+sve2"
! CHECK-SVE2-AES-REVERT: "{{.*}}flang2"
! CHECK-SVE2-AES-REVERT-SAME: "-target_features" "+v8a,+fp-armv8,+fullfp16,+neon,+sve,-sve2-aes,+sve2"
