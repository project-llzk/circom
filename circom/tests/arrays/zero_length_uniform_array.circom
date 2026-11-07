// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

function emptyArray() {
    // The implicit initializer is a zero-length UniformArray in the AST.
    var empty[0];
    return empty;
}

template Main() {
    signal output out[0] <== emptyArray();
}

component main = Main();

// CONCRETE-LABEL: function.def @emptyArray_0() -> !array.type<0 x !felt.type<"bn128">>
// CONCRETE: function.return {{.*}} : !array.type<0 x !felt.type<"bn128">>

// TEMPLATED: global.def const @[[EMPTY:array_const_[0-9]+]] : !array.type<0 x !felt.type<"bn128">> = []
// TEMPLATED-LABEL: function.def @emptyArray()
// TEMPLATED: global.read const @global::@[[EMPTY]] : !array.type<0 x !felt.type<"bn128">>
