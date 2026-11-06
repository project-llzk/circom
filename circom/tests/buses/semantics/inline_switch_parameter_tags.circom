// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Select(CHOOSE) {
    Tagged() left;
    Tagged() right;
    Tagged() output out;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;
    var choose = CHOOSE;
    out <== choose ? left : right;
}

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main() {
    component first = Select(1);
    component second = Select(0);
    component two = Expand();
    component three = Expand();
    two.in <== first.out;
    three.in <== second.out;
    signal output out;
    out <== two.out.x[1] + three.out.x[2];
}

component main = Main();

// CONCRETE-DAG: struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-DAG: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED-DAG: struct.member @two : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-DAG: struct.member @three : !struct.type<@Expand::@Expand<[3]>>
