// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Preserve every component index when tracking constructors and derived tags,
// while ignoring indices into the component's signal arrays.

pragma circom 2.2.3;

bus Tagged() { signal {size} x[2]; }

template Child() {
    Tagged() input in;
    signal output {size} out;
    out.size = in.x.size;
    out <== in.x[0] + in.x[1];
}

template Main() {
    Tagged() a;
    Tagged() b;
    a.x.size = 2;
    b.x.size = 3;
    a.x[0] <== 5;
    a.x[1] <== 6;
    b.x[0] <== 7;
    b.x[1] <== 8;
    component children[1][3];
    children[0][0] = Child();
    children[0][1] = Child();
    children[0][2] = parallel (parallel Child());
    children[0][0].in.x[0] <== a.x[0];
    children[0][1].in.x[0] <== b.x[0];
    children[0][2].in.x[0] <== a.x[0];
    children[0][0].in.x[1] <== a.x[1];
    children[0][1].in.x[1] <== b.x[1];
    children[0][2].in.x[1] <== a.x[1];
    signal output left[children[0][0].out.size];
    signal output right[children[0][1].out.size];
    signal output repeated[children[0][2].out.size];
    for (var i = 0; i < children[0][0].out.size; i++) {
        left[i] <== children[0][0].out;
    }
    for (var j = 0; j < children[0][1].out.size; j++) {
        right[j] <== children[0][1].out;
    }
    for (var k = 0; k < children[0][2].out.size; k++) {
        repeated[k] <== children[0][2].out;
    }
}

component main = Main();

// CONCRETE: struct.member @left : !array.type<2 x
// CONCRETE: struct.member @right : !array.type<3 x
// CONCRETE: struct.member @repeated : !array.type<2 x

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @left : !array.type<2 x
// TEMPLATED: struct.member @right : !array.type<3 x
// TEMPLATED: struct.member @repeated : !array.type<2 x
// TEMPLATED: @Child::@Child<[2]>
// TEMPLATED: @Child::@Child<[3]>
