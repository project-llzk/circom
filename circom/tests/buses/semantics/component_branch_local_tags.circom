// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Input tags belong to the constructor occurrence even when the component is
// constructed and used only in one parameter-controlled branch.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Child() {
    Tagged() input in;
    signal output out[in.x.size];
    for (var i = 0; i < in.x.size; i++) { out[i] <== in.x; }
}

template ThenOnly(ENABLED) {
    Tagged() tagged;
    tagged.x.size = 2;
    tagged.x <== 5;
    component child;
    signal output out;
    out <== 5;
    if (ENABLED) {
        child = Child();
        child.in <== tagged;
        child.out[1] === out;
    }
}

template ElseOnly(ENABLED) {
    Tagged() tagged;
    tagged.x.size = 3;
    tagged.x <== 7;
    component child;
    signal output out;
    if (ENABLED) {
        out <== 0;
    } else {
        child = Child();
        child.in <== tagged;
        out <== child.out[2];
    }
}

template Main() {
    component fromThen = ThenOnly(1);
    component skipThen = ThenOnly(0);
    component fromElse = ElseOnly(0);
    component skipElse = ElseOnly(1);
    signal output out;
    out <== fromThen.out + skipThen.out + fromElse.out + skipElse.out;
}

component main = Main();

// CONCRETE-LABEL: struct.def @Child_0 {
// CONCRETE: struct.member @out : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-LABEL: struct.def @Child_3 {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @ElseOnly {
// TEMPLATED: struct.member @child : !struct.type<@Child::@Child<[3]>>
// TEMPLATED-LABEL: struct.def @ThenOnly {
// TEMPLATED: struct.member @child : !struct.type<@Child::@Child<[2]>>
