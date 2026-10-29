// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// Source: https://github.com/costa-group/circom_tests/blob/e71231a7ed131417ae7dd23848aef865cd1947db/incomplete_assignments/correct/function_multiple1/function_multiple1.circom

function multiple_sizes(x){
    if (x == 0){
        return [99,99];
    } else if(x == 1){
        return [1, 1, 1, 1];
    } else{
        return [2, 2, 2, 2, 2, 2];
    }
}

template B(n){
    signal input in[n];
    signal output out[n];
    out <== in;
}

template A(){
    signal x[3] <== [0, 1, 2];

    component comp[3];

    var sizes[3] = [2,4,6];
    comp[0] = B(sizes[0]); // B(2)
    comp[1] = B(sizes[1]); // B(4)
    comp[2] = B(sizes[2]); // B(6)

    signal vale3 <== 3;

    var var0[2] = [99,99];
    var var1[4] = [1, 1, 1, 1];
    var var2[6] = [2, 2, 2, 2, 2, 2];

    for (var iter = 0; iter < 3; iter++){
        // `multiple_sizes` returns `!array.type<6 x !felt.type<"bn128">>` regardless but...
        // comp[0].in has size 2
        // comp[1].in has size 4
        // comp[2].in has size 6
        comp[iter].in <-- multiple_sizes(iter);

        //log("Real output:");
        for (var i = 0; i < sizes[iter]; i++){
            //log("Output[", i, "]", comp[iter].out[i]);
        }

        if (iter == 0){
            comp[iter].out === var0;
        }
        if (iter == 1){
            comp[iter].out === var1;
        }
        if (iter == 2){
            comp[iter].out === var2;
        }
    }

}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_3::@A_3<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 99 : <"bn128">,  99 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<4 x !felt.type<"bn128">> = [ 1 : <"bn128">,  1 : <"bn128">,  1 : <"bn128">,  1 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<6 x !felt.type<"bn128">> = [ 2 : <"bn128">,  2 : <"bn128">,  2 : <"bn128">,  2 : <"bn128">,  2 : <"bn128">,  2 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_3 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  4 : <"bn128">,  6 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @multiple_sizes_0 {
// CHECK-NEXT:      function.def @multiple_sizes_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x"}) -> !array.type<6 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!array.type<6 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new  : <6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          scf.for %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_8]] step %[[VAL_7]] {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_9]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_5]]{{\[}}%[[VAL_9]]] = %[[VAL_10]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_5]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_12]] -> (!array.type<6 x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.new  : <6 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:            scf.for %[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_16]] to %[[VAL_18]] step %[[VAL_17]] {
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_19]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_15]]{{\[}}%[[VAL_19]]] = %[[VAL_20]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_15]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:            scf.yield %[[VAL_21]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_3]] : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @A_3 {
// CHECK-NEXT:      struct.def @A_3 {
// CHECK-NEXT:        struct.member @x : !array.type<3 x !felt.type<"bn128">> {signal}
// CHECK-NEXT:        struct.member @vale3 : !felt.type<"bn128"> {signal}
// CHECK-NEXT:        struct.member @comp : !pod.type<[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>
// CHECK-NEXT:        struct.member @comp$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A_3::@A_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.new : <@A_3::@A_3<[]>>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_25]], @params = %[[VAL_24]] }  : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_27]], @params = %[[VAL_24]] }  : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_29]], @params = %[[VAL_24]] }  : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_26]], @idx_1 = %[[VAL_28]], @idx_2 = %[[VAL_30]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_35]]] = %[[VAL_33]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_38]]] = %[[VAL_36]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_41]]] = %[[VAL_39]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_22]][@vale3] = %[[VAL_43]] : <@A_3::@A_3<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_49:[0-9a-zA-Z_\.]+]] = %[[VAL_31]], %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_32]], %[[VAL_51:[0-9a-zA-Z_\.]+]] = %[[VAL_47]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_51]], %[[VAL_52]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_53]]) %[[VAL_49]], %[[VAL_50]], %[[VAL_51]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_54:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_55:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, %[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = function.call @multiple_sizes_0::@multiple_sizes_0(%[[VAL_56]]) : (!felt.type<"bn128">) -> !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_58]], %[[VAL_60]] : index
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_59]], %[[VAL_61]] : i1, i1
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_58]], %[[VAL_63]] : index
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_59]], %[[VAL_64]] : i1, i1
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_58]], %[[VAL_66]] : index
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_59]], %[[VAL_67]] : i1, i1
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_68]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_72]][@in] = %[[VAL_57]] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                pod.write %[[VAL_55]][@idx_2] = %[[VAL_72]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@count] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:                %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_73]], %[[VAL_74]] : index
// CHECK-NEXT:                pod.write %[[VAL_71]][@count] = %[[VAL_75]] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_75]], %[[VAL_76]] : index
// CHECK-NEXT:                scf.if %[[VAL_77]] {
// CHECK-NEXT:                  %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@params] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@in] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_80:[0-9a-zA-Z_\.]+]] = function.call @B_2::@B_2::@compute(%[[VAL_79]]) : (!array.type<6 x !felt.type<"bn128">>) -> !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_71]][@comp] = %[[VAL_80]] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                pod.write %[[VAL_54]][@idx_2] = %[[VAL_71]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_54]], %[[VAL_55]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_65]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:                  %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  scf.for %[[VAL_88:[0-9a-zA-Z_\.]+]] = %[[VAL_86]] to %[[VAL_85]] step %[[VAL_87]] {
// CHECK-NEXT:                    %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_88]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_84]]{{\[}}%[[VAL_88]]] = %[[VAL_89]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_83]][@in] = %[[VAL_84]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_55]][@idx_1] = %[[VAL_83]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:                  %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_90]], %[[VAL_91]] : index
// CHECK-NEXT:                  pod.write %[[VAL_82]][@count] = %[[VAL_92]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_92]], %[[VAL_93]] : index
// CHECK-NEXT:                  scf.if %[[VAL_94]] {
// CHECK-NEXT:                    %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@params] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_97:[0-9a-zA-Z_\.]+]] = function.call @B_1::@B_1::@compute(%[[VAL_96]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@B_1::@B_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_82]][@comp] = %[[VAL_97]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_54]][@idx_1] = %[[VAL_82]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_54]], %[[VAL_55]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_98:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_62]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                    %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    scf.for %[[VAL_105:[0-9a-zA-Z_\.]+]] = %[[VAL_103]] to %[[VAL_102]] step %[[VAL_104]] {
// CHECK-NEXT:                      %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_105]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                      array.write %[[VAL_101]]{{\[}}%[[VAL_105]]] = %[[VAL_106]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_100]][@in] = %[[VAL_101]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_55]][@idx_0] = %[[VAL_100]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:                    %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_107]], %[[VAL_108]] : index
// CHECK-NEXT:                    pod.write %[[VAL_99]][@count] = %[[VAL_109]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_109]], %[[VAL_110]] : index
// CHECK-NEXT:                    scf.if %[[VAL_111]] {
// CHECK-NEXT:                      %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@params] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_114:[0-9a-zA-Z_\.]+]] = function.call @B_0::@B_0::@compute(%[[VAL_113]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@B_0::@B_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_99]][@comp] = %[[VAL_114]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_54]][@idx_0] = %[[VAL_99]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_54]], %[[VAL_55]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_115:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_116:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_115]], %[[VAL_116]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_98]]#0, %[[VAL_98]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_81]]#0, %[[VAL_81]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_70]]#0, %[[VAL_70]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_119:[0-9a-zA-Z_\.]+]] = %[[VAL_117]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_42]]{{\[}}%[[VAL_120]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_119]], %[[VAL_121]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_122]]) %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_123:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_123]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_56]], %[[VAL_126]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_127]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_56]], %[[VAL_128]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_129]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_56]], %[[VAL_130]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_131]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_69]]#0, %[[VAL_69]]#1, %[[VAL_133]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_22]][@comp$inputs] = %[[VAL_48]]#1 : <@A_3::@A_3<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@comp] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_135]], @idx_1 = %[[VAL_137]], @idx_2 = %[[VAL_139]] }  : <[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_22]][@comp] = %[[VAL_140]] : <@A_3::@A_3<[]>>, !pod.type<[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_22]][@x] = %[[VAL_23]] : <@A_3::@A_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_22]] : !struct.type<@A_3::@A_3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_141:[0-9a-zA-Z_\.]+]]: !struct.type<@A_3::@A_3<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_141]][@x] : <@A_3::@A_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_141]][@vale3] : <@A_3::@A_3<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_141]][@comp] : <@A_3::@A_3<[]>>, !pod.type<[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_141]][@comp$inputs] : <@A_3::@A_3<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_147]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]{{\[}}%[[VAL_148]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_149]], %[[VAL_146]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_151]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]{{\[}}%[[VAL_152]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_153]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]{{\[}}%[[VAL_156]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_157]], %[[VAL_154]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_143]], %[[VAL_159]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_165:[0-9a-zA-Z_\.]+]] = %[[VAL_163]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_165]], %[[VAL_166]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_167]]) %[[VAL_165]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_168:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_171:[0-9a-zA-Z_\.]+]] = %[[VAL_169]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_168]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_158]]{{\[}}%[[VAL_172]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_171]], %[[VAL_173]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_174]]) %[[VAL_171]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_175:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_175]], %[[VAL_176]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_177]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_168]], %[[VAL_178]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_179]] {
// CHECK-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_0] : <[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>, !struct.type<@B_0::@B_0<[]>>
// CHECK-NEXT:              %[[VAL_181:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_180]][@out] : <@B_0::@B_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              constrain.eq %[[VAL_181]], %[[VAL_160]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_183:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_168]], %[[VAL_182]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_183]] {
// CHECK-NEXT:              %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_1] : <[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>, !struct.type<@B_1::@B_1<[]>>
// CHECK-NEXT:              %[[VAL_185:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_184]][@out] : <@B_1::@B_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              constrain.eq %[[VAL_185]], %[[VAL_161]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_168]], %[[VAL_186]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_187]] {
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_2] : <[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>, !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_188]][@out] : <@B_2::@B_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              constrain.eq %[[VAL_189]], %[[VAL_162]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_168]], %[[VAL_190]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_191]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_0] : <[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>, !struct.type<@B_0::@B_0<[]>>
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @B_0::@B_0::@constrain(%[[VAL_192]], %[[VAL_194]]) : (!struct.type<@B_0::@B_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_1] : <[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>, !struct.type<@B_1::@B_1<[]>>
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_196]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @B_1::@B_1::@constrain(%[[VAL_195]], %[[VAL_197]]) : (!struct.type<@B_1::@B_1<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_2] : <[@idx_0: !struct.type<@B_0::@B_0<[]>>, @idx_1: !struct.type<@B_1::@B_1<[]>>, @idx_2: !struct.type<@B_2::@B_2<[]>>]>, !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_2: !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<6 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_199]][@in] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @B_2::@B_2::@constrain(%[[VAL_198]], %[[VAL_200]]) : (!struct.type<@B_2::@B_2<[]>>, !array.type<6 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B_0 {
// CHECK-NEXT:      struct.def @B_0 {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_201:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@B_0::@B_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = struct.new : <@B_0::@B_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_202]][@out] = %[[VAL_201]] : <@B_0::@B_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_202]] : !struct.type<@B_0::@B_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_203:[0-9a-zA-Z_\.]+]]: !struct.type<@B_0::@B_0<[]>>, %[[VAL_204:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_203]][@out] : <@B_0::@B_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_205]], %[[VAL_204]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B_1 {
// CHECK-NEXT:      struct.def @B_1 {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_206:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_207]][@out] = %[[VAL_206]] : <@B_1::@B_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_207]] : !struct.type<@B_1::@B_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_208:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>, %[[VAL_209:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_208]][@out] : <@B_1::@B_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_210]], %[[VAL_209]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B_2 {
// CHECK-NEXT:      struct.def @B_2 {
// CHECK-NEXT:        struct.member @out : !array.type<6 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_211:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@B_2::@B_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@B_2<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_212]][@out] = %[[VAL_211]] : <@B_2::@B_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_212]] : !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_213:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@B_2<[]>>, %[[VAL_214:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_213]][@out] : <@B_2::@B_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_215]], %[[VAL_214]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
