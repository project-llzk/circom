// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk
// END.

// The constrained copy and explicit equality each constrain all four scalar leaves.

pragma circom 2.2.3;
bus Point() { signal x; signal y; }
bus Points() { Point() points[2]; }
template Main() {
    Points() input in;
    Points() a;
    a <== in;
    a === in;
}
component main = Main();

// CHECK-LABEL: struct.def @Main{{(_[0-9]+)?}} {
// CHECK: function.def @constrain(
// CHECK-NOT: constrain.eq
// CHECK-NOT: function.return
// CHECK: %[[END0:[a-zA-Z0-9_]+]] = arith.constant 2 : index
// CHECK-NEXT: %[[START0:[a-zA-Z0-9_]+]] = arith.constant 0 : index
// CHECK-NEXT: %[[STEP0:[a-zA-Z0-9_]+]] = arith.constant 1 : index
// CHECK-NEXT: scf.for %[[I0:[a-zA-Z0-9_]+]] = %[[START0]] to %[[END0]] step %[[STEP0]] {
// CHECK-NEXT: %[[A0:[a-zA-Z0-9_]+]] = array.read {{.*}}[%[[I0]]]
// CHECK-NEXT: %[[B0:[a-zA-Z0-9_]+]] = array.read {{.*}}[%[[I0]]]
// CHECK-NEXT: %[[AX0:[a-zA-Z0-9_]+]] = pod.read %[[A0]][@x]
// CHECK-NEXT: %[[BX0:[a-zA-Z0-9_]+]] = pod.read %[[B0]][@x]
// CHECK-NEXT: constrain.eq %[[AX0]], %[[BX0]]
// CHECK-NEXT: %[[AY0:[a-zA-Z0-9_]+]] = pod.read %[[A0]][@y]
// CHECK-NEXT: %[[BY0:[a-zA-Z0-9_]+]] = pod.read %[[B0]][@y]
// CHECK-NEXT: constrain.eq %[[AY0]], %[[BY0]]
// CHECK-NEXT: }
// CHECK-NOT: constrain.eq
// CHECK-NOT: function.return
// CHECK: %[[END1:[a-zA-Z0-9_]+]] = arith.constant 2 : index
// CHECK-NEXT: %[[START1:[a-zA-Z0-9_]+]] = arith.constant 0 : index
// CHECK-NEXT: %[[STEP1:[a-zA-Z0-9_]+]] = arith.constant 1 : index
// CHECK-NEXT: scf.for %[[I1:[a-zA-Z0-9_]+]] = %[[START1]] to %[[END1]] step %[[STEP1]] {
// CHECK-NEXT: %[[A1:[a-zA-Z0-9_]+]] = array.read {{.*}}[%[[I1]]]
// CHECK-NEXT: %[[B1:[a-zA-Z0-9_]+]] = array.read {{.*}}[%[[I1]]]
// CHECK-NEXT: %[[AX1:[a-zA-Z0-9_]+]] = pod.read %[[A1]][@x]
// CHECK-NEXT: %[[BX1:[a-zA-Z0-9_]+]] = pod.read %[[B1]][@x]
// CHECK-NEXT: constrain.eq %[[AX1]], %[[BX1]]
// CHECK-NEXT: %[[AY1:[a-zA-Z0-9_]+]] = pod.read %[[A1]][@y]
// CHECK-NEXT: %[[BY1:[a-zA-Z0-9_]+]] = pod.read %[[B1]][@y]
// CHECK-NEXT: constrain.eq %[[AY1]], %[[BY1]]
// CHECK-NEXT: }
// CHECK-NOT: constrain.eq
// CHECK-NEXT: function.return
