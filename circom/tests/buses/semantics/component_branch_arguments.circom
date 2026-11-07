// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// A tagged input assigned after a branch must refresh the output tag with the
// selected constructor's ordinary argument, including downstream hidden sizes.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Child(OFFSET) {
    signal input {size} in;
    signal output {size} out;
    out.size = in.size + OFFSET;
    out <== in;
}

template Expand() {
    signal input {size} in;
    Vec(in.size) output out;
    for (var i = 0; i < in.size; i++) { out.x[i] <== in; }
}

template Branch(CHOOSE) {
    signal {size} tagged;
    tagged.size = 2;
    tagged <== 5;
    component child;
    if (CHOOSE) { child = Child(1); }
    else { child = Child(2); }
    child.in <== tagged;
    component expanded = Expand();
    expanded.in <== child.out;
    signal output out;
    out <== expanded.out.x[0];
}

template Main() {
    component fromThen = Branch(1);
    component fromElse = Branch(0);
    signal output out;
    out <== fromThen.out + fromElse.out;
}

component main = Main();

// CONCRETE-LABEL: struct.def @Expand{{_[0-9]+}} {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @Expand{{_[0-9]+}} {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>

// TEMPLATED-LABEL: poly.template @Branch {
// TEMPLATED: poly.expr [[SIZE:@"2_Add_CHOOSE\?1:2@[0-9]+"]] {
// TEMPLATED: struct.member @expanded : !struct.type<@Expand::@Expand<{{\[}}[[SIZE]]]>>
// TEMPLATED-LABEL: struct.def @Expand {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>
