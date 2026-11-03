// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.1.6;

bus A(){
    signal x;
    signal y;
}

template B(){
    A() input in;
    output A() {tag} out;
    out.tag = 2;
    out <== in;
}

component main = B();

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @B_0 {
// CONCRETE: struct.member @out : !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE1:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[X1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@x]
// CONCRETE: %[[X2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2:[a-zA-Z0-9_.-]+]][@x]
// CONCRETE: constrain.eq %[[X1]], %[[X2]]
// CONCRETE: %[[Y1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@y]
// CONCRETE: %[[Y2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2]][@y]
// CONCRETE: constrain.eq %[[Y1]], %[[Y2]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE1:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[X1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@x]
// TEMPLATED: %[[X2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2:[a-zA-Z0-9_.-]+]][@x]
// TEMPLATED: constrain.eq %[[X1]], %[[X2]]
// TEMPLATED: %[[Y1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@y]
// TEMPLATED: %[[Y2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2]][@y]
// TEMPLATED: constrain.eq %[[Y1]], %[[Y2]]
// TEMPLATED: function.return
