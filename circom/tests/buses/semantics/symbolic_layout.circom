// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Concrete layouts use two-by-four arrays; templated layouts preserve the derived dimension through the child component.

pragma circom 2.2.3;
bus Vec(N) { signal coords[N]; }
bus Points(N) { Vec(N + 1) points[2]; }
template Copy(M) {
    Points(M + 1) input in;
    Points(M + 1) output out;
    out <== in;
}
template Main(M) {
    Points(M + 1) input in;
    Points(M + 1) output out;
    component child = Copy(M);
    child.in <== in;
    out <== child.out;
}
component main = Main(2);

// CONCRETE-LABEL: struct.def @"$bus_entry" {
// CONCRETE: struct.member @out.points.coords : !array.type<2,4 x !felt.type

// TEMPLATED: llzk.main = !struct.type<@Main::@"$bus_entry"<[2, 4]>>
// TEMPLATED-LABEL: poly.template @Copy {
// TEMPLATED: poly.param [[DIM:@"\$layout\$[^" ]+"]] : index
// TEMPLATED: struct.member @out : !pod.type<[@points: !array.type<2 x !pod.type<[@coords: !array.type<[[DIM]] x !felt.type
// TEMPLATED-LABEL: poly.template @Main {
// TEMPLATED: poly.param [[DIM:@"\$layout\$[^" ]+"]] : index
// TEMPLATED: struct.member @child : !struct.type<@Copy::@Copy<[@M, [[DIM]]]>>
// TEMPLATED: struct.member @out.points.coords : !array.type<2,[[DIM]] x !felt.type
