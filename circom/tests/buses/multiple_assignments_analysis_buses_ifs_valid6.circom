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
// CONCRETE: array.write %[[A1:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@a] = %[[A1]]
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %{{[0-9a-zA-Z_.-]+}}[@b]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[A2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[A3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT4]], %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[A4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[A5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT6]], %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: array.write %[[A1:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: pod.write %{{[0-9a-zA-Z_.-]+}}[@a] = %[[A1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %{{[0-9a-zA-Z_.-]+}}[@b]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[A2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: constrain.eq %[[A3]], %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.return
