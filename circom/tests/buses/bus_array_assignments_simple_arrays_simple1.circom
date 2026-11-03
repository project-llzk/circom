// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus miBus(n){
    signal a;
    signal b;
}

template A(){
    miBus(3) input in;

    miBus(3) output out[2] <== [in, in];

    out[1].b === in.b;
}

component main = A();

// Check bus/array layouts and the operands of nested writes and equalities.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[VALUE1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]] = %[[VALUE3:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return %[[VALUE4:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE6:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE7:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@b]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE7]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE7]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A4]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE7]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@b]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE7]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[B6]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE1:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE3:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2]]]
// TEMPLATED: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@a]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// TEMPLATED: constrain.eq %[[A1]], %[[A2]]
// TEMPLATED: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@b]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@b]
// TEMPLATED: constrain.eq %[[B1]], %[[B2]]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE4:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@b]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE5:[a-zA-Z0-9_.-]+]][@b]
// TEMPLATED: constrain.eq %[[B3]], %[[B4]]
// TEMPLATED: function.return
