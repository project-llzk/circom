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

    miBus(3) output out[2][2] <== [in.a, [in1, in1]];

    out[0][1].a === in.a[1].a;
    out[1][1].a === in1.a;
}

component main = A();

// Check bus/array layouts and the operands of nested writes and equalities.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<2,2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE6:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE8:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %[[A1]]{{\[}}%[[VALUE8]]]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A2]], %[[A3]]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@b]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE10:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE10]]]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@b]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE6]][@a]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[A7]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: constrain.eq %[[A6]], %[[A8]]
// CONCRETE: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CONCRETE: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %{{[0-9a-zA-Z_.-]+}}[@a]
// CONCRETE: constrain.eq %[[A9]], %[[A10]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<2,2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[VALUE2:[0-9a-zA-Z_.-]+]][@a]
// TEMPLATED: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE3:[0-9a-zA-Z_.-]+]], %[[VALUE4:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE3]], %[[VALUE4]]]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@b]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@b]
// TEMPLATED: constrain.eq %[[B1]], %[[B2]]
// TEMPLATED: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2]][@a]
// TEMPLATED: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[A5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A6]]
// TEMPLATED: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// TEMPLATED: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %{{[0-9a-zA-Z_.-]+}}[@a]
// TEMPLATED: constrain.eq %[[A7]], %[[A8]]
// TEMPLATED: function.return
