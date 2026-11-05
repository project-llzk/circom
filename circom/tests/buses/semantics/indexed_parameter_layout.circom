// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Forward indexed dimensions separately from scalarized array parameters, including
// through an intermediate component and across different argument shapes.
pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Child(ds, i) {
    Vec(ds[i]) input in;
    Vec(ds[i]) output out;
    signal output selected;
    out <== in;
    selected <== ds[i];
}

template Forward(ds, i) {
    Vec(ds[i]) input in;
    Vec(ds[i]) output out;
    signal output selected;
    component child = Child(ds, i);
    child.in <== in;
    out <== child.out;
    selected <== child.selected;
}

template Main() {
    Vec(2) input in;
    Vec(3) input wide_in;
    Vec(2) output out;
    Vec(3) output wide_out;
    Vec(2) output other_out;
    signal output selected;
    component child = Child([2, 3], 0);
    component forwarded = Forward([2, 3], 1);
    component other = Child([4, 2, 3], 1);
    child.in <== in;
    forwarded.in <== wide_in;
    other.in <== in;
    out <== child.out;
    wide_out <== forwarded.out;
    other_out <== other.out;
    selected <== child.selected + forwarded.selected + other.selected;
}

component main = Main();

// CONCRETE-LABEL: struct.def @"$bus_entry" {
// CONCRETE: struct.member @out.x : !array.type<2 x !felt.type
// CONCRETE: struct.member @wide_out.x : !array.type<3 x !felt.type
// CONCRETE: struct.member @other_out.x : !array.type<2 x !felt.type

// TEMPLATED-LABEL: poly.template @Child$arrays$0_2 {
// TEMPLATED: poly.param @"$array$ds$0"
// TEMPLATED: poly.param @"$array$ds$1"
// TEMPLATED: poly.param @"$layout$ds[i]" : index
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$layout$ds[i]" x !felt.type
// TEMPLATED-LABEL: poly.template @Forward$arrays$0_2 {
// TEMPLATED: struct.member @child : !struct.type<@Child$arrays$0_2::@Child$arrays$0_2<[@"ds[0]@{{[0-9_]+}}", @"ds[1]@{{[0-9_]+}}", @i, @"$layout$ds[i]"]>>
// TEMPLATED-LABEL: poly.template @Main {
// TEMPLATED: struct.member @child : !struct.type<@Child$arrays$0_2::@Child$arrays$0_2<[2, 3, 0, 2]>>
// TEMPLATED: struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !array.type<2 x !felt.type
// TEMPLATED: struct.member @forwarded : !struct.type<@Forward$arrays$0_2::@Forward$arrays$0_2<[2, 3, 1, 3]>>
// TEMPLATED: struct.member @other : !struct.type<@Child$arrays$0_3::@Child$arrays$0_3<[4, 2, 3, 1, 2]>>
