// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Different input tag values create distinct component layouts despite equal ordinary parameters.

pragma circom 2.2.3;
bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }
template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}
template Main() {
    Tagged() a;
    Tagged() b;
    a.x.size = 2;
    b.x.size = 3;
    a.x <== 5;
    b.x <== 7;
    component left = Expand();
    component right = Expand();
    left.in <== a;
    right.in <== b;
    signal output out;
    out <== left.out.x[1] + right.out.x[2];
}
component main = Main();

// CONCRETE-DAG: 2 x !felt.type
// CONCRETE-DAG: 3 x !felt.type

// TEMPLATED-LABEL: poly.template @Expand {
// TEMPLATED: poly.param [[TAG:@"\$tag\$[^" ]+"]] : index
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<[[TAG]] x !felt.type
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @left : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: struct.member @right : !struct.type<@Expand::@Expand<[3]>>
