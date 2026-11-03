// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus MiBusPeque{
    signal a[2];
}

bus MiBus{
    signal b;
    MiBusPeque a[2];
}

template A(){
    MiBus input in;
    MiBus output out;

    if (in.b > 10){
        out.a[1].a[0] <-- in.a[0].a[0];
    } else{
        out.a[1].a[0] <-- in.a[0].a[0];
    }
    out.a[0].a <== [3,3];
}

component main = A();

// Check bus/array layouts and the operands of nested writes and equalities.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[A1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE1:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT1:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[ELEMENT2:[a-zA-Z0-9_.-]+]][@a] = %[[A1]]
// CONCRETE: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4:[a-zA-Z0-9_.-]+]][@b]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[A2]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[A3]]{{\[}}%[[VALUE6:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT4]], %[[VALUE7:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[A4]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[A5]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT6]], %[[VALUE10:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: array.write %[[A1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE1:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: pod.write %[[ELEMENT2:[a-zA-Z0-9_.-]+]][@a] = %[[A1]]
// TEMPLATED: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4:[a-zA-Z0-9_.-]+]][@b]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[A2]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: constrain.eq %[[A3]], %[[VALUE6:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.return
