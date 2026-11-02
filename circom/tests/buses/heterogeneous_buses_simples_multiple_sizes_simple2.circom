// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(n){
    signal a[n];
    signal b[n];
}

template A(n){
    Simple(n) input in;
    Simple(n) output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.b;
        out.b <== in.a;
    }
}

template B(n1, n2, n3){
    Simple(n1) input in1;
    Simple(n2) input in2;
    Simple(n3) input in3;
    signal output out[3];

    var sizes[3] = [n1, n2, n3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i]);
        if (i == 0){
            aux[i].in.a <== in1.a;
            aux[i].in.b <== in1.b;
        } else if (i == 1){
            aux[i].in.a <== in2.a;
            aux[i].in.b <== in2.b;
        } else{
            aux[i].in.a <== in3.a;
            aux[i].in.b <== in3.b;
        }
        out[i] <== aux[i].out.b[0];
    }
}

component main = B(2, 3, 2);

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_2::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    module @global {
// CONCRETE-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  2 : <"bn128">]
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_1 {
// CONCRETE-NEXT:      struct.def @A_1 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@a] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_11]][@a] = %[[VAL_12]] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@a] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_11]][@b] = %[[VAL_14]] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_10]][@out] = %[[VAL_11]] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_10]] : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@a] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_19]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@a] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_21]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_2 {
// CONCRETE-NEXT:      struct.def @B_2 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE-NEXT:        struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in1"}, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in2"}, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in3"}) -> !struct.type<@B_2::@B_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@B_2<[]>>
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_29]], @params = %[[VAL_28]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_31]], @params = %[[VAL_28]] }  : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_33]], @params = %[[VAL_28]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_30]], @idx_1 = %[[VAL_32]], @idx_2 = %[[VAL_34]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_35]], %[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_36]], %[[VAL_42:[0-9a-zA-Z_\.]+]] = %[[VAL_38]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_42]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_44]]) %[[VAL_40]], %[[VAL_41]], %[[VAL_42]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_47]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_49]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_53]], %[[VAL_55]] : index
// CONCRETE-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_54]], %[[VAL_56]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_53]], %[[VAL_58]] : index
// CONCRETE-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_54]], %[[VAL_59]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_60]] : i1
// CONCRETE-NEXT:              bool.assert %[[VAL_61]], "incompatible mixed component bus input"
// CONCRETE-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_53]], %[[VAL_62]] : index
// CONCRETE-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_54]], %[[VAL_63]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_64]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                  %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  pod.write %[[VAL_69]][@a] = %[[VAL_51]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  pod.write %[[VAL_68]][@in] = %[[VAL_69]] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  pod.write %[[VAL_46]][@idx_2] = %[[VAL_68]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                  %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                  %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_71]], %[[VAL_72]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_67]][@count] = %[[VAL_73]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_73]], %[[VAL_74]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_75]] {
// CONCRETE-NEXT:                    %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_78:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_77]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_67]][@comp] = %[[VAL_78]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  pod.write %[[VAL_45]][@idx_2] = %[[VAL_67]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_79:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_57]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_82]][@a] = %[[VAL_51]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_81]][@in] = %[[VAL_82]] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_46]][@idx_0] = %[[VAL_81]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                    %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_84]], %[[VAL_85]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_80]][@count] = %[[VAL_86]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_86]], %[[VAL_87]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_88]] {
// CONCRETE-NEXT:                      %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_91:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_90]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_80]][@comp] = %[[VAL_91]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_45]][@idx_0] = %[[VAL_80]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_92:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_93:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_92]], %[[VAL_93]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_79]]#0, %[[VAL_79]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_66]]#0, %[[VAL_66]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_96]], %[[VAL_98]] : index
// CONCRETE-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_97]], %[[VAL_99]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_96]], %[[VAL_101]] : index
// CONCRETE-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_97]], %[[VAL_102]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_103]] : i1
// CONCRETE-NEXT:              bool.assert %[[VAL_104]], "incompatible mixed component bus input"
// CONCRETE-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_96]], %[[VAL_105]] : index
// CONCRETE-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_97]], %[[VAL_106]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_109:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_107]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]]#1[@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                  %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  pod.write %[[VAL_112]][@b] = %[[VAL_94]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  pod.write %[[VAL_111]][@in] = %[[VAL_112]] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  pod.write %[[VAL_65]]#1[@idx_2] = %[[VAL_111]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                  %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                  %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_114]], %[[VAL_115]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_110]][@count] = %[[VAL_116]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_116]], %[[VAL_117]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_118]] {
// CONCRETE-NEXT:                    %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_121:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_120]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_110]][@comp] = %[[VAL_121]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  pod.write %[[VAL_65]]#0[@idx_2] = %[[VAL_110]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_65]]#0, %[[VAL_65]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_122:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_100]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]]#1[@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_125]][@b] = %[[VAL_94]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_124]][@in] = %[[VAL_125]] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_65]]#1[@idx_0] = %[[VAL_124]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                    %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_127]], %[[VAL_128]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_123]][@count] = %[[VAL_129]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_129]], %[[VAL_130]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_131]] {
// CONCRETE-NEXT:                      %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_134:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_133]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_123]][@comp] = %[[VAL_134]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_65]]#0[@idx_0] = %[[VAL_123]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_65]]#0, %[[VAL_65]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_135:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_135]], %[[VAL_136]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_122]]#0, %[[VAL_122]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_109]]#0, %[[VAL_109]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_108]]#0, %[[VAL_108]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_47]], %[[VAL_137]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_138]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@a] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_142]], %[[VAL_144]] : index
// CONCRETE-NEXT:                %[[VAL_146:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_143]], %[[VAL_145]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_147:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_146]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_147]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_142]], %[[VAL_148]] : index
// CONCRETE-NEXT:                %[[VAL_150:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_143]], %[[VAL_149]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_142]], %[[VAL_151]] : index
// CONCRETE-NEXT:                %[[VAL_153:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_143]], %[[VAL_152]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_154:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_153]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_154]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_155:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_156:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_150]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@in] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_159]][@a] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_159]][@a] = %[[VAL_140]] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_158]][@in] = %[[VAL_159]] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_46]][@idx_1] = %[[VAL_158]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@count] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:                    %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_161]], %[[VAL_162]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_157]][@count] = %[[VAL_163]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_165:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_163]], %[[VAL_164]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_165]] {
// CONCRETE-NEXT:                      %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@params] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@in] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_168:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_167]]) : (!pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_157]][@comp] = %[[VAL_168]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_45]][@idx_1] = %[[VAL_157]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_169:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_170:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_169]], %[[VAL_170]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_156]]#0, %[[VAL_156]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_173:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_173]], %[[VAL_175]] : index
// CONCRETE-NEXT:                %[[VAL_177:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_174]], %[[VAL_176]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_178:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_177]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_178]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_179:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_173]], %[[VAL_179]] : index
// CONCRETE-NEXT:                %[[VAL_181:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_174]], %[[VAL_180]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_173]], %[[VAL_182]] : index
// CONCRETE-NEXT:                %[[VAL_184:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_174]], %[[VAL_183]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_185:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_184]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_185]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_186:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_187:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_181]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]]#1[@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@in] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_190]][@b] = %[[VAL_171]] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_189]][@in] = %[[VAL_190]] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_155]]#1[@idx_1] = %[[VAL_189]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_188]][@count] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:                    %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_192]], %[[VAL_193]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_188]][@count] = %[[VAL_194]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_194]], %[[VAL_195]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_196]] {
// CONCRETE-NEXT:                      %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_188]][@params] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@in] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_199:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_198]]) : (!pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_188]][@comp] = %[[VAL_199]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_155]]#0[@idx_1] = %[[VAL_188]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_155]]#0, %[[VAL_155]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_200:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_201:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_200]], %[[VAL_201]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_187]]#0, %[[VAL_187]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_186]]#0, %[[VAL_186]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_204:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_203]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_205:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                %[[VAL_206:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_207:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_204]], %[[VAL_206]] : index
// CONCRETE-NEXT:                %[[VAL_208:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_205]], %[[VAL_207]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_204]], %[[VAL_209]] : index
// CONCRETE-NEXT:                %[[VAL_211:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_205]], %[[VAL_210]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_212:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_211]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_212]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_204]], %[[VAL_213]] : index
// CONCRETE-NEXT:                %[[VAL_215:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_205]], %[[VAL_214]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_216:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_217:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_215]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_220]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_220]][@a] = %[[VAL_202]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_219]][@in] = %[[VAL_220]] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_46]][@idx_2] = %[[VAL_219]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                    %[[VAL_224:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_222]], %[[VAL_223]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_218]][@count] = %[[VAL_224]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_226:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_224]], %[[VAL_225]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_226]] {
// CONCRETE-NEXT:                      %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_229:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_228]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_218]][@comp] = %[[VAL_229]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_45]][@idx_2] = %[[VAL_218]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_230:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_208]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                      %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      pod.write %[[VAL_233]][@a] = %[[VAL_202]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      pod.write %[[VAL_232]][@in] = %[[VAL_233]] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      pod.write %[[VAL_46]][@idx_0] = %[[VAL_232]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                      %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_231]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_236:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                      %[[VAL_237:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_235]], %[[VAL_236]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_231]][@count] = %[[VAL_237]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_239:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_237]], %[[VAL_238]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_239]] {
// CONCRETE-NEXT:                        %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_231]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_241:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                        %[[VAL_242:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_241]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_231]][@comp] = %[[VAL_242]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_45]][@idx_0] = %[[VAL_231]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_243:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                      %[[VAL_244:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_243]], %[[VAL_244]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_230]]#0, %[[VAL_230]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_217]]#0, %[[VAL_217]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_246:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_247:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_246]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_248:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                %[[VAL_249:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_250:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_247]], %[[VAL_249]] : index
// CONCRETE-NEXT:                %[[VAL_251:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_248]], %[[VAL_250]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_252:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_253:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_247]], %[[VAL_252]] : index
// CONCRETE-NEXT:                %[[VAL_254:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_248]], %[[VAL_253]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_255:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_254]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_255]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_256:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_257:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_247]], %[[VAL_256]] : index
// CONCRETE-NEXT:                %[[VAL_258:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_248]], %[[VAL_257]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_259:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_260:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_258]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_261:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]]#1[@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_263:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_262]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_264:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_263]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_263]][@b] = %[[VAL_245]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_262]][@in] = %[[VAL_263]] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_216]]#1[@idx_2] = %[[VAL_262]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                    %[[VAL_265:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_261]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_266:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                    %[[VAL_267:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_265]], %[[VAL_266]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_261]][@count] = %[[VAL_267]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_268:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_269:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_267]], %[[VAL_268]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_269]] {
// CONCRETE-NEXT:                      %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_261]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_262]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_272:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_271]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_261]][@comp] = %[[VAL_272]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_216]]#0[@idx_2] = %[[VAL_261]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_216]]#0, %[[VAL_216]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_273:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_251]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_274:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_275:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]]#1[@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                      %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_276]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      pod.write %[[VAL_276]][@b] = %[[VAL_245]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      pod.write %[[VAL_275]][@in] = %[[VAL_276]] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      pod.write %[[VAL_216]]#1[@idx_0] = %[[VAL_275]] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                      %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_279:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                      %[[VAL_280:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_278]], %[[VAL_279]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_274]][@count] = %[[VAL_280]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_281:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_282:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_280]], %[[VAL_281]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_282]] {
// CONCRETE-NEXT:                        %[[VAL_283:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_284:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                        %[[VAL_285:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_284]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_274]][@comp] = %[[VAL_285]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_216]]#0[@idx_0] = %[[VAL_274]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_216]]#0, %[[VAL_216]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_286:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                      %[[VAL_287:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_286]], %[[VAL_287]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_273]]#0, %[[VAL_273]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_260]]#0, %[[VAL_260]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_259]]#0, %[[VAL_259]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_139]]#0, %[[VAL_139]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_288]], %[[VAL_290]] : index
// CONCRETE-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_289]], %[[VAL_291]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_288]], %[[VAL_293]] : index
// CONCRETE-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_289]], %[[VAL_294]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_288]], %[[VAL_296]] : index
// CONCRETE-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_289]], %[[VAL_297]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_300:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_298]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_302:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_301]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                %[[VAL_303:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_302]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_304:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_303]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_305:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_306:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_305]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_307:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_304]]{{\[}}%[[VAL_306]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.yield %[[VAL_307]] : !felt.type<"bn128">
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_308:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_295]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                  %[[VAL_309:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_310:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_309]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  %[[VAL_311:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_310]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_311]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_313:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_314:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_313]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_315:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_312]]{{\[}}%[[VAL_314]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  scf.yield %[[VAL_315]] : !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_316:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_292]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                    %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_317]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    %[[VAL_319:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_318]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_320:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_319]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_321:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_322:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_321]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_323:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_320]]{{\[}}%[[VAL_322]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    scf.yield %[[VAL_323]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_324:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CONCRETE-NEXT:                    scf.yield %[[VAL_324]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_316]] : !felt.type<"bn128">
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_308]] : !felt.type<"bn128">
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_300]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_325]]] = %[[VAL_299]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_47]], %[[VAL_326]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_50]]#0, %[[VAL_50]]#1, %[[VAL_327]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_26]][@aux$inputs] = %[[VAL_39]]#1 : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_329:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_328]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_330]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_334:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_329]], @idx_1 = %[[VAL_331]], @idx_2 = %[[VAL_333]] }  : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_26]][@aux] = %[[VAL_334]] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_26]][@out] = %[[VAL_27]] : <@B_2::@B_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_26]] : !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_335:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@B_2<[]>>, %[[VAL_336:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in1"}, %[[VAL_337:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in2"}, %[[VAL_338:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_335]][@out] : <@B_2::@B_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_340:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_335]][@aux] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE-NEXT:          %[[VAL_341:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_335]][@aux$inputs] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE-NEXT:          %[[VAL_342:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_343:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_344:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_345:[0-9a-zA-Z_\.]+]] = %[[VAL_343]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_347:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_345]], %[[VAL_346]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_347]]) %[[VAL_345]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_348:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_349:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_350:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_348]], %[[VAL_349]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.if %[[VAL_350]] {
// CONCRETE-NEXT:              %[[VAL_351:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_336]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              %[[VAL_352:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:              %[[VAL_353:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_352]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:              %[[VAL_354:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              constrain.eq %[[VAL_354]], %[[VAL_351]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              %[[VAL_355:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_336]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              %[[VAL_356:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:              %[[VAL_357:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_356]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:              %[[VAL_358:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_357]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              constrain.eq %[[VAL_358]], %[[VAL_355]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_359:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_360:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_348]], %[[VAL_359]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.if %[[VAL_360]] {
// CONCRETE-NEXT:                %[[VAL_361:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_337]][@a] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_362:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                %[[VAL_363:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@in] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_364:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_363]][@a] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                constrain.eq %[[VAL_364]], %[[VAL_361]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_365:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_337]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_366:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                %[[VAL_367:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_366]][@in] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_368:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                constrain.eq %[[VAL_368]], %[[VAL_365]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_369:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_338]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_370:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                %[[VAL_371:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_370]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_372:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                constrain.eq %[[VAL_372]], %[[VAL_369]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_373:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_338]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_374:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:                %[[VAL_375:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_374]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_376:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_375]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                constrain.eq %[[VAL_376]], %[[VAL_373]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_377:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_348]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_378:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_379:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_380:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_377]], %[[VAL_379]] : index
// CONCRETE-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_378]], %[[VAL_380]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_383:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_377]], %[[VAL_382]] : index
// CONCRETE-NEXT:            %[[VAL_384:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_378]], %[[VAL_383]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_385:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_377]], %[[VAL_385]] : index
// CONCRETE-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_378]], %[[VAL_386]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_388:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_389:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_387]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                %[[VAL_390:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                %[[VAL_391:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_390]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_392:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_391]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_393:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_394:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_395:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_392]]{{\[}}%[[VAL_394]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.yield %[[VAL_395]] : !felt.type<"bn128">
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_396:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_384]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                  %[[VAL_397:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  %[[VAL_398:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_397]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_399:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_398]][@b] : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_400:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_401:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_400]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_402:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_399]]{{\[}}%[[VAL_401]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  scf.yield %[[VAL_402]] : !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_403:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_381]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                    %[[VAL_404:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    %[[VAL_405:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_404]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_406:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_405]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_407:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_408:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_407]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_409:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_406]]{{\[}}%[[VAL_408]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    scf.yield %[[VAL_409]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_410:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CONCRETE-NEXT:                    scf.yield %[[VAL_410]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_403]] : !felt.type<"bn128">
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_396]] : !felt.type<"bn128">
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_389]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_411:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_348]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_412:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_339]]{{\[}}%[[VAL_411]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_412]], %[[VAL_388]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_413:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_414:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_348]], %[[VAL_413]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_414]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_415:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_416:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_417:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_416]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_415]], %[[VAL_417]]) : (!struct.type<@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_418:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_419:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_420:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_419]][@in] : <[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_418]], %[[VAL_420]]) : (!struct.type<@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_421:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_422:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@idx_2] : <[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>, !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_423:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_422]][@in] : <[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_421]], %[[VAL_423]]) : (!struct.type<@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_424:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_425:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_426:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_427:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_428:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_429:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B_2::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_430:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_431:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_424]], @b = %[[VAL_425]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_432:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_426]], @b = %[[VAL_427]] }  : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_433:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_428]], @b = %[[VAL_429]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_434:[0-9a-zA-Z_\.]+]] = function.call @B_2::@B_2::@compute(%[[VAL_431]], %[[VAL_432]], %[[VAL_433]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_430]][@"$component"] = %[[VAL_434]] : <@B_2::@"$bus_entry"<[]>>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          %[[VAL_435:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_434]][@out] : <@B_2::@B_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_430]][@out] = %[[VAL_435]] : <@B_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_430]] : !struct.type<@B_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_436:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@"$bus_entry"<[]>>, %[[VAL_437:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_438:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_439:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_440:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_441:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_442:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_443:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_437]], @b = %[[VAL_438]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_444:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_439]], @b = %[[VAL_440]] }  : <[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_445:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_441]], @b = %[[VAL_442]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_446:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_436]][@"$component"] : <@B_2::@"$bus_entry"<[]>>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          function.call @B_2::@B_2::@constrain(%[[VAL_446]], %[[VAL_443]], %[[VAL_444]], %[[VAL_445]]) : (!struct.type<@B_2::@B_2<[]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_447:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_436]][@out] : <@B_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_448:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_446]][@out] : <@B_2::@B_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_448]], %[[VAL_447]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@"$bus_entry"<[2, 3, 2]>>} {
// TEMPLATED-NEXT:    module @global {
// TEMPLATED-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      poly.param @n : index
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_3]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_6]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_8]] -> (!pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>) {
// TEMPLATED-NEXT:            struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@n]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_0]] : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            pod.write %[[VAL_4]][@a] = %[[VAL_10]] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            pod.write %[[VAL_4]][@b] = %[[VAL_12]] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            scf.yield %[[VAL_4]] : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@A::@A<[@n]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@n]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_16]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@out] : <@A::@A<[@n]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_17]], %[[VAL_19]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_20]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_22]] {
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_23]], %[[VAL_24]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_25]], %[[VAL_26]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_28]], %[[VAL_27]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_30]], %[[VAL_29]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      poly.param @n1 : index
// TEMPLATED-NEXT:      poly.param @n2 : index
// TEMPLATED-NEXT:      poly.param @n3 : index
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @aux : !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:        struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]> {function.arg_name = "in1"}, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]> {function.arg_name = "in2"}, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]> {function.arg_name = "in3"}) -> !struct.type<@B::@B<[@n1, @n2, @n3]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_35]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_37]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_39]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_36]], %[[VAL_38]], %[[VAL_40]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_48:[0-9a-zA-Z_\.]+]] = %[[VAL_41]], %[[VAL_49:[0-9a-zA-Z_\.]+]] = %[[VAL_42]], %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_46]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_50]], %[[VAL_51]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_52]]) %[[VAL_48]], %[[VAL_49]], %[[VAL_50]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_54:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, %[[VAL_55:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_56]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_57]] }  : <[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.addi %[[VAL_61]], %[[VAL_63]] : index
// TEMPLATED-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_64]], %[[VAL_65]] : index
// TEMPLATED-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_66]] -> (!struct.type<@A::@A<[#[[$ATTR_0]]]>>) {
// TEMPLATED-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_69]]) {(%[[VAL_71]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              scf.yield %[[VAL_72]] : !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = llzk.nondet : !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              scf.yield %[[VAL_73]] : !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_64]], @params = %[[VAL_59]], @comp = %[[VAL_67]] } (%[[VAL_58]]) : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_53]]{{\[}}%[[VAL_75]]] = %[[VAL_74]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_55]], %[[VAL_76]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_77]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>) {
// TEMPLATED-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@a] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_80]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_80]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_79]] : (!array.type<@n1 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:              pod.write %[[VAL_83]][@a] = %[[VAL_85]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:              pod.write %[[VAL_81]][@in] = %[[VAL_83]] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_86]], %[[VAL_87]] : index
// TEMPLATED-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_88]], %[[VAL_89]], %[[VAL_87]] : index
// TEMPLATED-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_90]], %[[VAL_91]] : index
// TEMPLATED-NEXT:              scf.if %[[VAL_92]] {
// TEMPLATED-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_93]], %[[VAL_94]] : index
// TEMPLATED-NEXT:                pod.write %[[VAL_82]][@count] = %[[VAL_95]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_95]], %[[VAL_96]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_97]] {
// TEMPLATED-NEXT:                  %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_102:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_99]]) {(%[[VAL_101]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  pod.write %[[VAL_82]][@comp] = %[[VAL_102]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              array.write %[[VAL_54]]{{\[}}%[[VAL_80]]] = %[[VAL_81]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:              array.write %[[VAL_53]]{{\[}}%[[VAL_80]]] = %[[VAL_82]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@b] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_104]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_104]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_103]] : (!array.type<@n1 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:              pod.write %[[VAL_107]][@b] = %[[VAL_109]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:              pod.write %[[VAL_105]][@in] = %[[VAL_107]] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_110]], %[[VAL_111]] : index
// TEMPLATED-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_112]], %[[VAL_113]], %[[VAL_111]] : index
// TEMPLATED-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_114]], %[[VAL_115]] : index
// TEMPLATED-NEXT:              scf.if %[[VAL_116]] {
// TEMPLATED-NEXT:                %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_117]], %[[VAL_118]] : index
// TEMPLATED-NEXT:                pod.write %[[VAL_106]][@count] = %[[VAL_119]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_119]], %[[VAL_120]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_121]] {
// TEMPLATED-NEXT:                  %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_123]]) {(%[[VAL_125]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  pod.write %[[VAL_106]][@comp] = %[[VAL_126]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              array.write %[[VAL_54]]{{\[}}%[[VAL_104]]] = %[[VAL_105]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:              array.write %[[VAL_53]]{{\[}}%[[VAL_104]]] = %[[VAL_106]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              scf.yield %[[VAL_53]], %[[VAL_54]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_55]], %[[VAL_127]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_128]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>) {
// TEMPLATED-NEXT:                %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@a] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_131]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_131]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_136:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_130]] : (!array.type<@n2 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_134]][@a] = %[[VAL_136]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_132]][@in] = %[[VAL_134]] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_137]], %[[VAL_138]] : index
// TEMPLATED-NEXT:                %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_139]], %[[VAL_140]], %[[VAL_138]] : index
// TEMPLATED-NEXT:                %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_141]], %[[VAL_142]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_143]] {
// TEMPLATED-NEXT:                  %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_144]], %[[VAL_145]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_133]][@count] = %[[VAL_146]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_147]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_148]] {
// TEMPLATED-NEXT:                    %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_152:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_151]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_153:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_150]]) {(%[[VAL_152]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_133]][@comp] = %[[VAL_153]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_54]]{{\[}}%[[VAL_131]]] = %[[VAL_132]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                array.write %[[VAL_53]]{{\[}}%[[VAL_131]]] = %[[VAL_133]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@b] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_155]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_155]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_160:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_154]] : (!array.type<@n2 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_158]][@b] = %[[VAL_160]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_156]][@in] = %[[VAL_158]] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_161]], %[[VAL_162]] : index
// TEMPLATED-NEXT:                %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_165:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_163]], %[[VAL_164]], %[[VAL_162]] : index
// TEMPLATED-NEXT:                %[[VAL_166:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_165]], %[[VAL_166]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_167]] {
// TEMPLATED-NEXT:                  %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_168]], %[[VAL_169]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_157]][@count] = %[[VAL_170]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_171]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_172]] {
// TEMPLATED-NEXT:                    %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_175]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_177:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_174]]) {(%[[VAL_176]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_157]][@comp] = %[[VAL_177]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_54]]{{\[}}%[[VAL_155]]] = %[[VAL_156]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                array.write %[[VAL_53]]{{\[}}%[[VAL_155]]] = %[[VAL_157]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                scf.yield %[[VAL_53]], %[[VAL_54]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>
// TEMPLATED-NEXT:              } else {
// TEMPLATED-NEXT:                %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@a] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_179]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                %[[VAL_181:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_179]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_184:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_178]] : (!array.type<@n3 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_182]][@a] = %[[VAL_184]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_180]][@in] = %[[VAL_182]] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_185]], %[[VAL_186]] : index
// TEMPLATED-NEXT:                %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_187]], %[[VAL_188]], %[[VAL_186]] : index
// TEMPLATED-NEXT:                %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_189]], %[[VAL_190]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_191]] {
// TEMPLATED-NEXT:                  %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_192]], %[[VAL_193]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_181]][@count] = %[[VAL_194]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_194]], %[[VAL_195]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_196]] {
// TEMPLATED-NEXT:                    %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_197]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_200:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_201:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_198]]) {(%[[VAL_200]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_181]][@comp] = %[[VAL_201]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_54]]{{\[}}%[[VAL_179]]] = %[[VAL_180]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                array.write %[[VAL_53]]{{\[}}%[[VAL_179]]] = %[[VAL_181]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@b] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_203:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_204:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_203]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                %[[VAL_205:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_203]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_208:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_202]] : (!array.type<@n3 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_206]][@b] = %[[VAL_208]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_204]][@in] = %[[VAL_206]] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_209:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_211:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_209]], %[[VAL_210]] : index
// TEMPLATED-NEXT:                %[[VAL_212:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_211]], %[[VAL_212]], %[[VAL_210]] : index
// TEMPLATED-NEXT:                %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_215:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_213]], %[[VAL_214]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_215]] {
// TEMPLATED-NEXT:                  %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_217:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_218:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_216]], %[[VAL_217]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_205]][@count] = %[[VAL_218]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_219:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_220:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_218]], %[[VAL_219]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_220]] {
// TEMPLATED-NEXT:                    %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_224:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_223]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_225:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_222]]) {(%[[VAL_224]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_205]][@comp] = %[[VAL_225]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_54]]{{\[}}%[[VAL_203]]] = %[[VAL_204]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                array.write %[[VAL_53]]{{\[}}%[[VAL_203]]] = %[[VAL_205]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                scf.yield %[[VAL_53]], %[[VAL_54]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              scf.yield %[[VAL_129]]#0, %[[VAL_129]]#1 : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]#0{{\[}}%[[VAL_226]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_227]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_229:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_228]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_230:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_229]][@b] : <[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_232:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_231]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_233:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_230]]{{\[}}%[[VAL_232]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_234:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_43]]{{\[}}%[[VAL_234]]] = %[[VAL_233]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_55]], %[[VAL_235]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_78]]#0, %[[VAL_78]]#1, %[[VAL_236]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_34]][@aux$inputs] = %[[VAL_47]]#1 : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>
// TEMPLATED-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_241:[0-9a-zA-Z_\.]+]] = %[[VAL_239]] to %[[VAL_238]] step %[[VAL_240]] {
// TEMPLATED-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]#0{{\[}}%[[VAL_241]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_243:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_242]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_237]]{{\[}}%[[VAL_241]]] = %[[VAL_243]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_34]][@aux] = %[[VAL_237]] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_34]][@out] = %[[VAL_43]] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_34]] : !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_244:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n1, @n2, @n3]>>, %[[VAL_245:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]> {function.arg_name = "in1"}, %[[VAL_246:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]> {function.arg_name = "in2"}, %[[VAL_247:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_248]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_250]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_252]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_244]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_244]][@aux] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_244]][@aux$inputs] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>
// TEMPLATED-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_249]], %[[VAL_251]], %[[VAL_253]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_261:[0-9a-zA-Z_\.]+]] = %[[VAL_259]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_263:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_261]], %[[VAL_262]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_263]]) %[[VAL_261]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_264:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_266:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_258]]{{\[}}%[[VAL_265]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_266]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_269:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_264]], %[[VAL_268]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.if %[[VAL_269]] {
// TEMPLATED-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]][@a] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_256]]{{\[}}%[[VAL_271]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_272]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_274:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_273]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:              constrain.eq %[[VAL_274]], %[[VAL_270]] : !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_275:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]][@b] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_276:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_277:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_256]]{{\[}}%[[VAL_276]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:              %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_277]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_279:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_278]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:              constrain.eq %[[VAL_279]], %[[VAL_275]] : !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_281:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_264]], %[[VAL_280]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.if %[[VAL_281]] {
// TEMPLATED-NEXT:                %[[VAL_282:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_246]][@a] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_283:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_284:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_256]]{{\[}}%[[VAL_283]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                %[[VAL_285:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_284]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_286:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                constrain.eq %[[VAL_286]], %[[VAL_282]] : !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_287:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_246]][@b] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_288:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_289:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_256]]{{\[}}%[[VAL_288]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                %[[VAL_290:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_289]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_291:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_290]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                constrain.eq %[[VAL_291]], %[[VAL_287]] : !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:              } else {
// TEMPLATED-NEXT:                %[[VAL_292:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@a] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_293:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_294:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_256]]{{\[}}%[[VAL_293]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                %[[VAL_295:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_294]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_296:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_295]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                constrain.eq %[[VAL_296]], %[[VAL_292]] : !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_297:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@b] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_298:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_299:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_256]]{{\[}}%[[VAL_298]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:                %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_299]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                constrain.eq %[[VAL_301]], %[[VAL_297]] : !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_302:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_303:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_255]]{{\[}}%[[VAL_302]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_304:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_303]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_304]][@b] : <[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_307:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_306]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_308:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_305]]{{\[}}%[[VAL_307]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_310:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_254]]{{\[}}%[[VAL_309]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_310]], %[[VAL_308]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_264]], %[[VAL_311]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_312]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_313:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_314:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_315:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_316:[0-9a-zA-Z_\.]+]] = %[[VAL_314]] to %[[VAL_313]] step %[[VAL_315]] {
// TEMPLATED-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_255]]{{\[}}%[[VAL_316]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_256]]{{\[}}%[[VAL_316]]] : <3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>, !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@in] : <[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            function.call @A::@A::@constrain(%[[VAL_317]], %[[VAL_319]]) : (!struct.type<@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_320:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_321:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_322:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_323:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_324:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_325:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          %[[VAL_327:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_327]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_329:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_329]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_331]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_320]], @b = %[[VAL_321]] }  : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_334:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_322]], @b = %[[VAL_323]] }  : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_335:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_324]], @b = %[[VAL_325]] }  : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_336:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_333]], %[[VAL_334]], %[[VAL_335]]) : (!pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>) -> !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_326]][@"$component"] = %[[VAL_336]] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          %[[VAL_337:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_336]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_326]][@out] = %[[VAL_337]] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_326]] : !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_338:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>>, %[[VAL_339:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_340:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_341:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_342:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_343:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_344:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_345:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_345]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_347:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_348:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_347]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_349]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_339]], @b = %[[VAL_340]] }  : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_341]], @b = %[[VAL_342]] }  : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_343]], @b = %[[VAL_344]] }  : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_338]][@"$component"] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_354]], %[[VAL_351]], %[[VAL_352]], %[[VAL_353]]) : (!struct.type<@B::@B<[@n1, @n2, @n3]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_338]][@out] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_354]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_356]], %[[VAL_355]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
