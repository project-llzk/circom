// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// Array of buses with different sizes as inputs
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(n){
    signal a[n];
    signal b[n];
}

template A(n, m){
    Simple(n) input in[m];
    Simple(n) output out[m];

    if (n % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < n; i++){
            out[i].a <== in[i].b;
            out[i].b <== in[i].a;
        }
    }
}

template B(n1, m1, n2, m2, n3, m3){
    Simple(n1) input in1[m1];
    Simple(n2) input in2[m2];
    Simple(n3) input in3[m3];
    signal output out[3];

    var sizes[3] = [n1, n2, n3];
    var sizes_m[3] = [m1, m2, m3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i], sizes_m[i]);
        for (var j = 0; j < sizes[i]; j++){
            for (var j_m = 0; j_m < sizes_m[i]; j_m++){
                if (i == 0){
                    aux[i].in[j_m].a[j] <== in1[j_m].a[j];
                    aux[i].in[j_m].b[j] <== in1[j_m].b[j];
                } else if (i == 1){
                    aux[i].in[j_m].a[j] <== in2[j_m].a[j];
                    aux[i].in[j_m].b[j] <== in2[j_m].b[j];
                } else{
                    aux[i].in[j_m].a[j] <== in3[j_m].a[j];
                    aux[i].in[j_m].b[j] <== in3[j_m].b[j];
                }
            }
        }
        out[i] <== aux[i].out[0].b[0];
    }
}

component main = B(2, 2, 2, 2, 2, 2);

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_1::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    module @global {
// CONCRETE-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  2 : <"bn128">,  2 : <"bn128">]
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_5]] step %[[VAL_7]] {
// CONCRETE-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_8]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_8]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_11]], %[[VAL_12]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_13]], %[[VAL_14]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux : !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:        struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in1"}, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in2"}, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in3"}) -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_23]] to %[[VAL_22]] step %[[VAL_24]] {
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_26]], @params = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            array.write %[[VAL_20]]{{\[}}%[[VAL_25]]] = %[[VAL_27]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_28]], %[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_31]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_35]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_37]]) %[[VAL_33]], %[[VAL_34]], %[[VAL_35]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, %[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_38]], %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_39]], %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_41]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) {
// CONCRETE-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_45]], %[[VAL_46]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_47]]) %[[VAL_43]], %[[VAL_44]], %[[VAL_45]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_49:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_53:[0-9a-zA-Z_\.]+]] = %[[VAL_48]], %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_49]], %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_51]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) {
// CONCRETE-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_55]], %[[VAL_56]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.condition(%[[VAL_57]]) %[[VAL_53]], %[[VAL_54]], %[[VAL_55]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:              } do {
// CONCRETE-NEXT:              ^bb0(%[[VAL_58:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_59:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, %[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_40]], %[[VAL_61]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_62]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>) {
// CONCRETE-NEXT:                  %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_64]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_67]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_70]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_70]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_74]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_77]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  array.write %[[VAL_76]]{{\[}}%[[VAL_77]]] = %[[VAL_68]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  pod.write %[[VAL_75]][@a] = %[[VAL_76]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  array.write %[[VAL_73]]{{\[}}%[[VAL_74]]] = %[[VAL_75]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  pod.write %[[VAL_71]][@in] = %[[VAL_73]] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_79]], %[[VAL_80]] : index
// CONCRETE-NEXT:                  %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_81]], %[[VAL_82]], %[[VAL_80]] : index
// CONCRETE-NEXT:                  %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_83]], %[[VAL_84]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_85]] {
// CONCRETE-NEXT:                    %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_86]], %[[VAL_87]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_72]][@count] = %[[VAL_88]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_88]], %[[VAL_89]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_90]] {
// CONCRETE-NEXT:                      %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      %[[VAL_93:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_92]]) : (!array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_72]][@comp] = %[[VAL_93]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  array.write %[[VAL_59]]{{\[}}%[[VAL_70]]] = %[[VAL_71]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  array.write %[[VAL_58]]{{\[}}%[[VAL_70]]] = %[[VAL_72]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_94]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_97]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_99]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_100]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_100]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_104]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_107]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  array.write %[[VAL_106]]{{\[}}%[[VAL_107]]] = %[[VAL_98]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  pod.write %[[VAL_105]][@b] = %[[VAL_106]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  array.write %[[VAL_103]]{{\[}}%[[VAL_104]]] = %[[VAL_105]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  pod.write %[[VAL_101]][@in] = %[[VAL_103]] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_109]], %[[VAL_110]] : index
// CONCRETE-NEXT:                  %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_111]], %[[VAL_112]], %[[VAL_110]] : index
// CONCRETE-NEXT:                  %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_113]], %[[VAL_114]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_115]] {
// CONCRETE-NEXT:                    %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_116]], %[[VAL_117]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_102]][@count] = %[[VAL_118]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_118]], %[[VAL_119]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_120]] {
// CONCRETE-NEXT:                      %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      %[[VAL_123:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_122]]) : (!array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_102]][@comp] = %[[VAL_123]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  array.write %[[VAL_59]]{{\[}}%[[VAL_100]]] = %[[VAL_101]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  array.write %[[VAL_58]]{{\[}}%[[VAL_100]]] = %[[VAL_102]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_58]], %[[VAL_59]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_125:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_40]], %[[VAL_124]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_125]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>) {
// CONCRETE-NEXT:                    %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_127]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_130]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_133:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_132]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_133]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_133]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_137]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_141:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_140]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    array.write %[[VAL_139]]{{\[}}%[[VAL_140]]] = %[[VAL_131]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    pod.write %[[VAL_138]][@a] = %[[VAL_139]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    array.write %[[VAL_136]]{{\[}}%[[VAL_137]]] = %[[VAL_138]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_134]][@in] = %[[VAL_136]] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_142]], %[[VAL_143]] : index
// CONCRETE-NEXT:                    %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_144]], %[[VAL_145]], %[[VAL_143]] : index
// CONCRETE-NEXT:                    %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_147]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_148]] {
// CONCRETE-NEXT:                      %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                      %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_149]], %[[VAL_150]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_135]][@count] = %[[VAL_151]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_151]], %[[VAL_152]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_153]] {
// CONCRETE-NEXT:                        %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                        %[[VAL_156:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_155]]) : (!array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_135]][@comp] = %[[VAL_156]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    array.write %[[VAL_59]]{{\[}}%[[VAL_133]]] = %[[VAL_134]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    array.write %[[VAL_58]]{{\[}}%[[VAL_133]]] = %[[VAL_135]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_157:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_157]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_161:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_160]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_163:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_162]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_164:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_163]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_163]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_168:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_166]]{{\[}}%[[VAL_167]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_171:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_170]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    array.write %[[VAL_169]]{{\[}}%[[VAL_170]]] = %[[VAL_161]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    pod.write %[[VAL_168]][@b] = %[[VAL_169]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    array.write %[[VAL_166]]{{\[}}%[[VAL_167]]] = %[[VAL_168]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_164]][@in] = %[[VAL_166]] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_172]], %[[VAL_173]] : index
// CONCRETE-NEXT:                    %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_174]], %[[VAL_175]], %[[VAL_173]] : index
// CONCRETE-NEXT:                    %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_176]], %[[VAL_177]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_178]] {
// CONCRETE-NEXT:                      %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                      %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_179]], %[[VAL_180]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_165]][@count] = %[[VAL_181]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_181]], %[[VAL_182]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_183]] {
// CONCRETE-NEXT:                        %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                        %[[VAL_186:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_185]]) : (!array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_165]][@comp] = %[[VAL_186]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    array.write %[[VAL_59]]{{\[}}%[[VAL_163]]] = %[[VAL_164]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    array.write %[[VAL_58]]{{\[}}%[[VAL_163]]] = %[[VAL_165]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_58]], %[[VAL_59]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_187:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_188:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_187]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_188]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_190:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_189]]{{\[}}%[[VAL_190]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_192]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_194:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_193]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_195:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_193]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_198:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_196]]{{\[}}%[[VAL_197]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_200:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_201:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_199]]{{\[}}%[[VAL_200]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    array.write %[[VAL_199]]{{\[}}%[[VAL_200]]] = %[[VAL_191]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    pod.write %[[VAL_198]][@a] = %[[VAL_199]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    array.write %[[VAL_196]]{{\[}}%[[VAL_197]]] = %[[VAL_198]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_194]][@in] = %[[VAL_196]] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_195]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_203:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_204:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_202]], %[[VAL_203]] : index
// CONCRETE-NEXT:                    %[[VAL_205:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_206:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_204]], %[[VAL_205]], %[[VAL_203]] : index
// CONCRETE-NEXT:                    %[[VAL_207:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_208:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_206]], %[[VAL_207]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_208]] {
// CONCRETE-NEXT:                      %[[VAL_209:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_195]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                      %[[VAL_211:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_209]], %[[VAL_210]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_195]][@count] = %[[VAL_211]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_212:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_211]], %[[VAL_212]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_213]] {
// CONCRETE-NEXT:                        %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_195]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                        %[[VAL_216:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_215]]) : (!array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_195]][@comp] = %[[VAL_216]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    array.write %[[VAL_59]]{{\[}}%[[VAL_193]]] = %[[VAL_194]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    array.write %[[VAL_58]]{{\[}}%[[VAL_193]]] = %[[VAL_195]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_217:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_218:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_217]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_220:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_221:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_219]]{{\[}}%[[VAL_220]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_223:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_222]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_224:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_223]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_223]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_224]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_227:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_228:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_226]]{{\[}}%[[VAL_227]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_228]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_230:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_231:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_230]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    array.write %[[VAL_229]]{{\[}}%[[VAL_230]]] = %[[VAL_221]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    pod.write %[[VAL_228]][@b] = %[[VAL_229]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    array.write %[[VAL_226]]{{\[}}%[[VAL_227]]] = %[[VAL_228]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_224]][@in] = %[[VAL_226]] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_233:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_234:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_232]], %[[VAL_233]] : index
// CONCRETE-NEXT:                    %[[VAL_235:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_236:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_234]], %[[VAL_235]], %[[VAL_233]] : index
// CONCRETE-NEXT:                    %[[VAL_237:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_236]], %[[VAL_237]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_238]] {
// CONCRETE-NEXT:                      %[[VAL_239:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_240:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                      %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_239]], %[[VAL_240]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_225]][@count] = %[[VAL_241]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_243:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_241]], %[[VAL_242]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_243]] {
// CONCRETE-NEXT:                        %[[VAL_244:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_224]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                        %[[VAL_246:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_245]]) : (!array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_225]][@comp] = %[[VAL_246]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    array.write %[[VAL_59]]{{\[}}%[[VAL_223]]] = %[[VAL_224]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    array.write %[[VAL_58]]{{\[}}%[[VAL_223]]] = %[[VAL_225]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_58]], %[[VAL_59]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_126]]#0, %[[VAL_126]]#1 : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_60]], %[[VAL_247]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.yield %[[VAL_63]]#0, %[[VAL_63]]#1, %[[VAL_248]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_50]], %[[VAL_249]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_52]]#0, %[[VAL_52]]#1, %[[VAL_250]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_251:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_252:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_42]]#0{{\[}}%[[VAL_251]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_253]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:            %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_256:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_254]]{{\[}}%[[VAL_256]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_257]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_260:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_259]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_258]]{{\[}}%[[VAL_260]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_262]]] = %[[VAL_261]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_264:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_263]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_42]]#0, %[[VAL_42]]#1, %[[VAL_264]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_18]][@aux$inputs] = %[[VAL_32]]#1 : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_269:[0-9a-zA-Z_\.]+]] = %[[VAL_267]] to %[[VAL_266]] step %[[VAL_268]] {
// CONCRETE-NEXT:            %[[VAL_270:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]#0{{\[}}%[[VAL_269]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_270]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            array.write %[[VAL_265]]{{\[}}%[[VAL_269]]] = %[[VAL_271]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_18]][@aux] = %[[VAL_265]] : <@B_1::@B_1<[]>>, !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          struct.writem %[[VAL_18]][@out] = %[[VAL_19]] : <@B_1::@B_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_18]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_272:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>, %[[VAL_273:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in1"}, %[[VAL_274:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in2"}, %[[VAL_275:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_272]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_272]][@aux] : <@B_1::@B_1<[]>>, !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_272]][@aux$inputs] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>
// CONCRETE-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_283:[0-9a-zA-Z_\.]+]] = %[[VAL_281]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_283]], %[[VAL_284]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_285]]) %[[VAL_283]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_286:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_289:[0-9a-zA-Z_\.]+]] = %[[VAL_287]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_289]], %[[VAL_290]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_291]]) %[[VAL_289]] : !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_292:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_295:[0-9a-zA-Z_\.]+]] = %[[VAL_293]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:                %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_297:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_295]], %[[VAL_296]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.condition(%[[VAL_297]]) %[[VAL_295]] : !felt.type<"bn128">
// CONCRETE-NEXT:              } do {
// CONCRETE-NEXT:              ^bb0(%[[VAL_298:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:                %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_300:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_286]], %[[VAL_299]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.if %[[VAL_300]] {
// CONCRETE-NEXT:                  %[[VAL_301:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_302:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_273]]{{\[}}%[[VAL_301]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_303:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_302]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_304:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_305:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_303]]{{\[}}%[[VAL_304]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_307:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_306]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_308:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_307]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  %[[VAL_309:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_308]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_310:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_309]]{{\[}}%[[VAL_310]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_311]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_313:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_314:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_312]]{{\[}}%[[VAL_313]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_314]], %[[VAL_305]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_315:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_316:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_273]]{{\[}}%[[VAL_315]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_316]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_318:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_319:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_317]]{{\[}}%[[VAL_318]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_320:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_320]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_322:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_321]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  %[[VAL_323:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_322]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_324:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_325:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_323]]{{\[}}%[[VAL_324]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_326:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_325]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_327:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_328:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_326]]{{\[}}%[[VAL_327]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_328]], %[[VAL_319]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_330:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_286]], %[[VAL_329]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  scf.if %[[VAL_330]] {
// CONCRETE-NEXT:                    %[[VAL_331:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_332:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_274]]{{\[}}%[[VAL_331]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_334:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_333]]{{\[}}%[[VAL_334]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_336:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_337:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_336]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_338:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_337]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_339:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_338]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_340:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_341:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_339]]{{\[}}%[[VAL_340]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_342:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_343:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_344:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_342]]{{\[}}%[[VAL_343]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_344]], %[[VAL_335]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_345:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_346:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_274]]{{\[}}%[[VAL_345]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_347:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_346]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_348:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_349:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_347]]{{\[}}%[[VAL_348]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_350:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_351:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_350]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_352:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_351]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_353:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_352]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_354:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_355:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_353]]{{\[}}%[[VAL_354]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_356:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_355]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_357:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_358:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_356]]{{\[}}%[[VAL_357]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_358]], %[[VAL_349]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_359:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_360:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_275]]{{\[}}%[[VAL_359]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_361:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_360]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_362:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_363:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_361]]{{\[}}%[[VAL_362]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_364:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_365:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_364]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_366:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_365]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_367:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_366]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_368:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_369:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_367]]{{\[}}%[[VAL_368]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_370:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_369]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_371:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_372:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_370]]{{\[}}%[[VAL_371]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_372]], %[[VAL_363]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_373:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_374:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_275]]{{\[}}%[[VAL_373]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_375:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_374]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_376:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_377:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_375]]{{\[}}%[[VAL_376]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_378:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_379:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_378]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_380:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_379]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_381:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_380]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_382:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_383:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_381]]{{\[}}%[[VAL_382]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_384:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_383]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_385:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_386:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_384]]{{\[}}%[[VAL_385]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_386]], %[[VAL_377]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                %[[VAL_387:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_388:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_298]], %[[VAL_387]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.yield %[[VAL_388]] : !felt.type<"bn128">
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_389:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_390:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_292]], %[[VAL_389]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_390]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_391:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_392:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_277]]{{\[}}%[[VAL_391]]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_393:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_392]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:            %[[VAL_394:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_395:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_394]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_396:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_393]]{{\[}}%[[VAL_395]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_397:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_396]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_398:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_399:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_398]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_400:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_397]]{{\[}}%[[VAL_399]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_401:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_402:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_276]]{{\[}}%[[VAL_401]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_402]], %[[VAL_400]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_403:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_404:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_286]], %[[VAL_403]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_404]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_405:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_406:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_407:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_408:[0-9a-zA-Z_\.]+]] = %[[VAL_406]] to %[[VAL_405]] step %[[VAL_407]] {
// CONCRETE-NEXT:            %[[VAL_409:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_277]]{{\[}}%[[VAL_408]]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_410:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_408]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:            %[[VAL_411:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_410]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:            function.call @A_0::@A_0::@constrain(%[[VAL_409]], %[[VAL_411]]) : (!struct.type<@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> ()
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_412:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_413:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_414:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_415:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_416:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_417:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B_1::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_418:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_419:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_420:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_421:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_422:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_423:[0-9a-zA-Z_\.]+]] = %[[VAL_421]] to %[[VAL_420]] step %[[VAL_422]] {
// CONCRETE-NEXT:            %[[VAL_424:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_412]]{{\[}}%[[VAL_423]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_425:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_413]]{{\[}}%[[VAL_423]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_426:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_424]], @b = %[[VAL_425]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_419]]{{\[}}%[[VAL_423]]] = %[[VAL_426]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_427:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_428:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_429:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_430:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_431:[0-9a-zA-Z_\.]+]] = %[[VAL_429]] to %[[VAL_428]] step %[[VAL_430]] {
// CONCRETE-NEXT:            %[[VAL_432:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_414]]{{\[}}%[[VAL_431]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_433:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_415]]{{\[}}%[[VAL_431]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_434:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_432]], @b = %[[VAL_433]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_427]]{{\[}}%[[VAL_431]]] = %[[VAL_434]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_435:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_436:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_437:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_438:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_439:[0-9a-zA-Z_\.]+]] = %[[VAL_437]] to %[[VAL_436]] step %[[VAL_438]] {
// CONCRETE-NEXT:            %[[VAL_440:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_416]]{{\[}}%[[VAL_439]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_441:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_417]]{{\[}}%[[VAL_439]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_442:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_440]], @b = %[[VAL_441]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_435]]{{\[}}%[[VAL_439]]] = %[[VAL_442]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_443:[0-9a-zA-Z_\.]+]] = function.call @B_1::@B_1::@compute(%[[VAL_419]], %[[VAL_427]], %[[VAL_435]]) : (!array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_418]][@"$component"] = %[[VAL_443]] : <@B_1::@"$bus_entry"<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_444:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_443]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_418]][@out] = %[[VAL_444]] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_418]] : !struct.type<@B_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_445:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@"$bus_entry"<[]>>, %[[VAL_446:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_447:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_448:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_449:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_450:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_451:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_452:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_453:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_454:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_455:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_456:[0-9a-zA-Z_\.]+]] = %[[VAL_454]] to %[[VAL_453]] step %[[VAL_455]] {
// CONCRETE-NEXT:            %[[VAL_457:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_446]]{{\[}}%[[VAL_456]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_458:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_447]]{{\[}}%[[VAL_456]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_459:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_457]], @b = %[[VAL_458]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_452]]{{\[}}%[[VAL_456]]] = %[[VAL_459]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_460:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_461:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_462:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_463:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_464:[0-9a-zA-Z_\.]+]] = %[[VAL_462]] to %[[VAL_461]] step %[[VAL_463]] {
// CONCRETE-NEXT:            %[[VAL_465:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_448]]{{\[}}%[[VAL_464]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_466:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_449]]{{\[}}%[[VAL_464]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_467:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_465]], @b = %[[VAL_466]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_460]]{{\[}}%[[VAL_464]]] = %[[VAL_467]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_468:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_469:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_470:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_471:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_472:[0-9a-zA-Z_\.]+]] = %[[VAL_470]] to %[[VAL_469]] step %[[VAL_471]] {
// CONCRETE-NEXT:            %[[VAL_473:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_450]]{{\[}}%[[VAL_472]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_474:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_451]]{{\[}}%[[VAL_472]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_475:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_473]], @b = %[[VAL_474]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_468]]{{\[}}%[[VAL_472]]] = %[[VAL_475]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_476:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_445]][@"$component"] : <@B_1::@"$bus_entry"<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          function.call @B_1::@B_1::@constrain(%[[VAL_476]], %[[VAL_452]], %[[VAL_460]], %[[VAL_468]]) : (!struct.type<@B_1::@B_1<[]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_477:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_445]][@out] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_478:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_476]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_478]], %[[VAL_477]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@"$bus_entry"<[2, 2, 2, 2, 2, 2]>>} {
// TEMPLATED-NEXT:    module @global {
// TEMPLATED-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      poly.param @n : index
// TEMPLATED-NEXT:      poly.param @m : index
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>> {function.arg_name = "in"}) -> !struct.type<@A::@A<[@n, @m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n, @m]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_4]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_5]], %[[VAL_7]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_8]], %[[VAL_9]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_10]] -> (!array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>) {
// TEMPLATED-NEXT:            struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@n, @m]>>, !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            scf.yield %[[VAL_0]] : !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_12]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_5]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_15]]) %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_17]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_6]]{{\[}}%[[VAL_20]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              pod.write %[[VAL_21]][@a] = %[[VAL_19]] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              array.write %[[VAL_6]]{{\[}}%[[VAL_20]]] = %[[VAL_21]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_23]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_6]]{{\[}}%[[VAL_26]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              pod.write %[[VAL_27]][@b] = %[[VAL_25]] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              array.write %[[VAL_6]]{{\[}}%[[VAL_26]]] = %[[VAL_27]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_30]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            scf.yield %[[VAL_6]] : !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_6]] : <@A::@A<[@n, @m]>>, !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@n, @m]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n, @m]>>, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_33]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_35]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@out] : <@A::@A<[@n, @m]>>, !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_36]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_39]], %[[VAL_40]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_41]] {
// TEMPLATED-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// TEMPLATED-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            scf.for %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_43]] to %[[VAL_42]] step %[[VAL_44]] {
// TEMPLATED-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_45]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_45]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              constrain.eq %[[VAL_48]], %[[VAL_49]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              constrain.eq %[[VAL_50]], %[[VAL_51]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_54]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_55]]) %[[VAL_54]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_57]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_60]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              constrain.eq %[[VAL_62]], %[[VAL_59]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_63]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_66]]] : <@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@b] : <[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              constrain.eq %[[VAL_68]], %[[VAL_65]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// TEMPLATED-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_69]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_70]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      poly.param @n1 : index
// TEMPLATED-NEXT:      poly.param @m1 : index
// TEMPLATED-NEXT:      poly.param @n2 : index
// TEMPLATED-NEXT:      poly.param @m2 : index
// TEMPLATED-NEXT:      poly.param @n3 : index
// TEMPLATED-NEXT:      poly.param @m3 : index
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @aux : !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:        struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !array.type<@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>> {function.arg_name = "in1"}, %[[VAL_72:[0-9a-zA-Z_\.]+]]: !array.type<@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>> {function.arg_name = "in2"}, %[[VAL_73:[0-9a-zA-Z_\.]+]]: !array.type<@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>> {function.arg_name = "in3"}) -> !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_75]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_77]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_79]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_81]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_83]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_85]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_82]], %[[VAL_84]], %[[VAL_86]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_76]], %[[VAL_78]], %[[VAL_80]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_96:[0-9a-zA-Z_\.]+]] = %[[VAL_87]], %[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_88]], %[[VAL_98:[0-9a-zA-Z_\.]+]] = %[[VAL_94]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_98]], %[[VAL_99]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_100]]) %[[VAL_96]], %[[VAL_97]], %[[VAL_98]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_101:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, %[[VAL_102:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, %[[VAL_103:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_104]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_107]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_105]], @m = %[[VAL_108]] }  : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.addi %[[VAL_112]], %[[VAL_114]] : index
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_116]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.muli %[[VAL_115]], %[[VAL_117]] : index
// TEMPLATED-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_118]], %[[VAL_119]] : index
// TEMPLATED-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_120]] -> (!struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>) {
// TEMPLATED-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_123]]) {(%[[VAL_125]]), (%[[VAL_127]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              scf.yield %[[VAL_128]] : !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = llzk.nondet : !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              scf.yield %[[VAL_129]] : !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_118]], @params = %[[VAL_110]], @comp = %[[VAL_121]] } (%[[VAL_106]]), (%[[VAL_109]]) : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_101]]{{\[}}%[[VAL_131]]] = %[[VAL_130]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_101]], %[[VAL_135:[0-9a-zA-Z_\.]+]] = %[[VAL_102]], %[[VAL_136:[0-9a-zA-Z_\.]+]] = %[[VAL_132]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) {
// TEMPLATED-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_137]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_136]], %[[VAL_138]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_139]]) %[[VAL_134]], %[[VAL_135]], %[[VAL_136]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_140:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, %[[VAL_141:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, %[[VAL_142:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_145:[0-9a-zA-Z_\.]+]] = %[[VAL_140]], %[[VAL_146:[0-9a-zA-Z_\.]+]] = %[[VAL_141]], %[[VAL_147:[0-9a-zA-Z_\.]+]] = %[[VAL_143]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">) {
// TEMPLATED-NEXT:                %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_148]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_150:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_147]], %[[VAL_149]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                scf.condition(%[[VAL_150]]) %[[VAL_145]], %[[VAL_146]], %[[VAL_147]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:              } do {
// TEMPLATED-NEXT:              ^bb0(%[[VAL_151:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, %[[VAL_152:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, %[[VAL_153:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:                %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:                %[[VAL_155:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_103]], %[[VAL_154]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_156:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_155]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>) {
// TEMPLATED-NEXT:                  %[[VAL_157:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_157]]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@a] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_161:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_160]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_162]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_164:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_162]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_165]]{{\[}}%[[VAL_166]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_167]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_170:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_168]]{{\[}}%[[VAL_169]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  array.write %[[VAL_168]]{{\[}}%[[VAL_169]]] = %[[VAL_161]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  pod.write %[[VAL_167]][@a] = %[[VAL_168]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  array.write %[[VAL_165]]{{\[}}%[[VAL_166]]] = %[[VAL_167]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  pod.write %[[VAL_163]][@in] = %[[VAL_165]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_171]], %[[VAL_172]] : index
// TEMPLATED-NEXT:                  %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                  %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_173]], %[[VAL_174]], %[[VAL_172]] : index
// TEMPLATED-NEXT:                  %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_175]], %[[VAL_176]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_177]] {
// TEMPLATED-NEXT:                    %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_179:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                    %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_178]], %[[VAL_179]] : index
// TEMPLATED-NEXT:                    pod.write %[[VAL_164]][@count] = %[[VAL_180]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_180]], %[[VAL_181]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_182]] {
// TEMPLATED-NEXT:                      %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                      %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                      %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_183]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_185]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_183]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_188:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_187]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_189:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_184]]) {(%[[VAL_186]]), (%[[VAL_188]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      pod.write %[[VAL_164]][@comp] = %[[VAL_189]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  array.write %[[VAL_152]]{{\[}}%[[VAL_162]]] = %[[VAL_163]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  array.write %[[VAL_151]]{{\[}}%[[VAL_162]]] = %[[VAL_164]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_190:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_190]]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_191]][@b] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_194:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_192]]{{\[}}%[[VAL_193]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_196:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_195]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_197:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_195]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_196]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_199:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_200:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_198]]{{\[}}%[[VAL_199]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_202:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_203:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_201]]{{\[}}%[[VAL_202]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  array.write %[[VAL_201]]{{\[}}%[[VAL_202]]] = %[[VAL_194]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  pod.write %[[VAL_200]][@b] = %[[VAL_201]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  array.write %[[VAL_198]]{{\[}}%[[VAL_199]]] = %[[VAL_200]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  pod.write %[[VAL_196]][@in] = %[[VAL_198]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_197]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_205:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_206:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_204]], %[[VAL_205]] : index
// TEMPLATED-NEXT:                  %[[VAL_207:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                  %[[VAL_208:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_206]], %[[VAL_207]], %[[VAL_205]] : index
// TEMPLATED-NEXT:                  %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_208]], %[[VAL_209]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_210]] {
// TEMPLATED-NEXT:                    %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_197]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_212:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                    %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_211]], %[[VAL_212]] : index
// TEMPLATED-NEXT:                    pod.write %[[VAL_197]][@count] = %[[VAL_213]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_215:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_213]], %[[VAL_214]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_215]] {
// TEMPLATED-NEXT:                      %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_197]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                      %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_196]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                      %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_221:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_222:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_217]]) {(%[[VAL_219]]), (%[[VAL_221]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      pod.write %[[VAL_197]][@comp] = %[[VAL_222]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  array.write %[[VAL_152]]{{\[}}%[[VAL_195]]] = %[[VAL_196]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  array.write %[[VAL_151]]{{\[}}%[[VAL_195]]] = %[[VAL_197]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  scf.yield %[[VAL_151]], %[[VAL_152]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:                } else {
// TEMPLATED-NEXT:                  %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:                  %[[VAL_224:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_103]], %[[VAL_223]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_225:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_224]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>) {
// TEMPLATED-NEXT:                    %[[VAL_226:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_227:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_226]]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_227]][@a] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_229:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_230:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_228]]{{\[}}%[[VAL_229]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_231:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_232:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_231]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    %[[VAL_233:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_231]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                    %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_236:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_235]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_237:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_236]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_237]]{{\[}}%[[VAL_238]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    array.write %[[VAL_237]]{{\[}}%[[VAL_238]]] = %[[VAL_230]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    pod.write %[[VAL_236]][@a] = %[[VAL_237]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    array.write %[[VAL_234]]{{\[}}%[[VAL_235]]] = %[[VAL_236]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    pod.write %[[VAL_232]][@in] = %[[VAL_234]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_240]], %[[VAL_241]] : index
// TEMPLATED-NEXT:                    %[[VAL_243:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                    %[[VAL_244:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_242]], %[[VAL_243]], %[[VAL_241]] : index
// TEMPLATED-NEXT:                    %[[VAL_245:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_246:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_244]], %[[VAL_245]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_246]] {
// TEMPLATED-NEXT:                      %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                      %[[VAL_248:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                      %[[VAL_249:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_247]], %[[VAL_248]] : index
// TEMPLATED-NEXT:                      pod.write %[[VAL_233]][@count] = %[[VAL_249]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                      %[[VAL_250:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                      %[[VAL_251:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_249]], %[[VAL_250]] : index
// TEMPLATED-NEXT:                      scf.if %[[VAL_251]] {
// TEMPLATED-NEXT:                        %[[VAL_252:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                        %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                        %[[VAL_254:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_255:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_254]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_256:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_257:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_256]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_258:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_253]]) {(%[[VAL_255]]), (%[[VAL_257]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                        pod.write %[[VAL_233]][@comp] = %[[VAL_258]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      }
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                    array.write %[[VAL_152]]{{\[}}%[[VAL_231]]] = %[[VAL_232]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    array.write %[[VAL_151]]{{\[}}%[[VAL_231]]] = %[[VAL_233]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                    %[[VAL_259:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_260:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_259]]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_261:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_260]][@b] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_262:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_263:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_261]]{{\[}}%[[VAL_262]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_264:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_265:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_264]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    %[[VAL_266:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_264]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                    %[[VAL_267:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_265]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_268:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_269:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_268]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_269]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_270]]{{\[}}%[[VAL_271]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    array.write %[[VAL_270]]{{\[}}%[[VAL_271]]] = %[[VAL_263]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    pod.write %[[VAL_269]][@b] = %[[VAL_270]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    array.write %[[VAL_267]]{{\[}}%[[VAL_268]]] = %[[VAL_269]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    pod.write %[[VAL_265]][@in] = %[[VAL_267]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_273:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_274:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_275:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_273]], %[[VAL_274]] : index
// TEMPLATED-NEXT:                    %[[VAL_276:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                    %[[VAL_277:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_275]], %[[VAL_276]], %[[VAL_274]] : index
// TEMPLATED-NEXT:                    %[[VAL_278:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_279:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_277]], %[[VAL_278]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_279]] {
// TEMPLATED-NEXT:                      %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                      %[[VAL_281:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                      %[[VAL_282:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_280]], %[[VAL_281]] : index
// TEMPLATED-NEXT:                      pod.write %[[VAL_266]][@count] = %[[VAL_282]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                      %[[VAL_283:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                      %[[VAL_284:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_282]], %[[VAL_283]] : index
// TEMPLATED-NEXT:                      scf.if %[[VAL_284]] {
// TEMPLATED-NEXT:                        %[[VAL_285:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                        %[[VAL_286:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_265]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                        %[[VAL_287:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_288:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_287]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_290:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_289]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_291:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_286]]) {(%[[VAL_288]]), (%[[VAL_290]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                        pod.write %[[VAL_266]][@comp] = %[[VAL_291]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      }
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                    array.write %[[VAL_152]]{{\[}}%[[VAL_264]]] = %[[VAL_265]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    array.write %[[VAL_151]]{{\[}}%[[VAL_264]]] = %[[VAL_266]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                    scf.yield %[[VAL_151]], %[[VAL_152]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:                  } else {
// TEMPLATED-NEXT:                    %[[VAL_292:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_293:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_292]]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_293]][@a] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_296:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_294]]{{\[}}%[[VAL_295]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_298:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_297]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    %[[VAL_299:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_297]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                    %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_298]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_301:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_302:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_300]]{{\[}}%[[VAL_301]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_303:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_302]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_304:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_305:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_303]]{{\[}}%[[VAL_304]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    array.write %[[VAL_303]]{{\[}}%[[VAL_304]]] = %[[VAL_296]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    pod.write %[[VAL_302]][@a] = %[[VAL_303]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    array.write %[[VAL_300]]{{\[}}%[[VAL_301]]] = %[[VAL_302]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    pod.write %[[VAL_298]][@in] = %[[VAL_300]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_306:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_299]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_307:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_308:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_306]], %[[VAL_307]] : index
// TEMPLATED-NEXT:                    %[[VAL_309:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                    %[[VAL_310:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_308]], %[[VAL_309]], %[[VAL_307]] : index
// TEMPLATED-NEXT:                    %[[VAL_311:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_312:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_310]], %[[VAL_311]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_312]] {
// TEMPLATED-NEXT:                      %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_299]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                      %[[VAL_314:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                      %[[VAL_315:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_313]], %[[VAL_314]] : index
// TEMPLATED-NEXT:                      pod.write %[[VAL_299]][@count] = %[[VAL_315]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                      %[[VAL_316:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                      %[[VAL_317:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_315]], %[[VAL_316]] : index
// TEMPLATED-NEXT:                      scf.if %[[VAL_317]] {
// TEMPLATED-NEXT:                        %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_299]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                        %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_298]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                        %[[VAL_320:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_320]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_322:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_323:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_322]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_324:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_319]]) {(%[[VAL_321]]), (%[[VAL_323]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                        pod.write %[[VAL_299]][@comp] = %[[VAL_324]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      }
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                    array.write %[[VAL_152]]{{\[}}%[[VAL_297]]] = %[[VAL_298]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    array.write %[[VAL_151]]{{\[}}%[[VAL_297]]] = %[[VAL_299]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                    %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_326:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_325]]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_327:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_326]][@b] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_328:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_329:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_327]]{{\[}}%[[VAL_328]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_330:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_331:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_330]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    %[[VAL_332:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_330]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                    %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_331]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_334:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_333]]{{\[}}%[[VAL_334]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_336:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_335]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_337:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_338:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_336]]{{\[}}%[[VAL_337]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    array.write %[[VAL_336]]{{\[}}%[[VAL_337]]] = %[[VAL_329]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    pod.write %[[VAL_335]][@b] = %[[VAL_336]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    array.write %[[VAL_333]]{{\[}}%[[VAL_334]]] = %[[VAL_335]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    pod.write %[[VAL_331]][@in] = %[[VAL_333]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_339:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_340:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_341:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_339]], %[[VAL_340]] : index
// TEMPLATED-NEXT:                    %[[VAL_342:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                    %[[VAL_343:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_341]], %[[VAL_342]], %[[VAL_340]] : index
// TEMPLATED-NEXT:                    %[[VAL_344:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_345:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_343]], %[[VAL_344]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_345]] {
// TEMPLATED-NEXT:                      %[[VAL_346:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                      %[[VAL_347:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                      %[[VAL_348:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_346]], %[[VAL_347]] : index
// TEMPLATED-NEXT:                      pod.write %[[VAL_332]][@count] = %[[VAL_348]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                      %[[VAL_349:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                      %[[VAL_350:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_348]], %[[VAL_349]] : index
// TEMPLATED-NEXT:                      scf.if %[[VAL_350]] {
// TEMPLATED-NEXT:                        %[[VAL_351:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                        %[[VAL_352:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_331]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                        %[[VAL_353:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_351]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_354:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_353]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_355:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_351]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_356:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_355]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                        %[[VAL_357:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_352]]) {(%[[VAL_354]]), (%[[VAL_356]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                        pod.write %[[VAL_332]][@comp] = %[[VAL_357]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      }
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                    array.write %[[VAL_152]]{{\[}}%[[VAL_330]]] = %[[VAL_331]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    array.write %[[VAL_151]]{{\[}}%[[VAL_330]]] = %[[VAL_332]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                    scf.yield %[[VAL_151]], %[[VAL_152]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  scf.yield %[[VAL_225]]#0, %[[VAL_225]]#1 : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                %[[VAL_358:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:                %[[VAL_359:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_153]], %[[VAL_358]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                scf.yield %[[VAL_156]]#0, %[[VAL_156]]#1, %[[VAL_359]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_361:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_142]], %[[VAL_360]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_144]]#0, %[[VAL_144]]#1, %[[VAL_361]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_362:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_363:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_133]]#0{{\[}}%[[VAL_362]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_364:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_363]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_365:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_364]][@out] : <@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !array.type<? x !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            %[[VAL_366:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_366]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_368:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_365]]{{\[}}%[[VAL_367]]] : <? x !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_369:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_368]][@b] : <[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_370:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_371:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_370]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_372:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_369]]{{\[}}%[[VAL_371]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_373:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_89]]{{\[}}%[[VAL_373]]] = %[[VAL_372]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_103]], %[[VAL_374]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_133]]#0, %[[VAL_133]]#1, %[[VAL_375]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_74]][@aux$inputs] = %[[VAL_95]]#1 : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_376:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_377:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_378:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_379:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_380:[0-9a-zA-Z_\.]+]] = %[[VAL_378]] to %[[VAL_377]] step %[[VAL_379]] {
// TEMPLATED-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_95]]#0{{\[}}%[[VAL_380]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_381]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_376]]{{\[}}%[[VAL_380]]] = %[[VAL_382]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_74]][@aux] = %[[VAL_376]] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_74]][@out] = %[[VAL_89]] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_74]] : !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_383:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, %[[VAL_384:[0-9a-zA-Z_\.]+]]: !array.type<@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>> {function.arg_name = "in1"}, %[[VAL_385:[0-9a-zA-Z_\.]+]]: !array.type<@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>> {function.arg_name = "in2"}, %[[VAL_386:[0-9a-zA-Z_\.]+]]: !array.type<@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_387:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_388:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_387]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_389:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_390:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_389]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_391:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_392:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_391]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_393:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_394:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_393]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_395:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_396:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_395]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_397:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_398:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_397]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_399:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_383]][@out] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_400:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_383]][@aux] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_401:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_383]][@aux$inputs] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_402:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_403:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_394]], %[[VAL_396]], %[[VAL_398]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_404:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_405:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_388]], %[[VAL_390]], %[[VAL_392]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_406:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_407:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_408:[0-9a-zA-Z_\.]+]] = %[[VAL_406]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_409:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_410:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_408]], %[[VAL_409]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_410]]) %[[VAL_408]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_411:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_412:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_413:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_403]]{{\[}}%[[VAL_412]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_414:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_413]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_415:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_416:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_405]]{{\[}}%[[VAL_415]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_417:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_416]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_418:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_419:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_420:[0-9a-zA-Z_\.]+]] = %[[VAL_418]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:              %[[VAL_421:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_422:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_403]]{{\[}}%[[VAL_421]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_423:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_420]], %[[VAL_422]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_423]]) %[[VAL_420]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_424:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_425:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_426:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_427:[0-9a-zA-Z_\.]+]] = %[[VAL_425]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:                %[[VAL_428:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_429:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_405]]{{\[}}%[[VAL_428]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_430:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_427]], %[[VAL_429]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                scf.condition(%[[VAL_430]]) %[[VAL_427]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              } do {
// TEMPLATED-NEXT:              ^bb0(%[[VAL_431:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:                %[[VAL_432:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:                %[[VAL_433:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_411]], %[[VAL_432]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                scf.if %[[VAL_433]] {
// TEMPLATED-NEXT:                  %[[VAL_434:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_435:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_384]]{{\[}}%[[VAL_434]]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_436:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_435]][@a] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_437:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_438:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_436]]{{\[}}%[[VAL_437]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_439:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_440:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_439]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_441:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_440]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_442:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_443:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_441]]{{\[}}%[[VAL_442]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_444:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_443]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_445:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_446:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_444]]{{\[}}%[[VAL_445]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_446]], %[[VAL_438]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_447:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_448:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_384]]{{\[}}%[[VAL_447]]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_449:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_448]][@b] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_450:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_451:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_449]]{{\[}}%[[VAL_450]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_452:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_453:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_452]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_454:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_453]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_455:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_456:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_454]]{{\[}}%[[VAL_455]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_457:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_456]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_458:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_459:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_457]]{{\[}}%[[VAL_458]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_459]], %[[VAL_451]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                } else {
// TEMPLATED-NEXT:                  %[[VAL_460:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:                  %[[VAL_461:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_411]], %[[VAL_460]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  scf.if %[[VAL_461]] {
// TEMPLATED-NEXT:                    %[[VAL_462:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_463:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_385]]{{\[}}%[[VAL_462]]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_464:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_463]][@a] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_465:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_466:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_464]]{{\[}}%[[VAL_465]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_467:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_468:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_467]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    %[[VAL_469:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_468]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_470:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_471:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_469]]{{\[}}%[[VAL_470]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_472:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_471]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_473:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_474:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_472]]{{\[}}%[[VAL_473]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    constrain.eq %[[VAL_474]], %[[VAL_466]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_475:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_476:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_385]]{{\[}}%[[VAL_475]]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_477:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_476]][@b] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_478:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_479:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_477]]{{\[}}%[[VAL_478]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_480:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_481:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_480]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    %[[VAL_482:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_481]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_483:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_484:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_482]]{{\[}}%[[VAL_483]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_485:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_484]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_486:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_487:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_485]]{{\[}}%[[VAL_486]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    constrain.eq %[[VAL_487]], %[[VAL_479]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  } else {
// TEMPLATED-NEXT:                    %[[VAL_488:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_489:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_386]]{{\[}}%[[VAL_488]]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_490:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_489]][@a] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_491:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_492:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_490]]{{\[}}%[[VAL_491]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_493:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_494:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_493]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    %[[VAL_495:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_494]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_496:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_497:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_495]]{{\[}}%[[VAL_496]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_498:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_497]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_499:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_500:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_498]]{{\[}}%[[VAL_499]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    constrain.eq %[[VAL_500]], %[[VAL_492]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_501:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_502:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_386]]{{\[}}%[[VAL_501]]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_503:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_502]][@b] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_504:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_505:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_503]]{{\[}}%[[VAL_504]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_506:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_507:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_506]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                    %[[VAL_508:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_507]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_509:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_431]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_510:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_508]]{{\[}}%[[VAL_509]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                    %[[VAL_511:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_510]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                    %[[VAL_512:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_513:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_511]]{{\[}}%[[VAL_512]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    constrain.eq %[[VAL_513]], %[[VAL_505]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                %[[VAL_514:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:                %[[VAL_515:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_431]], %[[VAL_514]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                scf.yield %[[VAL_515]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              %[[VAL_516:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_517:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_424]], %[[VAL_516]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_517]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_518:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_519:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_400]]{{\[}}%[[VAL_518]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_520:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_519]][@out] : <@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !array.type<? x !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            %[[VAL_521:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_522:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_521]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_523:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_520]]{{\[}}%[[VAL_522]]] : <? x !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_524:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_523]][@b] : <[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_525:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_526:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_525]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_527:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_524]]{{\[}}%[[VAL_526]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_528:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_529:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_399]]{{\[}}%[[VAL_528]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_529]], %[[VAL_527]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_530:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_531:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_411]], %[[VAL_530]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_531]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_532:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_533:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_534:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_535:[0-9a-zA-Z_\.]+]] = %[[VAL_533]] to %[[VAL_532]] step %[[VAL_534]] {
// TEMPLATED-NEXT:            %[[VAL_536:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_400]]{{\[}}%[[VAL_535]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_537:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_535]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:            %[[VAL_538:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_537]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            function.call @A::@A::@constrain(%[[VAL_536]], %[[VAL_538]]) : (!struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_539:[0-9a-zA-Z_\.]+]]: !array.type<@m1,@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_540:[0-9a-zA-Z_\.]+]]: !array.type<@m1,@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_541:[0-9a-zA-Z_\.]+]]: !array.type<@m2,@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_542:[0-9a-zA-Z_\.]+]]: !array.type<@m2,@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_543:[0-9a-zA-Z_\.]+]]: !array.type<@m3,@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_544:[0-9a-zA-Z_\.]+]]: !array.type<@m3,@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_545:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          %[[VAL_546:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_547:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_546]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_548:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_549:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_548]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_550:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_551:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_550]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_552:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_553:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_552]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_554:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_555:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_554]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_556:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_557:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_556]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_558:[0-9a-zA-Z_\.]+]] = array.new  : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_559:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_560:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_561:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_562:[0-9a-zA-Z_\.]+]] = %[[VAL_560]] to %[[VAL_559]] step %[[VAL_561]] {
// TEMPLATED-NEXT:            %[[VAL_563:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_539]]{{\[}}%[[VAL_562]]] : <@m1,@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_564:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_540]]{{\[}}%[[VAL_562]]] : <@m1,@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_565:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_563]], @b = %[[VAL_564]] }  : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_558]]{{\[}}%[[VAL_562]]] = %[[VAL_565]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_566:[0-9a-zA-Z_\.]+]] = array.new  : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_567:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_568:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_569:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_570:[0-9a-zA-Z_\.]+]] = %[[VAL_568]] to %[[VAL_567]] step %[[VAL_569]] {
// TEMPLATED-NEXT:            %[[VAL_571:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_541]]{{\[}}%[[VAL_570]]] : <@m2,@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_572:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_542]]{{\[}}%[[VAL_570]]] : <@m2,@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_573:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_571]], @b = %[[VAL_572]] }  : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_566]]{{\[}}%[[VAL_570]]] = %[[VAL_573]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_574:[0-9a-zA-Z_\.]+]] = array.new  : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_575:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_576:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_577:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_578:[0-9a-zA-Z_\.]+]] = %[[VAL_576]] to %[[VAL_575]] step %[[VAL_577]] {
// TEMPLATED-NEXT:            %[[VAL_579:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_543]]{{\[}}%[[VAL_578]]] : <@m3,@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_580:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_544]]{{\[}}%[[VAL_578]]] : <@m3,@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_581:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_579]], @b = %[[VAL_580]] }  : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_574]]{{\[}}%[[VAL_578]]] = %[[VAL_581]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_582:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_558]], %[[VAL_566]], %[[VAL_574]]) : (!array.type<@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !array.type<@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !array.type<@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>) -> !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_545]][@"$component"] = %[[VAL_582]] : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          %[[VAL_583:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_582]][@out] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_545]][@out] = %[[VAL_583]] : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_545]] : !struct.type<@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_584:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, %[[VAL_585:[0-9a-zA-Z_\.]+]]: !array.type<@m1,@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_586:[0-9a-zA-Z_\.]+]]: !array.type<@m1,@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_587:[0-9a-zA-Z_\.]+]]: !array.type<@m2,@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_588:[0-9a-zA-Z_\.]+]]: !array.type<@m2,@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_589:[0-9a-zA-Z_\.]+]]: !array.type<@m3,@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_590:[0-9a-zA-Z_\.]+]]: !array.type<@m3,@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_591:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_592:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_591]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_593:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_594:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_593]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_595:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_596:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_595]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_597:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_598:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_597]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_599:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_600:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_599]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_601:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_602:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_601]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_603:[0-9a-zA-Z_\.]+]] = array.new  : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_604:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_605:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_606:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_607:[0-9a-zA-Z_\.]+]] = %[[VAL_605]] to %[[VAL_604]] step %[[VAL_606]] {
// TEMPLATED-NEXT:            %[[VAL_608:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_585]]{{\[}}%[[VAL_607]]] : <@m1,@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_609:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_586]]{{\[}}%[[VAL_607]]] : <@m1,@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_610:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_608]], @b = %[[VAL_609]] }  : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_603]]{{\[}}%[[VAL_607]]] = %[[VAL_610]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_611:[0-9a-zA-Z_\.]+]] = array.new  : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_612:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_613:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_614:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_615:[0-9a-zA-Z_\.]+]] = %[[VAL_613]] to %[[VAL_612]] step %[[VAL_614]] {
// TEMPLATED-NEXT:            %[[VAL_616:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_587]]{{\[}}%[[VAL_615]]] : <@m2,@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_617:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_588]]{{\[}}%[[VAL_615]]] : <@m2,@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_618:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_616]], @b = %[[VAL_617]] }  : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_611]]{{\[}}%[[VAL_615]]] = %[[VAL_618]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_619:[0-9a-zA-Z_\.]+]] = array.new  : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_620:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_621:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_622:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_623:[0-9a-zA-Z_\.]+]] = %[[VAL_621]] to %[[VAL_620]] step %[[VAL_622]] {
// TEMPLATED-NEXT:            %[[VAL_624:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_589]]{{\[}}%[[VAL_623]]] : <@m3,@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_625:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_590]]{{\[}}%[[VAL_623]]] : <@m3,@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_626:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_624]], @b = %[[VAL_625]] }  : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_619]]{{\[}}%[[VAL_623]]] = %[[VAL_626]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_627:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_584]][@"$component"] : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_627]], %[[VAL_603]], %[[VAL_611]], %[[VAL_619]]) : (!struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !array.type<@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !array.type<@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>) -> ()
// TEMPLATED-NEXT:          %[[VAL_628:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_584]][@out] : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_629:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_627]][@out] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_629]], %[[VAL_628]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
