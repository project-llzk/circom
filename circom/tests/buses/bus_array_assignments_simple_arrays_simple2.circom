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

bus otroBus(n){
    miBus(n) a[2];
}

template A(){
    otroBus(3) input in;
    miBus(3) input in1;

    miBus(3) output out[2] <== [in.a[0], in1];

    out[0].b === in.a[0].b;
}

component main = A();

// Check bus/array layouts and the operands of nested writes and equalities.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %[[A1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A2]], %[[A3]]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@b]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE9:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@b]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE9]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@b]
// CONCRETE: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5]][@a]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[A6]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[B6]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2:[0-9a-zA-Z_.-]+]][@a]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = array.read %[[A1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE4:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE4]]]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@b]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@b]
// TEMPLATED: constrain.eq %[[B1]], %[[B2]]
// TEMPLATED: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2]][@a]
// TEMPLATED: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[A4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@b]
// TEMPLATED: constrain.eq %[[B3]], %[[B4]]
// TEMPLATED: function.return
