// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// LLZK generation verifies that each component input receives its declared array type,
// even when the function's maximum return shape is larger than the selected input.
function vector(n) {
    if (n == 2) {
        return [1, 2];
    } else if (n == 4) {
        return [1, 2, 3, 4];
    } else {
        return [1, 2, 3, 4, 5, 6];
    }
}

function matrix(n) {
    if (n == 1) {
        return [[1, 2]];
    } else {
        return [[1, 2, 3], [4, 5, 6]];
    }
}

template Vector(n) {
    signal input in[n];
    signal output out[n];
    out <== in;
}

template Matrix(n, m) {
    signal input in[n][m];
    signal output out[n][m];
    out <== in;
}

template Main() {
    // Mixed component arrays use a separate dispatch branch for each input shape.
    component vectors[3];
    vectors[0] = Vector(2);
    vectors[1] = Vector(4);
    vectors[2] = Vector(6);
    for (var i = 0; i < 3; i++) {
        vectors[i].in <-- vector(2 * (i + 1));
    }

    component matrices[2];
    matrices[0] = Matrix(1, 2);
    matrices[1] = Matrix(2, 3);
    for (var i = 0; i < 2; i++) {
        matrices[i].in <-- matrix(i + 1);
    }

    // Direct, statically indexed, and uniform-array writes share input adaptation.
    component direct = Vector(2);
    direct.in <-- vector(2);
    component directMatrix = Matrix(1, 2);
    directMatrix.in <-- matrix(1);

    component fixed[2];
    fixed[0] = Vector(2);
    fixed[1] = Vector(4);
    fixed[0].in <-- vector(2);
    fixed[1].in <-- vector(4);

    component uniform[2];
    for (var i = 0; i < 2; i++) {
        uniform[i] = Vector(2);
        uniform[i].in <-- vector(2);
    }
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_5::@Main_5<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<1,2 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<2,3 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<2 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_3 : !array.type<4 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_4 : !array.type<6 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @matrix_1 {
// CHECK-NEXT:      function.def @matrix_1(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "n"}) -> !array.type<2,3 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!array.type<2,3 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new  : <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          scf.for %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_8]] step %[[VAL_7]] {
// CHECK-NEXT:            scf.for %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_9]] step %[[VAL_7]] {
// CHECK-NEXT:              %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_10]], %[[VAL_11]]] : <1,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_5]]{{\[}}%[[VAL_10]], %[[VAL_11]]] = %[[VAL_12]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_5]] : !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_3]] : !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @vector_0 {
// CHECK-NEXT:      function.def @vector_0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "n"}) -> !array.type<6 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_14]], %[[VAL_15]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_16]] -> (!array.type<6 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new  : <6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          scf.for %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]] to %[[VAL_22]] step %[[VAL_21]] {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_23]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_23]]] = %[[VAL_24]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_19]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_14]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_26]] -> (!array.type<6 x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.new  : <6 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:            scf.for %[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_30]] to %[[VAL_32]] step %[[VAL_31]] {
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_33]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_29]]{{\[}}%[[VAL_33]]] = %[[VAL_34]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_29]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_4 : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:            scf.yield %[[VAL_35]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_27]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_17]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main_5 {
// CHECK-NEXT:      struct.def @Main_5 {
// CHECK-NEXT:        struct.member @direct : !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:        struct.member @direct$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        struct.member @directMatrix : !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:        struct.member @directMatrix$inputs : !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        struct.member @fixed : !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>
// CHECK-NEXT:        struct.member @fixed$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]> {signal}
// CHECK-NEXT:        struct.member @matrices : !pod.type<[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>
// CHECK-NEXT:        struct.member @matrices$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]> {signal}
// CHECK-NEXT:        struct.member @uniform : !array.type<2 x !struct.type<@Vector_0::@Vector_0<[]>>>
// CHECK-NEXT:        struct.member @uniform$inputs : !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        struct.member @vectors : !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>
// CHECK-NEXT:        struct.member @vectors$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main_5::@Main_5<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_5::@Main_5<[]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_38]], @params = %[[VAL_37]] }  : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_42]], @params = %[[VAL_41]] }  : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_46]], @params = %[[VAL_45]] }  : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_48]], @params = %[[VAL_45]] }  : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_47]], @idx_1 = %[[VAL_49]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_53]], @params = %[[VAL_52]] }  : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_55]], @params = %[[VAL_52]] }  : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_54]], @idx_1 = %[[VAL_56]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_64:[0-9a-zA-Z_\.]+]] = %[[VAL_62]] to %[[VAL_61]] step %[[VAL_63]] {
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_65]], @params = %[[VAL_60]] }  : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_59]]{{\[}}%[[VAL_64]]] = %[[VAL_66]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_69]], @params = %[[VAL_68]] }  : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_71]], @params = %[[VAL_68]] }  : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_73]], @params = %[[VAL_68]] }  : <[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_70]], @idx_1 = %[[VAL_72]], @idx_2 = %[[VAL_74]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_79:[0-9a-zA-Z_\.]+]] = %[[VAL_77]], %[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_75]], %[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_76]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_79]], %[[VAL_82]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_83]]) %[[VAL_79]], %[[VAL_80]], %[[VAL_81]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_85:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_87]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_90]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_92]], %[[VAL_94]] : index
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_93]], %[[VAL_95]] : i1, i1
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_92]], %[[VAL_97]] : index
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_93]], %[[VAL_98]] : i1, i1
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_92]], %[[VAL_100]] : index
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_93]], %[[VAL_101]] : i1, i1
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_102]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_106]][@in] = %[[VAL_91]] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                pod.write %[[VAL_86]][@idx_2] = %[[VAL_106]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@count] : <[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:                %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_107]], %[[VAL_108]] : index
// CHECK-NEXT:                pod.write %[[VAL_105]][@count] = %[[VAL_109]] : <[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_109]], %[[VAL_110]] : index
// CHECK-NEXT:                scf.if %[[VAL_111]] {
// CHECK-NEXT:                  %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@params] : <[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@in] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_114:[0-9a-zA-Z_\.]+]] = function.call @Vector_2::@Vector_2::@compute(%[[VAL_113]]) : (!array.type<6 x !felt.type<"bn128">>) -> !struct.type<@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_105]][@comp] = %[[VAL_114]] : <[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                pod.write %[[VAL_85]][@idx_2] = %[[VAL_105]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_85]], %[[VAL_86]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_115:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_99]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:                  %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  scf.for %[[VAL_122:[0-9a-zA-Z_\.]+]] = %[[VAL_120]] to %[[VAL_119]] step %[[VAL_121]] {
// CHECK-NEXT:                    %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_122]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_118]]{{\[}}%[[VAL_122]]] = %[[VAL_123]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_117]][@in] = %[[VAL_118]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_86]][@idx_1] = %[[VAL_117]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@count] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_124]], %[[VAL_125]] : index
// CHECK-NEXT:                  pod.write %[[VAL_116]][@count] = %[[VAL_126]] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_126]], %[[VAL_127]] : index
// CHECK-NEXT:                  scf.if %[[VAL_128]] {
// CHECK-NEXT:                    %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@params] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_131:[0-9a-zA-Z_\.]+]] = function.call @Vector_1::@Vector_1::@compute(%[[VAL_130]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_116]][@comp] = %[[VAL_131]] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_85]][@idx_1] = %[[VAL_116]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_85]], %[[VAL_86]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_132:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_96]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                    %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    scf.for %[[VAL_139:[0-9a-zA-Z_\.]+]] = %[[VAL_137]] to %[[VAL_136]] step %[[VAL_138]] {
// CHECK-NEXT:                      %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_139]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                      array.write %[[VAL_135]]{{\[}}%[[VAL_139]]] = %[[VAL_140]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_134]][@in] = %[[VAL_135]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_86]][@idx_0] = %[[VAL_134]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@count] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                    %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_141]], %[[VAL_142]] : index
// CHECK-NEXT:                    pod.write %[[VAL_133]][@count] = %[[VAL_143]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_143]], %[[VAL_144]] : index
// CHECK-NEXT:                    scf.if %[[VAL_145]] {
// CHECK-NEXT:                      %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@params] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_148:[0-9a-zA-Z_\.]+]] = function.call @Vector_0::@Vector_0::@compute(%[[VAL_147]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_133]][@comp] = %[[VAL_148]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_85]][@idx_0] = %[[VAL_133]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_85]], %[[VAL_86]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_149:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_150:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_149]], %[[VAL_150]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_132]]#0, %[[VAL_132]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_115]]#0, %[[VAL_115]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_104]]#0, %[[VAL_104]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_152]], %[[VAL_103]]#0, %[[VAL_103]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_155:[0-9a-zA-Z_\.]+]] = %[[VAL_153]], %[[VAL_156:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_157:[0-9a-zA-Z_\.]+]] = %[[VAL_58]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_155]], %[[VAL_158]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_159]]) %[[VAL_155]], %[[VAL_156]], %[[VAL_157]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_160:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_161:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_162:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_160]], %[[VAL_163]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = function.call @matrix_1::@matrix_1(%[[VAL_164]]) : (!felt.type<"bn128">) -> !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_166]], %[[VAL_168]] : index
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_167]], %[[VAL_169]] : i1, i1
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_166]], %[[VAL_171]] : index
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_167]], %[[VAL_172]] : i1, i1
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_173]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_161]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_177]][@in] = %[[VAL_165]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:                pod.write %[[VAL_162]][@idx_1] = %[[VAL_177]] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@count] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_179:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:                %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_178]], %[[VAL_179]] : index
// CHECK-NEXT:                pod.write %[[VAL_176]][@count] = %[[VAL_180]] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_180]], %[[VAL_181]] : index
// CHECK-NEXT:                scf.if %[[VAL_182]] {
// CHECK-NEXT:                  %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@params] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_185:[0-9a-zA-Z_\.]+]] = function.call @Matrix_4::@Matrix_4::@compute(%[[VAL_184]]) : (!array.type<2,3 x !felt.type<"bn128">>) -> !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_176]][@comp] = %[[VAL_185]] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                pod.write %[[VAL_161]][@idx_1] = %[[VAL_176]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_161]], %[[VAL_162]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_186:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_170]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_161]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_189:[0-9a-zA-Z_\.]+]] = array.new  : <1,2 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                  %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  scf.for %[[VAL_194:[0-9a-zA-Z_\.]+]] = %[[VAL_192]] to %[[VAL_190]] step %[[VAL_193]] {
// CHECK-NEXT:                    scf.for %[[VAL_195:[0-9a-zA-Z_\.]+]] = %[[VAL_192]] to %[[VAL_191]] step %[[VAL_193]] {
// CHECK-NEXT:                      %[[VAL_196:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_165]]{{\[}}%[[VAL_194]], %[[VAL_195]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                      array.write %[[VAL_189]]{{\[}}%[[VAL_194]], %[[VAL_195]]] = %[[VAL_196]] : <1,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    }
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_188]][@in] = %[[VAL_189]] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_162]][@idx_0] = %[[VAL_188]] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@count] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                  %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_197]], %[[VAL_198]] : index
// CHECK-NEXT:                  pod.write %[[VAL_187]][@count] = %[[VAL_199]] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_201:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_199]], %[[VAL_200]] : index
// CHECK-NEXT:                  scf.if %[[VAL_201]] {
// CHECK-NEXT:                    %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@params] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_188]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_204:[0-9a-zA-Z_\.]+]] = function.call @Matrix_3::@Matrix_3::@compute(%[[VAL_203]]) : (!array.type<1,2 x !felt.type<"bn128">>) -> !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_187]][@comp] = %[[VAL_204]] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_161]][@idx_0] = %[[VAL_187]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_161]], %[[VAL_162]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_205:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                  %[[VAL_206:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_205]], %[[VAL_206]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_186]]#0, %[[VAL_186]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_175]]#0, %[[VAL_175]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_160]], %[[VAL_207]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_208]], %[[VAL_174]]#0, %[[VAL_174]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_209]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_215:[0-9a-zA-Z_\.]+]] = %[[VAL_213]] to %[[VAL_212]] step %[[VAL_214]] {
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_210]]{{\[}}%[[VAL_215]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_211]]{{\[}}%[[VAL_215]]] = %[[VAL_216]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_40]][@in] = %[[VAL_211]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_217]], %[[VAL_218]] : index
// CHECK-NEXT:          pod.write %[[VAL_39]][@count] = %[[VAL_219]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_219]], %[[VAL_220]] : index
// CHECK-NEXT:          scf.if %[[VAL_221]] {
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@params] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = function.call @Vector_0::@Vector_0::@compute(%[[VAL_223]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_39]][@comp] = %[[VAL_224]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = function.call @matrix_1::@matrix_1(%[[VAL_225]]) : (!felt.type<"bn128">) -> !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = array.new  : <1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_232:[0-9a-zA-Z_\.]+]] = %[[VAL_230]] to %[[VAL_228]] step %[[VAL_231]] {
// CHECK-NEXT:            scf.for %[[VAL_233:[0-9a-zA-Z_\.]+]] = %[[VAL_230]] to %[[VAL_229]] step %[[VAL_231]] {
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_226]]{{\[}}%[[VAL_232]], %[[VAL_233]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_227]]{{\[}}%[[VAL_232]], %[[VAL_233]]] = %[[VAL_234]] : <1,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_44]][@in] = %[[VAL_227]] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@count] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_235]], %[[VAL_236]] : index
// CHECK-NEXT:          pod.write %[[VAL_43]][@count] = %[[VAL_237]] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_237]], %[[VAL_238]] : index
// CHECK-NEXT:          scf.if %[[VAL_239]] {
// CHECK-NEXT:            %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@params] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = function.call @Matrix_3::@Matrix_3::@compute(%[[VAL_241]]) : (!array.type<1,2 x !felt.type<"bn128">>) -> !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:            pod.write %[[VAL_43]][@comp] = %[[VAL_242]] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_243]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_250:[0-9a-zA-Z_\.]+]] = %[[VAL_248]] to %[[VAL_247]] step %[[VAL_249]] {
// CHECK-NEXT:            %[[VAL_251:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_244]]{{\[}}%[[VAL_250]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_246]]{{\[}}%[[VAL_250]]] = %[[VAL_251]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_245]][@in] = %[[VAL_246]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          pod.write %[[VAL_51]][@idx_0] = %[[VAL_245]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@count] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_254]], %[[VAL_255]] : index
// CHECK-NEXT:          pod.write %[[VAL_252]][@count] = %[[VAL_256]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_256]], %[[VAL_257]] : index
// CHECK-NEXT:          scf.if %[[VAL_258]] {
// CHECK-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@params] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_260:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_253]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = function.call @Vector_0::@Vector_0::@compute(%[[VAL_260]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_252]][@comp] = %[[VAL_261]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_50]][@idx_0] = %[[VAL_252]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_262]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_269:[0-9a-zA-Z_\.]+]] = %[[VAL_267]] to %[[VAL_266]] step %[[VAL_268]] {
// CHECK-NEXT:            %[[VAL_270:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_263]]{{\[}}%[[VAL_269]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_265]]{{\[}}%[[VAL_269]]] = %[[VAL_270]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_264]][@in] = %[[VAL_265]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          pod.write %[[VAL_51]][@idx_1] = %[[VAL_264]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_271]][@count] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_273]], %[[VAL_274]] : index
// CHECK-NEXT:          pod.write %[[VAL_271]][@count] = %[[VAL_275]] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_275]], %[[VAL_276]] : index
// CHECK-NEXT:          scf.if %[[VAL_277]] {
// CHECK-NEXT:            %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_271]][@params] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_279:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_272]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = function.call @Vector_1::@Vector_1::@compute(%[[VAL_279]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:            pod.write %[[VAL_271]][@comp] = %[[VAL_280]] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_50]][@idx_1] = %[[VAL_271]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_283:[0-9a-zA-Z_\.]+]] = %[[VAL_281]], %[[VAL_284:[0-9a-zA-Z_\.]+]] = %[[VAL_59]], %[[VAL_285:[0-9a-zA-Z_\.]+]] = %[[VAL_67]]) : (!felt.type<"bn128">, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_283]], %[[VAL_286]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_287]]) %[[VAL_283]], %[[VAL_284]], %[[VAL_285]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_288:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_289:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_290:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_291]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_290]]{{\[}}%[[VAL_293]]] : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_299:[0-9a-zA-Z_\.]+]] = %[[VAL_297]] to %[[VAL_296]] step %[[VAL_298]] {
// CHECK-NEXT:              %[[VAL_300:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_292]]{{\[}}%[[VAL_299]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_295]]{{\[}}%[[VAL_299]]] = %[[VAL_300]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            pod.write %[[VAL_294]][@in] = %[[VAL_295]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_290]]{{\[}}%[[VAL_301]]] = %[[VAL_294]] : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_302:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_303:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_289]]{{\[}}%[[VAL_302]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_304:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_290]]{{\[}}%[[VAL_304]]] : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_306:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_303]][@count] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_307:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_308:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_306]], %[[VAL_307]] : index
// CHECK-NEXT:            pod.write %[[VAL_303]][@count] = %[[VAL_308]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_310:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_308]], %[[VAL_309]] : index
// CHECK-NEXT:            scf.if %[[VAL_310]] {
// CHECK-NEXT:              %[[VAL_311:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_303]][@params] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_305]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_313:[0-9a-zA-Z_\.]+]] = function.call @Vector_0::@Vector_0::@compute(%[[VAL_312]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:              pod.write %[[VAL_303]][@comp] = %[[VAL_313]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_289]]{{\[}}%[[VAL_314]]] = %[[VAL_303]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_288]], %[[VAL_315]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_316]], %[[VAL_289]], %[[VAL_290]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_36]][@direct$inputs] = %[[VAL_40]] : <@Main_5::@Main_5<[]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@comp] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@direct] = %[[VAL_317]] : <@Main_5::@Main_5<[]>>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@directMatrix$inputs] = %[[VAL_44]] : <@Main_5::@Main_5<[]>>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@comp] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@directMatrix] = %[[VAL_318]] : <@Main_5::@Main_5<[]>>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@fixed$inputs] = %[[VAL_51]] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_319]][@comp] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_321:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_321]][@comp] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_320]], @idx_1 = %[[VAL_322]] }  : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@fixed] = %[[VAL_323]] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@matrices$inputs] = %[[VAL_154]]#2 : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_324]][@comp] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_327:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_326]][@comp] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_325]], @idx_1 = %[[VAL_327]] }  : <[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@matrices] = %[[VAL_328]] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@uniform$inputs] = %[[VAL_282]]#2 : <@Main_5::@Main_5<[]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_329:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Vector_0::@Vector_0<[]>>>
// CHECK-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_333:[0-9a-zA-Z_\.]+]] = %[[VAL_331]] to %[[VAL_330]] step %[[VAL_332]] {
// CHECK-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_282]]#1{{\[}}%[[VAL_333]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_334]][@comp] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            array.write %[[VAL_329]]{{\[}}%[[VAL_333]]] = %[[VAL_335]] : <2 x !struct.type<@Vector_0::@Vector_0<[]>>>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_36]][@uniform] = %[[VAL_329]] : <@Main_5::@Main_5<[]>>, !array.type<2 x !struct.type<@Vector_0::@Vector_0<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@vectors$inputs] = %[[VAL_78]]#2 : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_336:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_337:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_336]][@comp] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_338:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_338]][@comp] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          %[[VAL_340:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]]#1[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_341:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@comp] : <[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:          %[[VAL_342:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_337]], @idx_1 = %[[VAL_339]], @idx_2 = %[[VAL_341]] }  : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@vectors] = %[[VAL_342]] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_36]] : !struct.type<@Main_5::@Main_5<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_343:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_5::@Main_5<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_344:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@direct] : <@Main_5::@Main_5<[]>>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_345:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@direct$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@directMatrix] : <@Main_5::@Main_5<[]>>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          %[[VAL_347:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@directMatrix$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_348:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@fixed] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>
// CHECK-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@fixed$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@matrices] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>
// CHECK-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@matrices$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@uniform] : <@Main_5::@Main_5<[]>>, !array.type<2 x !struct.type<@Vector_0::@Vector_0<[]>>>
// CHECK-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@uniform$inputs] : <@Main_5::@Main_5<[]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@vectors] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>
// CHECK-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_343]][@vectors$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_358:[0-9a-zA-Z_\.]+]] = %[[VAL_356]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_359:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_358]], %[[VAL_359]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_360]]) %[[VAL_358]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_361:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_362:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_363:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_361]], %[[VAL_362]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_363]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_364:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_365:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_366:[0-9a-zA-Z_\.]+]] = %[[VAL_364]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_368:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_366]], %[[VAL_367]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_368]]) %[[VAL_366]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_369:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_370:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_371:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_369]], %[[VAL_370]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_371]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_373:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_374:[0-9a-zA-Z_\.]+]] = %[[VAL_372]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_376:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_374]], %[[VAL_375]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_376]]) %[[VAL_374]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_377:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_378:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_379:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_377]], %[[VAL_378]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_379]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_380:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_345]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_0::@Vector_0::@constrain(%[[VAL_344]], %[[VAL_380]]) : (!struct.type<@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_381:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Matrix_3::@Matrix_3::@constrain(%[[VAL_346]], %[[VAL_381]]) : (!struct.type<@Matrix_3::@Matrix_3<[]>>, !array.type<1,2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_382:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_348]][@idx_0] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_383:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_349]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_384:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_383]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_0::@Vector_0::@constrain(%[[VAL_382]], %[[VAL_384]]) : (!struct.type<@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_385:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_348]][@idx_1] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          %[[VAL_386:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_349]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_387:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_386]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_1::@Vector_1::@constrain(%[[VAL_385]], %[[VAL_387]]) : (!struct.type<@Vector_1::@Vector_1<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_388:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_350]][@idx_0] : <[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          %[[VAL_389:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_351]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_390:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_389]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Matrix_3::@Matrix_3::@constrain(%[[VAL_388]], %[[VAL_390]]) : (!struct.type<@Matrix_3::@Matrix_3<[]>>, !array.type<1,2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_391:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_350]][@idx_1] : <[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>, !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:          %[[VAL_392:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_351]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_393:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_392]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Matrix_4::@Matrix_4::@constrain(%[[VAL_391]], %[[VAL_393]]) : (!struct.type<@Matrix_4::@Matrix_4<[]>>, !array.type<2,3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_394:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_395:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_396:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_397:[0-9a-zA-Z_\.]+]] = %[[VAL_395]] to %[[VAL_394]] step %[[VAL_396]] {
// CHECK-NEXT:            %[[VAL_398:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_352]]{{\[}}%[[VAL_397]]] : <2 x !struct.type<@Vector_0::@Vector_0<[]>>>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            %[[VAL_399:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_353]]{{\[}}%[[VAL_397]]] : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_400:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_399]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Vector_0::@Vector_0::@constrain(%[[VAL_398]], %[[VAL_400]]) : (!struct.type<@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_401:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_354]][@idx_0] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_402:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_355]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_403:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_402]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_0::@Vector_0::@constrain(%[[VAL_401]], %[[VAL_403]]) : (!struct.type<@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_404:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_354]][@idx_1] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          %[[VAL_405:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_355]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_406:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_405]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_1::@Vector_1::@constrain(%[[VAL_404]], %[[VAL_406]]) : (!struct.type<@Vector_1::@Vector_1<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_407:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_354]][@idx_2] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>, !struct.type<@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:          %[[VAL_408:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_355]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_409:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_408]][@in] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_2::@Vector_2::@constrain(%[[VAL_407]], %[[VAL_409]]) : (!struct.type<@Vector_2::@Vector_2<[]>>, !array.type<6 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Matrix_3 {
// CHECK-NEXT:      struct.def @Matrix_3 {
// CHECK-NEXT:        struct.member @out : !array.type<1,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_410:[0-9a-zA-Z_\.]+]]: !array.type<1,2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Matrix_3::@Matrix_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_411:[0-9a-zA-Z_\.]+]] = struct.new : <@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_411]][@out] = %[[VAL_410]] : <@Matrix_3::@Matrix_3<[]>>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_411]] : !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_412:[0-9a-zA-Z_\.]+]]: !struct.type<@Matrix_3::@Matrix_3<[]>>, %[[VAL_413:[0-9a-zA-Z_\.]+]]: !array.type<1,2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_414:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_412]][@out] : <@Matrix_3::@Matrix_3<[]>>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_414]], %[[VAL_413]] : !array.type<1,2 x !felt.type<"bn128">>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Matrix_4 {
// CHECK-NEXT:      struct.def @Matrix_4 {
// CHECK-NEXT:        struct.member @out : !array.type<2,3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_415:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Matrix_4::@Matrix_4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_416:[0-9a-zA-Z_\.]+]] = struct.new : <@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_416]][@out] = %[[VAL_415]] : <@Matrix_4::@Matrix_4<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_416]] : !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_417:[0-9a-zA-Z_\.]+]]: !struct.type<@Matrix_4::@Matrix_4<[]>>, %[[VAL_418:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_419:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_417]][@out] : <@Matrix_4::@Matrix_4<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_419]], %[[VAL_418]] : !array.type<2,3 x !felt.type<"bn128">>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Vector_0 {
// CHECK-NEXT:      struct.def @Vector_0 {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_420:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Vector_0::@Vector_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_421:[0-9a-zA-Z_\.]+]] = struct.new : <@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_421]][@out] = %[[VAL_420]] : <@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_421]] : !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_422:[0-9a-zA-Z_\.]+]]: !struct.type<@Vector_0::@Vector_0<[]>>, %[[VAL_423:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_424:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_422]][@out] : <@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_424]], %[[VAL_423]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Vector_1 {
// CHECK-NEXT:      struct.def @Vector_1 {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_425:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Vector_1::@Vector_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_426:[0-9a-zA-Z_\.]+]] = struct.new : <@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_426]][@out] = %[[VAL_425]] : <@Vector_1::@Vector_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_426]] : !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_427:[0-9a-zA-Z_\.]+]]: !struct.type<@Vector_1::@Vector_1<[]>>, %[[VAL_428:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_429:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_427]][@out] : <@Vector_1::@Vector_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_429]], %[[VAL_428]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Vector_2 {
// CHECK-NEXT:      struct.def @Vector_2 {
// CHECK-NEXT:        struct.member @out : !array.type<6 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_430:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Vector_2::@Vector_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_431:[0-9a-zA-Z_\.]+]] = struct.new : <@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_431]][@out] = %[[VAL_430]] : <@Vector_2::@Vector_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_431]] : !struct.type<@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_432:[0-9a-zA-Z_\.]+]]: !struct.type<@Vector_2::@Vector_2<[]>>, %[[VAL_433:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_434:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_432]][@out] : <@Vector_2::@Vector_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_434]], %[[VAL_433]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
