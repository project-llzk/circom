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
// CHECK-NEXT:                  %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_118]][] : <4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:                  %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  scf.for %[[VAL_123:[0-9a-zA-Z_\.]+]] = %[[VAL_121]] to %[[VAL_120]] step %[[VAL_122]] {
// CHECK-NEXT:                    %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_123]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_119]]{{\[}}%[[VAL_123]]] = %[[VAL_124]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_117]][@in] = %[[VAL_119]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_86]][@idx_1] = %[[VAL_117]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@count] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:                  %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_125]], %[[VAL_126]] : index
// CHECK-NEXT:                  pod.write %[[VAL_116]][@count] = %[[VAL_127]] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_127]], %[[VAL_128]] : index
// CHECK-NEXT:                  scf.if %[[VAL_129]] {
// CHECK-NEXT:                    %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@params] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_132:[0-9a-zA-Z_\.]+]] = function.call @Vector_1::@Vector_1::@compute(%[[VAL_131]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_116]][@comp] = %[[VAL_132]] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_85]][@idx_1] = %[[VAL_116]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_85]], %[[VAL_86]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_133:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_96]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_136]][] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                    %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    scf.for %[[VAL_141:[0-9a-zA-Z_\.]+]] = %[[VAL_139]] to %[[VAL_138]] step %[[VAL_140]] {
// CHECK-NEXT:                      %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_141]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                      array.write %[[VAL_137]]{{\[}}%[[VAL_141]]] = %[[VAL_142]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_135]][@in] = %[[VAL_137]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_86]][@idx_0] = %[[VAL_135]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@count] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                    %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_143]], %[[VAL_144]] : index
// CHECK-NEXT:                    pod.write %[[VAL_134]][@count] = %[[VAL_145]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_145]], %[[VAL_146]] : index
// CHECK-NEXT:                    scf.if %[[VAL_147]] {
// CHECK-NEXT:                      %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@params] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_150:[0-9a-zA-Z_\.]+]] = function.call @Vector_0::@Vector_0::@compute(%[[VAL_149]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_134]][@comp] = %[[VAL_150]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_85]][@idx_0] = %[[VAL_134]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_85]], %[[VAL_86]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_151:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_152:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_151]], %[[VAL_152]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_133]]#0, %[[VAL_133]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_115]]#0, %[[VAL_115]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_104]]#0, %[[VAL_104]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_154]], %[[VAL_103]]#0, %[[VAL_103]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_157:[0-9a-zA-Z_\.]+]] = %[[VAL_155]], %[[VAL_158:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_159:[0-9a-zA-Z_\.]+]] = %[[VAL_58]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_157]], %[[VAL_160]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_161]]) %[[VAL_157]], %[[VAL_158]], %[[VAL_159]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_162:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_163:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_164:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_162]], %[[VAL_165]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = function.call @matrix_1::@matrix_1(%[[VAL_166]]) : (!felt.type<"bn128">) -> !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_162]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_168]], %[[VAL_170]] : index
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_169]], %[[VAL_171]] : i1, i1
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_168]], %[[VAL_173]] : index
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_169]], %[[VAL_174]] : i1, i1
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_175]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_179]][@in] = %[[VAL_167]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:                pod.write %[[VAL_164]][@idx_1] = %[[VAL_179]] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@count] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:                %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_180]], %[[VAL_181]] : index
// CHECK-NEXT:                pod.write %[[VAL_178]][@count] = %[[VAL_182]] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_182]], %[[VAL_183]] : index
// CHECK-NEXT:                scf.if %[[VAL_184]] {
// CHECK-NEXT:                  %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@params] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_187:[0-9a-zA-Z_\.]+]] = function.call @Matrix_4::@Matrix_4::@compute(%[[VAL_186]]) : (!array.type<2,3 x !felt.type<"bn128">>) -> !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_178]][@comp] = %[[VAL_187]] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                pod.write %[[VAL_163]][@idx_1] = %[[VAL_178]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_163]], %[[VAL_164]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_188:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_172]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_192:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_191]][] : <1,2 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                  %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  scf.for %[[VAL_197:[0-9a-zA-Z_\.]+]] = %[[VAL_195]] to %[[VAL_193]] step %[[VAL_196]] {
// CHECK-NEXT:                    scf.for %[[VAL_198:[0-9a-zA-Z_\.]+]] = %[[VAL_195]] to %[[VAL_194]] step %[[VAL_196]] {
// CHECK-NEXT:                      %[[VAL_199:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_167]]{{\[}}%[[VAL_197]], %[[VAL_198]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                      array.write %[[VAL_192]]{{\[}}%[[VAL_197]], %[[VAL_198]]] = %[[VAL_199]] : <1,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    }
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_190]][@in] = %[[VAL_192]] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_164]][@idx_0] = %[[VAL_190]] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@count] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_201:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                  %[[VAL_202:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_200]], %[[VAL_201]] : index
// CHECK-NEXT:                  pod.write %[[VAL_189]][@count] = %[[VAL_202]] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_203:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_204:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_202]], %[[VAL_203]] : index
// CHECK-NEXT:                  scf.if %[[VAL_204]] {
// CHECK-NEXT:                    %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@params] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_207:[0-9a-zA-Z_\.]+]] = function.call @Matrix_3::@Matrix_3::@compute(%[[VAL_206]]) : (!array.type<1,2 x !felt.type<"bn128">>) -> !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_189]][@comp] = %[[VAL_207]] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_163]][@idx_0] = %[[VAL_189]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_163]], %[[VAL_164]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_208:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                  %[[VAL_209:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_208]], %[[VAL_209]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_188]]#0, %[[VAL_188]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_177]]#0, %[[VAL_177]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_162]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_211]], %[[VAL_176]]#0, %[[VAL_176]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_212]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_214]][] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_219:[0-9a-zA-Z_\.]+]] = %[[VAL_217]] to %[[VAL_216]] step %[[VAL_218]] {
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_213]]{{\[}}%[[VAL_219]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_215]]{{\[}}%[[VAL_219]]] = %[[VAL_220]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_40]][@in] = %[[VAL_215]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_221]], %[[VAL_222]] : index
// CHECK-NEXT:          pod.write %[[VAL_39]][@count] = %[[VAL_223]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_223]], %[[VAL_224]] : index
// CHECK-NEXT:          scf.if %[[VAL_225]] {
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@params] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = function.call @Vector_0::@Vector_0::@compute(%[[VAL_227]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_39]][@comp] = %[[VAL_228]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = function.call @matrix_1::@matrix_1(%[[VAL_229]]) : (!felt.type<"bn128">) -> !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_231]][] : <1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_237:[0-9a-zA-Z_\.]+]] = %[[VAL_235]] to %[[VAL_233]] step %[[VAL_236]] {
// CHECK-NEXT:            scf.for %[[VAL_238:[0-9a-zA-Z_\.]+]] = %[[VAL_235]] to %[[VAL_234]] step %[[VAL_236]] {
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_230]]{{\[}}%[[VAL_237]], %[[VAL_238]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_232]]{{\[}}%[[VAL_237]], %[[VAL_238]]] = %[[VAL_239]] : <1,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_44]][@in] = %[[VAL_232]] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@count] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_240]], %[[VAL_241]] : index
// CHECK-NEXT:          pod.write %[[VAL_43]][@count] = %[[VAL_242]] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_242]], %[[VAL_243]] : index
// CHECK-NEXT:          scf.if %[[VAL_244]] {
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@params] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = function.call @Matrix_3::@Matrix_3::@compute(%[[VAL_246]]) : (!array.type<1,2 x !felt.type<"bn128">>) -> !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:            pod.write %[[VAL_43]][@comp] = %[[VAL_247]] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_248]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_250]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_251]][] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_256:[0-9a-zA-Z_\.]+]] = %[[VAL_254]] to %[[VAL_253]] step %[[VAL_255]] {
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_256]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_252]]{{\[}}%[[VAL_256]]] = %[[VAL_257]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_250]][@in] = %[[VAL_252]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          pod.write %[[VAL_51]][@idx_0] = %[[VAL_250]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_258]][@count] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_260]], %[[VAL_261]] : index
// CHECK-NEXT:          pod.write %[[VAL_258]][@count] = %[[VAL_262]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_262]], %[[VAL_263]] : index
// CHECK-NEXT:          scf.if %[[VAL_264]] {
// CHECK-NEXT:            %[[VAL_265:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_258]][@params] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_266:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_259]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_267:[0-9a-zA-Z_\.]+]] = function.call @Vector_0::@Vector_0::@compute(%[[VAL_266]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_258]][@comp] = %[[VAL_267]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_50]][@idx_0] = %[[VAL_258]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_268]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_270]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_271]][] : <4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_276:[0-9a-zA-Z_\.]+]] = %[[VAL_274]] to %[[VAL_273]] step %[[VAL_275]] {
// CHECK-NEXT:            %[[VAL_277:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_276]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_272]]{{\[}}%[[VAL_276]]] = %[[VAL_277]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_270]][@in] = %[[VAL_272]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          pod.write %[[VAL_51]][@idx_1] = %[[VAL_270]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_278]][@count] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_280]], %[[VAL_281]] : index
// CHECK-NEXT:          pod.write %[[VAL_278]][@count] = %[[VAL_282]] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_283:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_284:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_282]], %[[VAL_283]] : index
// CHECK-NEXT:          scf.if %[[VAL_284]] {
// CHECK-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_278]][@params] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_279]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = function.call @Vector_1::@Vector_1::@compute(%[[VAL_286]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:            pod.write %[[VAL_278]][@comp] = %[[VAL_287]] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_50]][@idx_1] = %[[VAL_278]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_289:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_290:[0-9a-zA-Z_\.]+]] = %[[VAL_288]], %[[VAL_291:[0-9a-zA-Z_\.]+]] = %[[VAL_59]], %[[VAL_292:[0-9a-zA-Z_\.]+]] = %[[VAL_67]]) : (!felt.type<"bn128">, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_290]], %[[VAL_293]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_294]]) %[[VAL_290]], %[[VAL_291]], %[[VAL_292]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_295:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_296:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_297:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = function.call @vector_0::@vector_0(%[[VAL_298]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_295]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_297]]{{\[}}%[[VAL_300]]] : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_302:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_301]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_303:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_302]][] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_304:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_306:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_307:[0-9a-zA-Z_\.]+]] = %[[VAL_305]] to %[[VAL_304]] step %[[VAL_306]] {
// CHECK-NEXT:              %[[VAL_308:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_299]]{{\[}}%[[VAL_307]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_303]]{{\[}}%[[VAL_307]]] = %[[VAL_308]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            pod.write %[[VAL_301]][@in] = %[[VAL_303]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_295]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_297]]{{\[}}%[[VAL_309]]] = %[[VAL_301]] : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_310:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_295]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_296]]{{\[}}%[[VAL_310]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_295]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_297]]{{\[}}%[[VAL_312]]] : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_311]][@count] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_314]], %[[VAL_315]] : index
// CHECK-NEXT:            pod.write %[[VAL_311]][@count] = %[[VAL_316]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_316]], %[[VAL_317]] : index
// CHECK-NEXT:            scf.if %[[VAL_318]] {
// CHECK-NEXT:              %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_311]][@params] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_320:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_313]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_321:[0-9a-zA-Z_\.]+]] = function.call @Vector_0::@Vector_0::@compute(%[[VAL_320]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:              pod.write %[[VAL_311]][@comp] = %[[VAL_321]] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_322:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_295]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_296]]{{\[}}%[[VAL_322]]] = %[[VAL_311]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_295]], %[[VAL_323]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_324]], %[[VAL_296]], %[[VAL_297]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_36]][@direct$inputs] = %[[VAL_40]] : <@Main_5::@Main_5<[]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@comp] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@direct] = %[[VAL_325]] : <@Main_5::@Main_5<[]>>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@directMatrix$inputs] = %[[VAL_44]] : <@Main_5::@Main_5<[]>>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@comp] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@directMatrix] = %[[VAL_326]] : <@Main_5::@Main_5<[]>>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@fixed$inputs] = %[[VAL_51]] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_327:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_327]][@comp] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_329:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_329]][@comp] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_328]], @idx_1 = %[[VAL_330]] }  : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@fixed] = %[[VAL_331]] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@matrices$inputs] = %[[VAL_156]]#2 : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@comp] : <[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          %[[VAL_334:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Matrix_3::@Matrix_3<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_335:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_334]][@comp] : <[@count: index, @comp: !struct.type<@Matrix_4::@Matrix_4<[]>>, @params: !pod.type<[]>]>, !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:          %[[VAL_336:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_333]], @idx_1 = %[[VAL_335]] }  : <[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@matrices] = %[[VAL_336]] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@uniform$inputs] = %[[VAL_289]]#2 : <@Main_5::@Main_5<[]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_337:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Vector_0::@Vector_0<[]>>>
// CHECK-NEXT:          %[[VAL_338:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_340:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_341:[0-9a-zA-Z_\.]+]] = %[[VAL_339]] to %[[VAL_338]] step %[[VAL_340]] {
// CHECK-NEXT:            %[[VAL_342:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_289]]#1{{\[}}%[[VAL_341]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_343:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_342]][@comp] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            array.write %[[VAL_337]]{{\[}}%[[VAL_341]]] = %[[VAL_343]] : <2 x !struct.type<@Vector_0::@Vector_0<[]>>>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_36]][@uniform] = %[[VAL_337]] : <@Main_5::@Main_5<[]>>, !array.type<2 x !struct.type<@Vector_0::@Vector_0<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@vectors$inputs] = %[[VAL_78]]#2 : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_344:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_345:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_344]][@comp] : <[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_347:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_346]][@comp] : <[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          %[[VAL_348:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]]#1[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Vector_0::@Vector_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Vector_1::@Vector_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_348]][@comp] : <[@count: index, @comp: !struct.type<@Vector_2::@Vector_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_345]], @idx_1 = %[[VAL_347]], @idx_2 = %[[VAL_349]] }  : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@vectors] = %[[VAL_350]] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_36]] : !struct.type<@Main_5::@Main_5<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_351:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_5::@Main_5<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@direct] : <@Main_5::@Main_5<[]>>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@direct$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@directMatrix] : <@Main_5::@Main_5<[]>>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@directMatrix$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@fixed] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>
// CHECK-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@fixed$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_358:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@matrices] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>
// CHECK-NEXT:          %[[VAL_359:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@matrices$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_360:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@uniform] : <@Main_5::@Main_5<[]>>, !array.type<2 x !struct.type<@Vector_0::@Vector_0<[]>>>
// CHECK-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@uniform$inputs] : <@Main_5::@Main_5<[]>>, !array.type<2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_362:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@vectors] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>
// CHECK-NEXT:          %[[VAL_363:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@vectors$inputs] : <@Main_5::@Main_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_364:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_365:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_366:[0-9a-zA-Z_\.]+]] = %[[VAL_364]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
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
// CHECK-NEXT:          %[[VAL_380:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_381:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_382:[0-9a-zA-Z_\.]+]] = %[[VAL_380]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_383:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_384:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_382]], %[[VAL_383]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_384]]) %[[VAL_382]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_385:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_385]], %[[VAL_386]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_387]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_388:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_0::@Vector_0::@constrain(%[[VAL_352]], %[[VAL_388]]) : (!struct.type<@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_389:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_355]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Matrix_3::@Matrix_3::@constrain(%[[VAL_354]], %[[VAL_389]]) : (!struct.type<@Matrix_3::@Matrix_3<[]>>, !array.type<1,2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_390:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_356]][@idx_0] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_391:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_357]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_392:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_391]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_0::@Vector_0::@constrain(%[[VAL_390]], %[[VAL_392]]) : (!struct.type<@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_393:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_356]][@idx_1] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          %[[VAL_394:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_357]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_395:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_394]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_1::@Vector_1::@constrain(%[[VAL_393]], %[[VAL_395]]) : (!struct.type<@Vector_1::@Vector_1<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_396:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_358]][@idx_0] : <[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>, !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          %[[VAL_397:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_359]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_398:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_397]][@in] : <[@in: !array.type<1,2 x !felt.type<"bn128">>]>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Matrix_3::@Matrix_3::@constrain(%[[VAL_396]], %[[VAL_398]]) : (!struct.type<@Matrix_3::@Matrix_3<[]>>, !array.type<1,2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_399:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_358]][@idx_1] : <[@idx_0: !struct.type<@Matrix_3::@Matrix_3<[]>>, @idx_1: !struct.type<@Matrix_4::@Matrix_4<[]>>]>, !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:          %[[VAL_400:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_359]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<1,2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_401:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_400]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Matrix_4::@Matrix_4::@constrain(%[[VAL_399]], %[[VAL_401]]) : (!struct.type<@Matrix_4::@Matrix_4<[]>>, !array.type<2,3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_402:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_403:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_404:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_405:[0-9a-zA-Z_\.]+]] = %[[VAL_403]] to %[[VAL_402]] step %[[VAL_404]] {
// CHECK-NEXT:            %[[VAL_406:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_360]]{{\[}}%[[VAL_405]]] : <2 x !struct.type<@Vector_0::@Vector_0<[]>>>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:            %[[VAL_407:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_361]]{{\[}}%[[VAL_405]]] : <2 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_408:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_407]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Vector_0::@Vector_0::@constrain(%[[VAL_406]], %[[VAL_408]]) : (!struct.type<@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_409:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_0] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>, !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          %[[VAL_410:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_363]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_411:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_410]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_0::@Vector_0::@constrain(%[[VAL_409]], %[[VAL_411]]) : (!struct.type<@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_412:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_1] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>, !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          %[[VAL_413:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_363]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_414:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_413]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_1::@Vector_1::@constrain(%[[VAL_412]], %[[VAL_414]]) : (!struct.type<@Vector_1::@Vector_1<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_415:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_2] : <[@idx_0: !struct.type<@Vector_0::@Vector_0<[]>>, @idx_1: !struct.type<@Vector_1::@Vector_1<[]>>, @idx_2: !struct.type<@Vector_2::@Vector_2<[]>>]>, !struct.type<@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:          %[[VAL_416:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_363]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_417:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_416]][@in] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector_2::@Vector_2::@constrain(%[[VAL_415]], %[[VAL_417]]) : (!struct.type<@Vector_2::@Vector_2<[]>>, !array.type<6 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Matrix_3 {
// CHECK-NEXT:      struct.def @Matrix_3 {
// CHECK-NEXT:        struct.member @out : !array.type<1,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_418:[0-9a-zA-Z_\.]+]]: !array.type<1,2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Matrix_3::@Matrix_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_419:[0-9a-zA-Z_\.]+]] = struct.new : <@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_419]][@out] = %[[VAL_418]] : <@Matrix_3::@Matrix_3<[]>>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_419]] : !struct.type<@Matrix_3::@Matrix_3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_420:[0-9a-zA-Z_\.]+]]: !struct.type<@Matrix_3::@Matrix_3<[]>>, %[[VAL_421:[0-9a-zA-Z_\.]+]]: !array.type<1,2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_422:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_420]][@out] : <@Matrix_3::@Matrix_3<[]>>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_422]], %[[VAL_421]] : !array.type<1,2 x !felt.type<"bn128">>, !array.type<1,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Matrix_4 {
// CHECK-NEXT:      struct.def @Matrix_4 {
// CHECK-NEXT:        struct.member @out : !array.type<2,3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_423:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Matrix_4::@Matrix_4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_424:[0-9a-zA-Z_\.]+]] = struct.new : <@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_424]][@out] = %[[VAL_423]] : <@Matrix_4::@Matrix_4<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_424]] : !struct.type<@Matrix_4::@Matrix_4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_425:[0-9a-zA-Z_\.]+]]: !struct.type<@Matrix_4::@Matrix_4<[]>>, %[[VAL_426:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_427:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_425]][@out] : <@Matrix_4::@Matrix_4<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_427]], %[[VAL_426]] : !array.type<2,3 x !felt.type<"bn128">>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Vector_0 {
// CHECK-NEXT:      struct.def @Vector_0 {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_428:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Vector_0::@Vector_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_429:[0-9a-zA-Z_\.]+]] = struct.new : <@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_429]][@out] = %[[VAL_428]] : <@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_429]] : !struct.type<@Vector_0::@Vector_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_430:[0-9a-zA-Z_\.]+]]: !struct.type<@Vector_0::@Vector_0<[]>>, %[[VAL_431:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_432:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_430]][@out] : <@Vector_0::@Vector_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_432]], %[[VAL_431]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Vector_1 {
// CHECK-NEXT:      struct.def @Vector_1 {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_433:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Vector_1::@Vector_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_434:[0-9a-zA-Z_\.]+]] = struct.new : <@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_434]][@out] = %[[VAL_433]] : <@Vector_1::@Vector_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_434]] : !struct.type<@Vector_1::@Vector_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_435:[0-9a-zA-Z_\.]+]]: !struct.type<@Vector_1::@Vector_1<[]>>, %[[VAL_436:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_437:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_435]][@out] : <@Vector_1::@Vector_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_437]], %[[VAL_436]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Vector_2 {
// CHECK-NEXT:      struct.def @Vector_2 {
// CHECK-NEXT:        struct.member @out : !array.type<6 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_438:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Vector_2::@Vector_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_439:[0-9a-zA-Z_\.]+]] = struct.new : <@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_439]][@out] = %[[VAL_438]] : <@Vector_2::@Vector_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_439]] : !struct.type<@Vector_2::@Vector_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_440:[0-9a-zA-Z_\.]+]]: !struct.type<@Vector_2::@Vector_2<[]>>, %[[VAL_441:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_442:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_440]][@out] : <@Vector_2::@Vector_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_442]], %[[VAL_441]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
