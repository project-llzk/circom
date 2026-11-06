// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

bus Vec(ds) { signal x[ds[0]]; }
bus IndexedVec(ds, i) { signal x[ds[i]]; }
bus ExtendedVec(ds) { signal x[ds[0] + 1]; }
bus MatrixVec(ds) { signal x[ds[1][0]]; }
bus Rows(ds) { Vec(ds[1]) row; }
bus IndexedRows(ds, i) { IndexedVec(ds[i], 1) row; }

// The caller deliberately reuses the bus formal's name, ds.
template Main(ds, i) {
    var table[2][2] = [[2, 3], [4, 5]];

    Vec([2, 3]) input literal_in;
    Vec([2, 3]) output literal_out;
    literal_out <== literal_in;

    IndexedVec([2, 3], 1) input indexed_in;
    IndexedVec([2, 3], 1) output indexed_out;
    indexed_out <== indexed_in;

    ExtendedVec([2, 3]) input extended_in;
    ExtendedVec([2, 3]) output extended_out;
    extended_out <== extended_in;

    MatrixVec([[2, 3], [4, 5]]) input matrix_in;
    MatrixVec([[2, 3], [4, 5]]) output matrix_out;
    matrix_out <== matrix_in;

    Rows([[2, 3], [4, 5]]) input rows_in;
    Rows([[2, 3], [4, 5]]) output rows_out;
    rows_out <== rows_in;

    Vec(1 ? [2, 3] : [4, 5]) input conditional_in;
    Vec(1 ? [2, 3] : [4, 5]) output conditional_out;
    conditional_out <== conditional_in;

    Vec([ds, 3]) input symbolic_value_in;
    Vec([ds, 3]) output symbolic_value_out;
    symbolic_value_out <== symbolic_value_in;

    IndexedVec([2, 3], i) input symbolic_index_in;
    IndexedVec([2, 3], i) output symbolic_index_out;
    symbolic_index_out <== symbolic_index_in;

    IndexedVec([2, 3], 1 - 1) input computed_index_in;
    IndexedVec([2, 3], 1 - 1) output computed_index_out;
    computed_index_out <== computed_index_in;

    Vec(table[1]) input slice_in;
    Vec(table[1]) output slice_out;
    slice_out <== slice_in;

    IndexedRows([[2, 3], [4, 5]], i) input symbolic_rows_in;
    IndexedRows([[2, 3], [4, 5]], i) output symbolic_rows_out;
    symbolic_rows_out <== symbolic_rows_in;
}

component main = Main(2, 0);

// CONCRETE-LABEL: struct.def @Main_0 {
// CONCRETE: struct.member @literal_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @indexed_out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @extended_out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @matrix_out : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @rows_out : !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE: struct.member @conditional_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @symbolic_value_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @symbolic_index_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @computed_index_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @slice_out : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @symbolic_rows_out : !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>

// TEMPLATED: poly.param @ds : index
// TEMPLATED: poly.param @i
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @literal_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @indexed_out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @extended_out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @matrix_out : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @rows_out : !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// TEMPLATED: struct.member @conditional_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @symbolic_value_out : !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @symbolic_index_out : !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@{{[0-9_]+}}" x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @computed_index_out : !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@{{[0-9_]+}}" x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @slice_out : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @symbolic_rows_out : !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@{{[0-9_]+}}" x !felt.type<"bn128">>]>]>
