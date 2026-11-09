// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

bus Vec(N) { signal {size} x[N]; }

template Child() {
    signal input {size} in;
    signal output out;
    out <== in;
}

template Main(ENABLED) {
    Vec(2) source;
    source.x.size = 2;
    source.x <== [3, 5];
    Vec(2) item;
    if (ENABLED) {
        item.x.size = 99;
        component unused = Child();
        // This path is invalid if executed, but must not change the outer metadata
        // or leave a component waiting for input tags after the nested conflict.
        {
            Vec(3) item;
            item.x.size = 3;
            item.x <== [7, 11, 13];
        }
        unused.in <== source.x[0];
    } else {
        item <== source;
    }
    if (1) {
        if (0) {
            Vec(4) item;
            item.x <== [1, 2, 3, 4];
        }
    }
    signal output out[item.x.size];
    out <== item.x;
}

component main = Main(0);

// CONCRETE: struct.member @out : !array.type<2 x !felt.type
// TEMPLATED: struct.member @out : !array.type<2 x !felt.type
// TEMPLATED: function.def @constrain(
// TEMPLATED: scf.if
// TEMPLATED: bool.assert
// TEMPLATED-NEXT: } else {
