// REQUIRES: aarch64-registered-target
// REQUIRES: classic_flang
// RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a -c %s 2>&1 | FileCheck --check-prefix=CHECK-ATTRS-NEON %s
// RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve -c %s 2>&1 | FileCheck --check-prefix=CHECK-ATTRS-SVE %s
// RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+nosve -c %s 2>&1 | FileCheck --check-prefix=CHECK-ATTRS-NOSVE %s
// RUN: %flang -### -target aarch64-linux-gnu -march=armv8-a+sve+nosve -c %s 2>&1 | FileCheck --check-prefix=CHECK-ATTRS-NOSVE %s
// CHECK-ATTRS-NEON: "{{.*}}flang2"
// CHECK-ATTRS-NEON-SAME: "-target_features" "+neon,+v8a
// CHECK-ATTRS-SVE: "{{.*}}flang2"
// CHECK-ATTRS-SVE-SAME: "-target_features" "+neon,+v8a,+sve
// CHECK-ATTRS-NOSVE: "{{.*}}flang2"
// CHECK-ATTRS-NOSVE-SAME: "-target_features" "+neon,+v8a,-sve
