// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --implicit-check-not=arith.subi
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --implicit-check-not=arith.subi
// END.

// Empty inputs complete without decrementing an input counter.

pragma circom 2.2.3;
bus Vec(N) { signal x[N]; }
template Empty() {
    Vec(0) input in;
    signal output out;
    out <== 7;
}
template Main() {
    Vec(0) input in;
    signal output out;
    component child = Empty();
    child.in <== in;
    out <== child.out;
}
component main = Main();

// CHECK-LABEL: struct.def @Main{{(_[0-9]+)?}} {
// CHECK: struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !array.type<0 x !felt.type
// CHECK: function.def @compute(
// CHECK-NOT: scf.if
// CHECK: function.call @Empty{{(_[0-9]+)?}}::@Empty{{(_[0-9]+)?}}::@compute(
// CHECK: %[[CHILD:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %{{[0-9a-zA-Z_.-]+}} }
// CHECK-NOT: function.call
// CHECK: %[[RESULT:[0-9a-zA-Z_.-]+]] = pod.read %[[CHILD]][@comp]
// CHECK-NEXT: %[[OUT:[0-9a-zA-Z_.-]+]] = struct.readm %[[RESULT]][@out]
// CHECK-NEXT: struct.writem {{.*}}[@out] = %[[OUT]]
// CHECK-NOT: function.call
// CHECK: function.return
