// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk
// END.

// Unconstrained copies retain independent witnesses; only the explicit equality remains.

pragma circom 2.2.3;
bus Point() { signal x; signal y; }
bus Points() { Point() points[2]; }
template Main() {
    Points() input in;
    Points() a;
    Points() b;
    a <-- in;
    b <-- a;
    a.points[0].x === b.points[1].y;
}
component main = Main();

// CHECK-LABEL: struct.def @Main{{(_[0-9]+)?}} {
// CHECK: function.def @constrain(
// CHECK-NOT: constrain.eq
// CHECK-NOT: function.return
// CHECK: %[[A:[0-9a-zA-Z_.-]+]] = struct.readm %[[SELF:[0-9a-zA-Z_.-]+]][@a]
// CHECK-NEXT: %[[B:[0-9a-zA-Z_.-]+]] = struct.readm %[[SELF]][@b]
// CHECK-NEXT: %[[AP:[0-9a-zA-Z_.-]+]] = pod.read %[[A]][@points]
// CHECK-NEXT: %[[ZERO:[0-9a-zA-Z_.-]+]] = felt.const 0 :
// CHECK-NEXT: %[[I:[0-9a-zA-Z_.-]+]] = cast.toindex %[[ZERO]]
// CHECK-NEXT: %[[A0:[0-9a-zA-Z_.-]+]] = array.read %[[AP]][%[[I]]]
// CHECK-NEXT: %[[X:[0-9a-zA-Z_.-]+]] = pod.read %[[A0]][@x]
// CHECK-NEXT: %[[BP:[0-9a-zA-Z_.-]+]] = pod.read %[[B]][@points]
// CHECK-NEXT: %[[ONE:[0-9a-zA-Z_.-]+]] = felt.const 1 :
// CHECK-NEXT: %[[J:[0-9a-zA-Z_.-]+]] = cast.toindex %[[ONE]]
// CHECK-NEXT: %[[B1:[0-9a-zA-Z_.-]+]] = array.read %[[BP]][%[[J]]]
// CHECK-NEXT: %[[Y:[0-9a-zA-Z_.-]+]] = pod.read %[[B1]][@y]
// CHECK-NEXT: constrain.eq %[[X]], %[[Y]]
// CHECK-NOT: constrain.eq
// CHECK: function.return
