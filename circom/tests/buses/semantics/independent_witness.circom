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
// CHECK: %[[A:[a-zA-Z0-9_.-]+]] = struct.readm %[[SELF:[a-zA-Z0-9_.-]+]][@a]
// CHECK-NEXT: %[[B:[a-zA-Z0-9_.-]+]] = struct.readm %[[SELF]][@b]
// CHECK-NEXT: %[[AP:[a-zA-Z0-9_.-]+]] = pod.read %[[A]][@points]
// CHECK-NEXT: %[[ZERO:[a-zA-Z0-9_.-]+]] = felt.const 0 :
// CHECK-NEXT: %[[I:[a-zA-Z0-9_.-]+]] = cast.toindex %[[ZERO]]
// CHECK-NEXT: %[[A0:[a-zA-Z0-9_.-]+]] = array.read %[[AP]][%[[I]]]
// CHECK-NEXT: %[[X:[a-zA-Z0-9_.-]+]] = pod.read %[[A0]][@x]
// CHECK-NEXT: %[[BP:[a-zA-Z0-9_.-]+]] = pod.read %[[B]][@points]
// CHECK-NEXT: %[[ONE:[a-zA-Z0-9_.-]+]] = felt.const 1 :
// CHECK-NEXT: %[[J:[a-zA-Z0-9_.-]+]] = cast.toindex %[[ONE]]
// CHECK-NEXT: %[[B1:[a-zA-Z0-9_.-]+]] = array.read %[[BP]][%[[J]]]
// CHECK-NEXT: %[[Y:[a-zA-Z0-9_.-]+]] = pod.read %[[B1]][@y]
// CHECK-NEXT: constrain.eq %[[X]], %[[Y]]
// CHECK-NOT: constrain.eq
// CHECK: function.return
