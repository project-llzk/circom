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

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_0::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    module @global {
// CONCRETE-NEXT:      global.def const @array_const_0 : !array.type<2,2 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">]
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Main_0 {
// CONCRETE-NEXT:      struct.def @Main_0 {
// CONCRETE-NEXT:        struct.member @literal_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @indexed_out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @extended_out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @matrix_out : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @rows_out : !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @conditional_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @symbolic_value_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @symbolic_index_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @computed_index_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @slice_out : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @symbolic_rows_out : !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "literal_in"}, %[[VAL_1:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "indexed_in"}, %[[VAL_2:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "extended_in"}, %[[VAL_3:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {function.arg_name = "matrix_in"}, %[[VAL_4:[0-9a-zA-Z_.-]+]]: !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]> {function.arg_name = "rows_in"}, %[[VAL_5:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "conditional_in"}, %[[VAL_6:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "symbolic_value_in"}, %[[VAL_7:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "symbolic_index_in"}, %[[VAL_8:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "computed_index_in"}, %[[VAL_9:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {function.arg_name = "slice_in"}, %[[VAL_10:[0-9a-zA-Z_.-]+]]: !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]> {function.arg_name = "symbolic_rows_in"}) -> !struct.type<@Main_0::@Main_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_0::@Main_0<[]>>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@literal_out] = %[[VAL_0]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@indexed_out] = %[[VAL_1]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@extended_out] = %[[VAL_2]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@matrix_out] = %[[VAL_3]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@rows_out] = %[[VAL_4]] : <@Main_0::@Main_0<[]>>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@conditional_out] = %[[VAL_5]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@symbolic_value_out] = %[[VAL_6]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@symbolic_index_out] = %[[VAL_7]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@computed_index_out] = %[[VAL_8]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@slice_out] = %[[VAL_9]] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_11]][@symbolic_rows_out] = %[[VAL_10]] : <@Main_0::@Main_0<[]>>, !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          function.return %[[VAL_11]] : !struct.type<@Main_0::@Main_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_13:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_0::@Main_0<[]>>, %[[VAL_14:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "literal_in"}, %[[VAL_15:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "indexed_in"}, %[[VAL_16:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "extended_in"}, %[[VAL_17:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {function.arg_name = "matrix_in"}, %[[VAL_18:[0-9a-zA-Z_.-]+]]: !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]> {function.arg_name = "rows_in"}, %[[VAL_19:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "conditional_in"}, %[[VAL_20:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "symbolic_value_in"}, %[[VAL_21:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "symbolic_index_in"}, %[[VAL_22:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "computed_index_in"}, %[[VAL_23:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {function.arg_name = "slice_in"}, %[[VAL_24:[0-9a-zA-Z_.-]+]]: !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]> {function.arg_name = "symbolic_rows_in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@literal_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@indexed_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@extended_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@matrix_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@rows_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@conditional_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@symbolic_value_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@symbolic_index_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@computed_index_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@slice_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_13]][@symbolic_rows_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_25]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_14]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_38]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_26]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_15]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_40]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_27]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_16]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_41]], %[[VAL_42]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_28]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_17]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_44]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_29]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_18]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_46]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_48]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_30]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_19]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_49]], %[[VAL_50]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_31]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_20]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_51]], %[[VAL_52]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_32]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_21]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_54]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_33]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_22]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_55]], %[[VAL_56]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_34]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_23]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_57]], %[[VAL_58]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_35]][@row] : <[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_24]][@row] : <[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_59]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_61]], %[[VAL_62]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@Main_0::@Main_0<[]>>
// CONCRETE-NEXT:        struct.member @literal_out.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @indexed_out.x : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @extended_out.x : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @matrix_out.x : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @rows_out.row.x : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @conditional_out.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @symbolic_value_out.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @symbolic_index_out.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @computed_index_out.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @slice_out.x : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @symbolic_rows_out.row.x : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_63:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "literal_in.x"}, %[[VAL_64:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "indexed_in.x"}, %[[VAL_65:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "extended_in.x"}, %[[VAL_66:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "matrix_in.x"}, %[[VAL_67:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "rows_in.row.x"}, %[[VAL_68:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "conditional_in.x"}, %[[VAL_69:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "symbolic_value_in.x"}, %[[VAL_70:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "symbolic_index_in.x"}, %[[VAL_71:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "computed_index_in.x"}, %[[VAL_72:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "slice_in.x"}, %[[VAL_73:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "symbolic_rows_in.row.x"}) -> !struct.type<@Main_0::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_0::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_63]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_64]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_65]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_66]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_67]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_79]] }  : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_68]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_69]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_70]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_71]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_72]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_73]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_86]] }  : <[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = function.call @Main_0::@Main_0::@compute(%[[VAL_75]], %[[VAL_76]], %[[VAL_77]], %[[VAL_78]], %[[VAL_80]], %[[VAL_81]], %[[VAL_82]], %[[VAL_83]], %[[VAL_84]], %[[VAL_85]], %[[VAL_87]]) : (!pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>, !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>) -> !struct.type<@Main_0::@Main_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@"$component"] = %[[VAL_88]] : <@Main_0::@"$bus_entry"<[]>>, !struct.type<@Main_0::@Main_0<[]>>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@literal_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_89]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@indexed_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_91]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@extended_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_93]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@matrix_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_95]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@rows_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_97]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_98]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@conditional_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_101:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_100]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_102:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@symbolic_value_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_103:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_102]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_104:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@symbolic_index_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_104]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@computed_index_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_106]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@slice_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_108]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_88]][@symbolic_rows_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_110]][@row] : <[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@literal_out.x] = %[[VAL_90]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@indexed_out.x] = %[[VAL_92]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@extended_out.x] = %[[VAL_94]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@matrix_out.x] = %[[VAL_96]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@rows_out.row.x] = %[[VAL_99]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@conditional_out.x] = %[[VAL_101]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@symbolic_value_out.x] = %[[VAL_103]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@symbolic_index_out.x] = %[[VAL_105]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@computed_index_out.x] = %[[VAL_107]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@slice_out.x] = %[[VAL_109]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_74]][@symbolic_rows_out.row.x] = %[[VAL_112]] : <@Main_0::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_74]] : !struct.type<@Main_0::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_113:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_0::@"$bus_entry"<[]>>, %[[VAL_114:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "literal_in.x"}, %[[VAL_115:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "indexed_in.x"}, %[[VAL_116:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "extended_in.x"}, %[[VAL_117:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "matrix_in.x"}, %[[VAL_118:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "rows_in.row.x"}, %[[VAL_119:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "conditional_in.x"}, %[[VAL_120:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "symbolic_value_in.x"}, %[[VAL_121:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "symbolic_index_in.x"}, %[[VAL_122:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "computed_index_in.x"}, %[[VAL_123:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "slice_in.x"}, %[[VAL_124:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "symbolic_rows_in.row.x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_114]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_115]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_116]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_117]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_118]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_129]] }  : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_119]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_120]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_121]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_134:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_122]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_123]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_136:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_124]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_136]] }  : <[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@"$component"] : <@Main_0::@"$bus_entry"<[]>>, !struct.type<@Main_0::@Main_0<[]>>
// CONCRETE-NEXT:          function.call @Main_0::@Main_0::@constrain(%[[VAL_138]], %[[VAL_125]], %[[VAL_126]], %[[VAL_127]], %[[VAL_128]], %[[VAL_130]], %[[VAL_131]], %[[VAL_132]], %[[VAL_133]], %[[VAL_134]], %[[VAL_135]], %[[VAL_137]]) : (!struct.type<@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>, !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@literal_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_140:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@indexed_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@extended_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@matrix_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@rows_out.row.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@conditional_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_145:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@symbolic_value_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_146:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@symbolic_index_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_147:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@computed_index_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_148:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@slice_out.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_149:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@symbolic_rows_out.row.x] : <@Main_0::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_150:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@literal_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_151:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_139]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_152:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_150]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_153:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_151]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_152]], %[[VAL_153]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_154:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@indexed_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_140]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_154]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_155]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_156]], %[[VAL_157]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_158:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@extended_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_141]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_158]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_159]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_160]], %[[VAL_161]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@matrix_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_142]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_162]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_164]], %[[VAL_165]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@rows_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_167:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_143]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_167]] }  : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_166]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_170:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_168]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_171:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_169]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_172:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_170]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_171]], %[[VAL_172]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_173:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@conditional_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_174:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_144]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_175:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_173]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_176:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_174]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_175]], %[[VAL_176]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_177:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@symbolic_value_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_178:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_145]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_179:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_177]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_180:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_178]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_179]], %[[VAL_180]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_181:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@symbolic_index_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_182:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_146]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_183:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_181]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_182]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_183]], %[[VAL_184]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@computed_index_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_147]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_187:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_185]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_188:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_186]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_187]], %[[VAL_188]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_189:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@slice_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_190:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_148]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_191:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_189]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_192:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_190]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_191]], %[[VAL_192]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_193:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_138]][@symbolic_rows_out] : <@Main_0::@Main_0<[]>>, !pod.type<[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_194:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_149]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_195:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_194]] }  : <[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_196:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_193]][@row] : <[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_197:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_195]][@row] : <[@row: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_198:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_196]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_199:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_197]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_198]], %[[VAL_199]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@"$bus_entry"<[2, 0]>>} {
// TEMPLATED-NEXT:    module @global {
// TEMPLATED-NEXT:      global.def const @array_const_0 : !array.type<2,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// TEMPLATED-NEXT:      global.def const @array_const_1 : !array.type<2,2 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">]
// TEMPLATED-NEXT:      global.def const @array_const_2 : !array.type<2 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">]
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      poly.param @ds : index
// TEMPLATED-NEXT:      poly.param @i
// TEMPLATED-NEXT:      poly.expr @"$bus_array_access([2,3],(1_Sub_1))@1939" {
// TEMPLATED-NEXT:        %[[VAL_0:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:        %[[VAL_1:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:        %[[VAL_2:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_3:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_2 : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:        %[[VAL_4:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_0]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_5:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_4]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_5]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      poly.expr @"$bus_array_access([2,3],(1_Sub_1))@1994" {
// TEMPLATED-NEXT:        %[[VAL_6:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:        %[[VAL_7:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:        %[[VAL_8:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_7]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_9:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_2 : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:        %[[VAL_10:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_6]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_11:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_11]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      poly.expr @"$bus_array_access([2,3],i)@1788" {
// TEMPLATED-NEXT:        %[[VAL_12:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:        %[[VAL_13:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_12]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_14:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_15:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_2 : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:        %[[VAL_16:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_17:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_16]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_18:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_18]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      poly.expr @"$bus_array_access([2,3],i)@1839" {
// TEMPLATED-NEXT:        %[[VAL_19:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:        %[[VAL_20:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_21:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_22:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_2 : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:        %[[VAL_23:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_24:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_23]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_25:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_25]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      poly.expr @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" {
// TEMPLATED-NEXT:        %[[VAL_26:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:        %[[VAL_27:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:        %[[VAL_28:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_27]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_29:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_30:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:        %[[VAL_31:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_32:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_31]], %[[VAL_26]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_33:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_33]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      poly.expr @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" {
// TEMPLATED-NEXT:        %[[VAL_34:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:        %[[VAL_35:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:        %[[VAL_36:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_35]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_37:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_38:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:        %[[VAL_39:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_40:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_39]], %[[VAL_34]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_41:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_41]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      poly.expr @"table[1][0]@550" {
// TEMPLATED-NEXT:        %[[VAL_42:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:        %[[VAL_43:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:        %[[VAL_44:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:        %[[VAL_45:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_44]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_46:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:        %[[VAL_47:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_42]], %[[VAL_43]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_48:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_48]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      poly.expr @"table[1][0]@550_1" {
// TEMPLATED-NEXT:        %[[VAL_49:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:        %[[VAL_50:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:        %[[VAL_51:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:        %[[VAL_52:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_51]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_53:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:        %[[VAL_54:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_49]], %[[VAL_50]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_55:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_55]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @literal_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @indexed_out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @extended_out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @matrix_out : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @rows_out : !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @conditional_out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @symbolic_value_out : !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @symbolic_index_out : !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @computed_index_out : !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @slice_out : !pod.type<[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @symbolic_rows_out : !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_56:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "literal_in"}, %[[VAL_57:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "indexed_in"}, %[[VAL_58:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "extended_in"}, %[[VAL_59:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {function.arg_name = "matrix_in"}, %[[VAL_60:[0-9a-zA-Z_.-]+]]: !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]> {function.arg_name = "rows_in"}, %[[VAL_61:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "conditional_in"}, %[[VAL_62:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]> {function.arg_name = "symbolic_value_in"}, %[[VAL_63:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">>]> {function.arg_name = "symbolic_index_in"}, %[[VAL_64:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">>]> {function.arg_name = "computed_index_in"}, %[[VAL_65:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<@"table[1][0]@550" x !felt.type<"bn128">>]> {function.arg_name = "slice_in"}, %[[VAL_66:[0-9a-zA-Z_.-]+]]: !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>]> {function.arg_name = "symbolic_rows_in"}) -> !struct.type<@Main::@Main<[@ds, @i]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[@ds, @i]>>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],(1_Sub_1))@1939" : index
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_68]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],(1_Sub_1))@1994" : index
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_70]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],i)@1788" : index
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_72]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],i)@1839" : index
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_74]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" : index
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_76]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" : index
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_78]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_80]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = poly.read_const @"table[1][0]@550" : index
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_83]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = poly.read_const @"table[1][0]@550_1" : index
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_85]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@literal_out] = %[[VAL_56]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@indexed_out] = %[[VAL_57]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@extended_out] = %[[VAL_58]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@matrix_out] = %[[VAL_59]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@rows_out] = %[[VAL_60]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@conditional_out] = %[[VAL_61]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@symbolic_value_out] = %[[VAL_62]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_63]] : (!pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">>]>) -> !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@symbolic_index_out] = %[[VAL_89]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_64]] : (!pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">>]>) -> !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@computed_index_out] = %[[VAL_90]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_65]] : (!pod.type<[@x: !array.type<@"table[1][0]@550" x !felt.type<"bn128">>]>) -> !pod.type<[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@slice_out] = %[[VAL_91]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_66]] : (!pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>]>) -> !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_67]][@symbolic_rows_out] = %[[VAL_92]] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          function.return %[[VAL_67]] : !struct.type<@Main::@Main<[@ds, @i]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_93:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[@ds, @i]>>, %[[VAL_94:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "literal_in"}, %[[VAL_95:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "indexed_in"}, %[[VAL_96:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "extended_in"}, %[[VAL_97:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]> {function.arg_name = "matrix_in"}, %[[VAL_98:[0-9a-zA-Z_.-]+]]: !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]> {function.arg_name = "rows_in"}, %[[VAL_99:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "conditional_in"}, %[[VAL_100:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]> {function.arg_name = "symbolic_value_in"}, %[[VAL_101:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">>]> {function.arg_name = "symbolic_index_in"}, %[[VAL_102:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">>]> {function.arg_name = "computed_index_in"}, %[[VAL_103:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !array.type<@"table[1][0]@550" x !felt.type<"bn128">>]> {function.arg_name = "slice_in"}, %[[VAL_104:[0-9a-zA-Z_.-]+]]: !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>]> {function.arg_name = "symbolic_rows_in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],(1_Sub_1))@1939" : index
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_105]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],(1_Sub_1))@1994" : index
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_107]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],i)@1788" : index
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_109]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],i)@1839" : index
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_111]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" : index
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_113]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" : index
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_115]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_117:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_117]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_.-]+]] = poly.read_const @"table[1][0]@550" : index
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_120]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_.-]+]] = poly.read_const @"table[1][0]@550_1" : index
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_122]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@literal_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@indexed_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@extended_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@matrix_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@rows_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@conditional_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@symbolic_value_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@symbolic_index_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@computed_index_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@slice_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_93]][@symbolic_rows_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_.-]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_124]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_94]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_137]], %[[VAL_138]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_125]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_95]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_139]], %[[VAL_140]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_126]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_96]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_141]], %[[VAL_142]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_127]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_144:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_97]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_143]], %[[VAL_144]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_145:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_128]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_98]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_145]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_146]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_147]], %[[VAL_148]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_129]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_99]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_149]], %[[VAL_150]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_130]][@x] : <[@x: !array.type<@ds x !felt.type<"bn128">>]>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_100]][@x] : <[@x: !array.type<@ds x !felt.type<"bn128">>]>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_151]], %[[VAL_152]] : !array.type<@ds x !felt.type<"bn128">>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_101]] : (!pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">>]>) -> !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_131]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_153]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_154]], %[[VAL_155]] : !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_102]] : (!pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">>]>) -> !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_132]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_158:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_156]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_157]], %[[VAL_158]] : !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_103]] : (!pod.type<[@x: !array.type<@"table[1][0]@550" x !felt.type<"bn128">>]>) -> !pod.type<[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_133]][@x] : <[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_159]][@x] : <[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_160]], %[[VAL_161]] : !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_104]] : (!pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>]>) -> !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_134]][@row] : <[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_162]][@row] : <[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@x] : <[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_164]][@x] : <[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_165]], %[[VAL_166]] : !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@Main::@Main<[@ds, @i]>>
// TEMPLATED-NEXT:        struct.member @literal_out.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @indexed_out.x : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @extended_out.x : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @matrix_out.x : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @rows_out.row.x : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @conditional_out.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @symbolic_value_out.x : !array.type<@ds x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @symbolic_index_out.x : !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @computed_index_out.x : !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @slice_out.x : !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @symbolic_rows_out.row.x : !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_167:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "literal_in.x"}, %[[VAL_168:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "indexed_in.x"}, %[[VAL_169:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "extended_in.x"}, %[[VAL_170:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "matrix_in.x"}, %[[VAL_171:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "rows_in.row.x"}, %[[VAL_172:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "conditional_in.x"}, %[[VAL_173:[0-9a-zA-Z_.-]+]]: !array.type<@ds x !felt.type<"bn128">> {function.arg_name = "symbolic_value_in.x"}, %[[VAL_174:[0-9a-zA-Z_.-]+]]: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">> {function.arg_name = "symbolic_index_in.x"}, %[[VAL_175:[0-9a-zA-Z_.-]+]]: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">> {function.arg_name = "computed_index_in.x"}, %[[VAL_176:[0-9a-zA-Z_.-]+]]: !array.type<@"table[1][0]@550" x !felt.type<"bn128">> {function.arg_name = "slice_in.x"}, %[[VAL_177:[0-9a-zA-Z_.-]+]]: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">> {function.arg_name = "symbolic_rows_in.row.x"}) -> !struct.type<@Main::@"$bus_entry"<[@ds, @i]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_178:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@"$bus_entry"<[@ds, @i]>>
// TEMPLATED-NEXT:          %[[VAL_179:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],(1_Sub_1))@1939" : index
// TEMPLATED-NEXT:          %[[VAL_180:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_179]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_181:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],(1_Sub_1))@1994" : index
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_181]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],i)@1788" : index
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_183]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],i)@1839" : index
// TEMPLATED-NEXT:          %[[VAL_186:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_185]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_187:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" : index
// TEMPLATED-NEXT:          %[[VAL_188:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_187]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_189:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" : index
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_189]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_191]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_.-]+]] = poly.read_const @"table[1][0]@550" : index
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_194]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_.-]+]] = poly.read_const @"table[1][0]@550_1" : index
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_196]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_167]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_168]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_169]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_170]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_171]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_202]] }  : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_204:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_172]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_173]] }  : <[@x: !array.type<@ds x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_206:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_174]] }  : <[@x: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_207:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_175]] }  : <[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_208:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_176]] }  : <[@x: !array.type<@"table[1][0]@550" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_209:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_177]] }  : <[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_209]] }  : <[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_.-]+]] = function.call @Main::@Main::@compute(%[[VAL_198]], %[[VAL_199]], %[[VAL_200]], %[[VAL_201]], %[[VAL_203]], %[[VAL_204]], %[[VAL_205]], %[[VAL_206]], %[[VAL_207]], %[[VAL_208]], %[[VAL_210]]) : (!pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<@"table[1][0]@550" x !felt.type<"bn128">>]>, !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>]>) -> !struct.type<@Main::@Main<[@ds, @i]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@"$component"] = %[[VAL_211]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !struct.type<@Main::@Main<[@ds, @i]>>
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@literal_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_212]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@indexed_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_215:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_214]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@extended_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_216]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_218:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@matrix_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_219:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_218]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_220:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@rows_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_221:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_220]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_222:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_221]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_223:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@conditional_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_224:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_223]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_225:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@symbolic_value_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_226:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_225]][@x] : <[@x: !array.type<@ds x !felt.type<"bn128">>]>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_227:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@symbolic_index_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_228:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_227]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@computed_index_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_229]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@slice_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_231]][@x] : <[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@symbolic_rows_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_233]][@row] : <[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_234]][@x] : <[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@literal_out.x] = %[[VAL_213]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@indexed_out.x] = %[[VAL_215]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@extended_out.x] = %[[VAL_217]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@matrix_out.x] = %[[VAL_219]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@rows_out.row.x] = %[[VAL_222]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@conditional_out.x] = %[[VAL_224]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@symbolic_value_out.x] = %[[VAL_226]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@symbolic_index_out.x] = %[[VAL_228]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@computed_index_out.x] = %[[VAL_230]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@slice_out.x] = %[[VAL_232]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_178]][@symbolic_rows_out.row.x] = %[[VAL_235]] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_178]] : !struct.type<@Main::@"$bus_entry"<[@ds, @i]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_236:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@"$bus_entry"<[@ds, @i]>>, %[[VAL_237:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "literal_in.x"}, %[[VAL_238:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "indexed_in.x"}, %[[VAL_239:[0-9a-zA-Z_.-]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "extended_in.x"}, %[[VAL_240:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "matrix_in.x"}, %[[VAL_241:[0-9a-zA-Z_.-]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "rows_in.row.x"}, %[[VAL_242:[0-9a-zA-Z_.-]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "conditional_in.x"}, %[[VAL_243:[0-9a-zA-Z_.-]+]]: !array.type<@ds x !felt.type<"bn128">> {function.arg_name = "symbolic_value_in.x"}, %[[VAL_244:[0-9a-zA-Z_.-]+]]: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">> {function.arg_name = "symbolic_index_in.x"}, %[[VAL_245:[0-9a-zA-Z_.-]+]]: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">> {function.arg_name = "computed_index_in.x"}, %[[VAL_246:[0-9a-zA-Z_.-]+]]: !array.type<@"table[1][0]@550" x !felt.type<"bn128">> {function.arg_name = "slice_in.x"}, %[[VAL_247:[0-9a-zA-Z_.-]+]]: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">> {function.arg_name = "symbolic_rows_in.row.x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_248:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],(1_Sub_1))@1939" : index
// TEMPLATED-NEXT:          %[[VAL_249:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_248]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_250:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],(1_Sub_1))@1994" : index
// TEMPLATED-NEXT:          %[[VAL_251:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_250]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_252:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],i)@1788" : index
// TEMPLATED-NEXT:          %[[VAL_253:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_252]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_254:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access([2,3],i)@1839" : index
// TEMPLATED-NEXT:          %[[VAL_255:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_254]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_256:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" : index
// TEMPLATED-NEXT:          %[[VAL_257:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_256]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_258:[0-9a-zA-Z_.-]+]] = poly.read_const @"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" : index
// TEMPLATED-NEXT:          %[[VAL_259:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_258]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_260:[0-9a-zA-Z_.-]+]] = poly.read_const @ds : index
// TEMPLATED-NEXT:          %[[VAL_261:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_260]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_262:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_263:[0-9a-zA-Z_.-]+]] = poly.read_const @"table[1][0]@550" : index
// TEMPLATED-NEXT:          %[[VAL_264:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_263]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_265:[0-9a-zA-Z_.-]+]] = poly.read_const @"table[1][0]@550_1" : index
// TEMPLATED-NEXT:          %[[VAL_266:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_265]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_267:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_237]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_268:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_238]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_269:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_239]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_270:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_240]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_271:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_241]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_272:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_271]] }  : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_273:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_242]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_274:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_243]] }  : <[@x: !array.type<@ds x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_275:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_244]] }  : <[@x: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_276:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_245]] }  : <[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_277:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_246]] }  : <[@x: !array.type<@"table[1][0]@550" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_278:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_247]] }  : <[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_279:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_278]] }  : <[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_280:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@"$component"] : <@Main::@"$bus_entry"<[@ds, @i]>>, !struct.type<@Main::@Main<[@ds, @i]>>
// TEMPLATED-NEXT:          function.call @Main::@Main::@constrain(%[[VAL_280]], %[[VAL_267]], %[[VAL_268]], %[[VAL_269]], %[[VAL_270]], %[[VAL_272]], %[[VAL_273]], %[[VAL_274]], %[[VAL_275]], %[[VAL_276]], %[[VAL_277]], %[[VAL_279]]) : (!struct.type<@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1788" x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1939" x !felt.type<"bn128">>]>, !pod.type<[@x: !array.type<@"table[1][0]@550" x !felt.type<"bn128">>]>, !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2198" x !felt.type<"bn128">>]>]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_281:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@literal_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_282:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@indexed_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_283:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@extended_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_284:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@matrix_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_285:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@rows_out.row.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_286:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@conditional_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_287:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@symbolic_value_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_288:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@symbolic_index_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_289:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@computed_index_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_290:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@slice_out.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_291:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_236]][@symbolic_rows_out.row.x] : <@Main::@"$bus_entry"<[@ds, @i]>>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_292:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@literal_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_293:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_281]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_294:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_292]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_295:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_293]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_294]], %[[VAL_295]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_296:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@indexed_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_297:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_282]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_298:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_296]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_299:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_297]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_298]], %[[VAL_299]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_300:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@extended_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_301:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_283]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_302:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_300]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_303:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_301]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_302]], %[[VAL_303]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_304:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@matrix_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_305:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_284]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_306:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_304]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_307:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_305]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_306]], %[[VAL_307]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_308:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@rows_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_309:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_285]] }  : <[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_310:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_309]] }  : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_311:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_308]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_312:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_310]][@row] : <[@row: !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_313:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_311]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_314:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_312]][@x] : <[@x: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_313]], %[[VAL_314]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_315:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@conditional_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_316:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_286]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_317:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_315]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_318:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_316]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_317]], %[[VAL_318]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_319:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@symbolic_value_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@ds x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_320:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_287]] }  : <[@x: !array.type<@ds x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_321:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_319]][@x] : <[@x: !array.type<@ds x !felt.type<"bn128">>]>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_322:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_320]][@x] : <[@x: !array.type<@ds x !felt.type<"bn128">>]>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_321]], %[[VAL_322]] : !array.type<@ds x !felt.type<"bn128">>, !array.type<@ds x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_323:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@symbolic_index_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_324:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_288]] }  : <[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_325:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_323]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_326:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_324]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_325]], %[[VAL_326]] : !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>, !array.type<@"$bus_array_access([2,3],i)@1839" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_327:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@computed_index_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_328:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_289]] }  : <[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_329:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_327]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_330:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_328]][@x] : <[@x: !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_329]], %[[VAL_330]] : !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>, !array.type<@"$bus_array_access([2,3],(1_Sub_1))@1994" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_331:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@slice_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_332:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_290]] }  : <[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_333:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_331]][@x] : <[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_334:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_332]][@x] : <[@x: !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>]>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_333]], %[[VAL_334]] : !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>, !array.type<@"table[1][0]@550_1" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_335:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_280]][@symbolic_rows_out] : <@Main::@Main<[@ds, @i]>>, !pod.type<[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_336:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_291]] }  : <[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_337:[0-9a-zA-Z_.-]+]] = pod.new { @row = %[[VAL_336]] }  : <[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_338:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_335]][@row] : <[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_339:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_337]][@row] : <[@row: !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>]>, !pod.type<[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_340:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_338]][@x] : <[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_341:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_339]][@x] : <[@x: !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>]>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_340]], %[[VAL_341]] : !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>, !array.type<@"$bus_array_access({{\[\[}}2,3],[4,5]],i,1)@2259" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
