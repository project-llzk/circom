// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Simple case, array of buses as inputs, different sizes in the arrays
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(){
    signal a;
    signal b;
}

template A(n){
    Simple input in[n];
    Simple output out[n];

    if (n % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < n; i++){
            out[i].a <== in[i].b;
            out[i].b <== in[i].a;
        }
    }
}

template B(n1, n2, n3){
    Simple input in1[n1];
    Simple input in2[n2];
    Simple input in3[n3];
    Simple output out[3];

    var sizes[3] = [n1, n2, n3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i]);
        for (var j = 0; j < sizes[i]; j++){
            if (i == 0){
                aux[i].in[j] <== in1[j];
            } else if (i == 1){
                aux[i].in[j] <== in2[j];
            } else{
                aux[i].in[j] <== in3[j];
            }
        }
        out[i] <== aux[i].out[0];
    }
}

component main = B(2, 3, 2);

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_2::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    module @global {
// CONCRETE-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  2 : <"bn128">]
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_5]] step %[[VAL_7]] {
// CONCRETE-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_8]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_8]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_1 {
// CONCRETE-NEXT:      struct.def @A_1 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_22]]) %[[VAL_20]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_24]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_27]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_28]][@a] = %[[VAL_26]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_27]]] = %[[VAL_28]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_30]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_33]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_34]][@b] = %[[VAL_32]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_33]]] = %[[VAL_34]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_37]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_16]][@out] = %[[VAL_17]] : <@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_16]] : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@out] : <@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_41]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_43]], %[[VAL_44]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_45]]) %[[VAL_43]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_47]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_40]]{{\[}}%[[VAL_50]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_52]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_53]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_40]]{{\[}}%[[VAL_56]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_58]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_2 {
// CONCRETE-NEXT:      struct.def @B_2 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE-NEXT:        struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in1"}, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in2"}, %[[VAL_63:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in3"}) -> !struct.type<@B_2::@B_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@B_2<[]>>
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_67]], @params = %[[VAL_66]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_69]], @params = %[[VAL_66]] }  : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_71]], @params = %[[VAL_66]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_68]], @idx_1 = %[[VAL_70]], @idx_2 = %[[VAL_72]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_73]], %[[VAL_79:[0-9a-zA-Z_\.]+]] = %[[VAL_74]], %[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_76]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_80]], %[[VAL_81]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_82]]) %[[VAL_78]], %[[VAL_79]], %[[VAL_80]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_83:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_84:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, %[[VAL_85:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_88:[0-9a-zA-Z_\.]+]] = %[[VAL_83]], %[[VAL_89:[0-9a-zA-Z_\.]+]] = %[[VAL_84]], %[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_86]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !felt.type<"bn128">) {
// CONCRETE-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_91]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_90]], %[[VAL_92]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_93]]) %[[VAL_88]], %[[VAL_89]], %[[VAL_90]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_94:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_95:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, %[[VAL_96:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_85]], %[[VAL_97]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_98]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_100]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_103]], %[[VAL_105]] : index
// CONCRETE-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_104]], %[[VAL_106]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_103]], %[[VAL_108]] : index
// CONCRETE-NEXT:                %[[VAL_110:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_104]], %[[VAL_109]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_103]], %[[VAL_111]] : index
// CONCRETE-NEXT:                %[[VAL_113:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_104]], %[[VAL_112]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_114:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_115:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_113]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_118]]{{\[}}%[[VAL_119]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    array.write %[[VAL_118]]{{\[}}%[[VAL_119]]] = %[[VAL_101]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    pod.write %[[VAL_117]][@in] = %[[VAL_118]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_95]][@idx_2] = %[[VAL_117]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                    %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_121]], %[[VAL_122]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_116]][@count] = %[[VAL_123]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_123]], %[[VAL_124]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_125]] {
// CONCRETE-NEXT:                      %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                      %[[VAL_128:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_127]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_116]][@comp] = %[[VAL_128]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_94]][@idx_2] = %[[VAL_116]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_129:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_110]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                      %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                      %[[VAL_133:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                      %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_132]]{{\[}}%[[VAL_133]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                      array.write %[[VAL_132]]{{\[}}%[[VAL_133]]] = %[[VAL_101]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                      pod.write %[[VAL_131]][@in] = %[[VAL_132]] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_95]][@idx_1] = %[[VAL_131]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                      %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@count] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                      %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_135]], %[[VAL_136]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_130]][@count] = %[[VAL_137]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_137]], %[[VAL_138]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_139]] {
// CONCRETE-NEXT:                        %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@params] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        %[[VAL_142:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_141]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_130]][@comp] = %[[VAL_142]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_94]][@idx_1] = %[[VAL_130]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_143:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_107]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                        %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                        %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                        %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        %[[VAL_147:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                        %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_146]]{{\[}}%[[VAL_147]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                        array.write %[[VAL_146]]{{\[}}%[[VAL_147]]] = %[[VAL_101]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                        pod.write %[[VAL_145]][@in] = %[[VAL_146]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_95]][@idx_0] = %[[VAL_145]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                        %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                        %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                        %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_149]], %[[VAL_150]] : index
// CONCRETE-NEXT:                        pod.write %[[VAL_144]][@count] = %[[VAL_151]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                        %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                        %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_151]], %[[VAL_152]] : index
// CONCRETE-NEXT:                        scf.if %[[VAL_153]] {
// CONCRETE-NEXT:                          %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                          %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                          %[[VAL_156:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_155]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                          pod.write %[[VAL_144]][@comp] = %[[VAL_156]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        }
// CONCRETE-NEXT:                        pod.write %[[VAL_94]][@idx_0] = %[[VAL_144]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                        scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                      } else {
// CONCRETE-NEXT:                        %[[VAL_157:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                        %[[VAL_158:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                        scf.yield %[[VAL_157]], %[[VAL_158]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      scf.yield %[[VAL_143]]#0, %[[VAL_143]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_129]]#0, %[[VAL_129]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_115]]#0, %[[VAL_115]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_114]]#0, %[[VAL_114]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_160:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_85]], %[[VAL_159]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_161:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_160]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_162]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_166:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                  %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_165]], %[[VAL_167]] : index
// CONCRETE-NEXT:                  %[[VAL_169:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_166]], %[[VAL_168]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_165]], %[[VAL_170]] : index
// CONCRETE-NEXT:                  %[[VAL_172:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_166]], %[[VAL_171]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                  %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_165]], %[[VAL_173]] : index
// CONCRETE-NEXT:                  %[[VAL_175:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_166]], %[[VAL_174]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_176:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_177:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_175]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                      %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                      %[[VAL_181:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                      %[[VAL_182:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_180]]{{\[}}%[[VAL_181]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                      array.write %[[VAL_180]]{{\[}}%[[VAL_181]]] = %[[VAL_163]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                      pod.write %[[VAL_179]][@in] = %[[VAL_180]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_95]][@idx_2] = %[[VAL_179]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                      %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                      %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_183]], %[[VAL_184]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_178]][@count] = %[[VAL_185]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_185]], %[[VAL_186]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_187]] {
// CONCRETE-NEXT:                        %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        %[[VAL_190:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_189]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_178]][@comp] = %[[VAL_190]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_94]][@idx_2] = %[[VAL_178]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_191:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_172]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                        %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                        %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                        %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                        %[[VAL_196:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_194]]{{\[}}%[[VAL_195]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                        array.write %[[VAL_194]]{{\[}}%[[VAL_195]]] = %[[VAL_163]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                        pod.write %[[VAL_193]][@in] = %[[VAL_194]] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_95]][@idx_1] = %[[VAL_193]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                        %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@count] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                        %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                        %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_197]], %[[VAL_198]] : index
// CONCRETE-NEXT:                        pod.write %[[VAL_192]][@count] = %[[VAL_199]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                        %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                        %[[VAL_201:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_199]], %[[VAL_200]] : index
// CONCRETE-NEXT:                        scf.if %[[VAL_201]] {
// CONCRETE-NEXT:                          %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@params] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                          %[[VAL_204:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_203]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                          pod.write %[[VAL_192]][@comp] = %[[VAL_204]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                        }
// CONCRETE-NEXT:                        pod.write %[[VAL_94]][@idx_1] = %[[VAL_192]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                        scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                      } else {
// CONCRETE-NEXT:                        %[[VAL_205:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_169]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                          %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_207]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                          %[[VAL_209:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                          %[[VAL_210:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_208]]{{\[}}%[[VAL_209]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                          array.write %[[VAL_208]]{{\[}}%[[VAL_209]]] = %[[VAL_163]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                          pod.write %[[VAL_207]][@in] = %[[VAL_208]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                          pod.write %[[VAL_95]][@idx_0] = %[[VAL_207]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                          %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                          %[[VAL_212:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                          %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_211]], %[[VAL_212]] : index
// CONCRETE-NEXT:                          pod.write %[[VAL_206]][@count] = %[[VAL_213]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                          %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                          %[[VAL_215:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_213]], %[[VAL_214]] : index
// CONCRETE-NEXT:                          scf.if %[[VAL_215]] {
// CONCRETE-NEXT:                            %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                            %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_207]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                            %[[VAL_218:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_217]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                            pod.write %[[VAL_206]][@comp] = %[[VAL_218]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                          }
// CONCRETE-NEXT:                          pod.write %[[VAL_94]][@idx_0] = %[[VAL_206]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                          scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                        } else {
// CONCRETE-NEXT:                          %[[VAL_219:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                          %[[VAL_220:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                          scf.yield %[[VAL_219]], %[[VAL_220]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                        }
// CONCRETE-NEXT:                        scf.yield %[[VAL_205]]#0, %[[VAL_205]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      scf.yield %[[VAL_191]]#0, %[[VAL_191]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_177]]#0, %[[VAL_177]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_176]]#0, %[[VAL_176]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_221:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_222:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_221]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_224:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_223]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                  %[[VAL_226:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_227:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_224]], %[[VAL_226]] : index
// CONCRETE-NEXT:                  %[[VAL_228:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_225]], %[[VAL_227]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_229:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_230:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_224]], %[[VAL_229]] : index
// CONCRETE-NEXT:                  %[[VAL_231:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_225]], %[[VAL_230]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_232:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                  %[[VAL_233:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_224]], %[[VAL_232]] : index
// CONCRETE-NEXT:                  %[[VAL_234:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_225]], %[[VAL_233]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_235:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_236:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_234]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_237:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_238:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                      %[[VAL_239:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_238]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                      %[[VAL_240:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                      %[[VAL_241:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_239]]{{\[}}%[[VAL_240]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                      array.write %[[VAL_239]]{{\[}}%[[VAL_240]]] = %[[VAL_222]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                      pod.write %[[VAL_238]][@in] = %[[VAL_239]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_95]][@idx_2] = %[[VAL_238]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                      %[[VAL_242:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_237]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_243:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                      %[[VAL_244:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_242]], %[[VAL_243]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_237]][@count] = %[[VAL_244]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_245:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_246:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_244]], %[[VAL_245]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_246]] {
// CONCRETE-NEXT:                        %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_237]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_238]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        %[[VAL_249:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_248]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_237]][@comp] = %[[VAL_249]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_94]][@idx_2] = %[[VAL_237]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_250:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_231]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                        %[[VAL_251:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                        %[[VAL_252:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                        %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        %[[VAL_254:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                        %[[VAL_255:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_253]]{{\[}}%[[VAL_254]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                        array.write %[[VAL_253]]{{\[}}%[[VAL_254]]] = %[[VAL_222]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                        pod.write %[[VAL_252]][@in] = %[[VAL_253]] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_95]][@idx_1] = %[[VAL_252]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                        %[[VAL_256:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_251]][@count] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                        %[[VAL_257:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                        %[[VAL_258:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_256]], %[[VAL_257]] : index
// CONCRETE-NEXT:                        pod.write %[[VAL_251]][@count] = %[[VAL_258]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                        %[[VAL_259:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                        %[[VAL_260:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_258]], %[[VAL_259]] : index
// CONCRETE-NEXT:                        scf.if %[[VAL_260]] {
// CONCRETE-NEXT:                          %[[VAL_261:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_251]][@params] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                          %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                          %[[VAL_263:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_262]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                          pod.write %[[VAL_251]][@comp] = %[[VAL_263]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                        }
// CONCRETE-NEXT:                        pod.write %[[VAL_94]][@idx_1] = %[[VAL_251]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                        scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                      } else {
// CONCRETE-NEXT:                        %[[VAL_264:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_228]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>) {
// CONCRETE-NEXT:                          %[[VAL_265:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                          %[[VAL_266:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                          %[[VAL_267:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                          %[[VAL_268:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:                          %[[VAL_269:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_268]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                          array.write %[[VAL_267]]{{\[}}%[[VAL_268]]] = %[[VAL_222]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                          pod.write %[[VAL_266]][@in] = %[[VAL_267]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                          pod.write %[[VAL_95]][@idx_0] = %[[VAL_266]] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                          %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_265]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                          %[[VAL_271:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                          %[[VAL_272:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_270]], %[[VAL_271]] : index
// CONCRETE-NEXT:                          pod.write %[[VAL_265]][@count] = %[[VAL_272]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                          %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                          %[[VAL_274:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_272]], %[[VAL_273]] : index
// CONCRETE-NEXT:                          scf.if %[[VAL_274]] {
// CONCRETE-NEXT:                            %[[VAL_275:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_265]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                            %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                            %[[VAL_277:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_276]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                            pod.write %[[VAL_265]][@comp] = %[[VAL_277]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                          }
// CONCRETE-NEXT:                          pod.write %[[VAL_94]][@idx_0] = %[[VAL_265]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                          scf.yield %[[VAL_94]], %[[VAL_95]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                        } else {
// CONCRETE-NEXT:                          %[[VAL_278:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                          %[[VAL_279:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                          scf.yield %[[VAL_278]], %[[VAL_279]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                        }
// CONCRETE-NEXT:                        scf.yield %[[VAL_264]]#0, %[[VAL_264]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      scf.yield %[[VAL_250]]#0, %[[VAL_250]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_236]]#0, %[[VAL_236]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_235]]#0, %[[VAL_235]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_161]]#0, %[[VAL_161]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_96]], %[[VAL_280]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_99]]#0, %[[VAL_99]]#1, %[[VAL_281]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_283:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_282]], %[[VAL_284]] : index
// CONCRETE-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_283]], %[[VAL_285]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_282]], %[[VAL_287]] : index
// CONCRETE-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_283]], %[[VAL_288]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_282]], %[[VAL_290]] : index
// CONCRETE-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_283]], %[[VAL_291]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {
// CONCRETE-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_292]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) {
// CONCRETE-NEXT:                %[[VAL_295:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_296:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_295]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                %[[VAL_297:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_296]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_300:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_297]]{{\[}}%[[VAL_299]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                scf.yield %[[VAL_300]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_301:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_289]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) {
// CONCRETE-NEXT:                  %[[VAL_302:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_303:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_302]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  %[[VAL_304:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_303]][@out] : <@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_305:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_306:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_305]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_307:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_304]]{{\[}}%[[VAL_306]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_307]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_308:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_286]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) {
// CONCRETE-NEXT:                    %[[VAL_309:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_310:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_309]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    %[[VAL_311:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_310]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_312:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_313:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_312]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_314:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_313]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_314]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_315:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_315]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_308]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_301]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_294]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_65]]{{\[}}%[[VAL_316]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_65]]{{\[}}%[[VAL_316]]] = %[[VAL_293]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_85]], %[[VAL_318]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_87]]#0, %[[VAL_87]]#1, %[[VAL_319]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_64]][@aux$inputs] = %[[VAL_77]]#1 : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_321:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_320]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_322]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_324]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_321]], @idx_1 = %[[VAL_323]], @idx_2 = %[[VAL_325]] }  : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_64]][@aux] = %[[VAL_326]] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_64]][@out] = %[[VAL_65]] : <@B_2::@B_2<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_64]] : !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_327:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@B_2<[]>>, %[[VAL_328:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in1"}, %[[VAL_329:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in2"}, %[[VAL_330:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_327]][@out] : <@B_2::@B_2<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_327]][@aux] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE-NEXT:          %[[VAL_333:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_327]][@aux$inputs] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:          %[[VAL_334:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_335:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_336:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_337:[0-9a-zA-Z_\.]+]] = %[[VAL_335]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_338:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_339:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_337]], %[[VAL_338]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_339]]) %[[VAL_337]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_340:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_341:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_342:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_343:[0-9a-zA-Z_\.]+]] = %[[VAL_341]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_344:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_340]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_345:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_334]]{{\[}}%[[VAL_344]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_346:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_343]], %[[VAL_345]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_346]]) %[[VAL_343]] : !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_347:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_349:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_340]], %[[VAL_348]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.if %[[VAL_349]] {
// CONCRETE-NEXT:                %[[VAL_350:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_351:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_328]]{{\[}}%[[VAL_350]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_352:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_333]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                %[[VAL_353:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_352]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                %[[VAL_354:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_355:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_353]]{{\[}}%[[VAL_354]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_356:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_355]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_357:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_351]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                constrain.eq %[[VAL_356]], %[[VAL_357]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_358:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_355]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_359:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_351]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                constrain.eq %[[VAL_358]], %[[VAL_359]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_361:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_340]], %[[VAL_360]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.if %[[VAL_361]] {
// CONCRETE-NEXT:                  %[[VAL_362:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_363:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_329]]{{\[}}%[[VAL_362]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_364:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_333]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                  %[[VAL_365:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_364]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_366:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_367:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_365]]{{\[}}%[[VAL_366]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_368:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_369:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_363]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_368]], %[[VAL_369]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_370:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_371:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_363]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_370]], %[[VAL_371]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_372:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_373:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_330]]{{\[}}%[[VAL_372]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_374:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_333]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                  %[[VAL_375:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_374]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_376:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_377:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_375]]{{\[}}%[[VAL_376]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_378:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_377]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_379:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_373]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_378]], %[[VAL_379]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_380:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_377]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_381:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_373]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_380]], %[[VAL_381]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_382:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_383:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_347]], %[[VAL_382]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_383]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_384:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_340]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_385:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_384]], %[[VAL_386]] : index
// CONCRETE-NEXT:            %[[VAL_388:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_385]], %[[VAL_387]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_389:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_390:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_384]], %[[VAL_389]] : index
// CONCRETE-NEXT:            %[[VAL_391:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_385]], %[[VAL_390]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_392:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_393:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_384]], %[[VAL_392]] : index
// CONCRETE-NEXT:            %[[VAL_394:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_385]], %[[VAL_393]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_395:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {
// CONCRETE-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_394]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) {
// CONCRETE-NEXT:                %[[VAL_397:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                %[[VAL_398:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_397]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                %[[VAL_399:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_400:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_399]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_401:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_398]]{{\[}}%[[VAL_400]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                scf.yield %[[VAL_401]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_402:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_391]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) {
// CONCRETE-NEXT:                  %[[VAL_403:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  %[[VAL_404:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_403]][@out] : <@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_405:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_406:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_405]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_407:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_404]]{{\[}}%[[VAL_406]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_407]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_408:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_388]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) {
// CONCRETE-NEXT:                    %[[VAL_409:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    %[[VAL_410:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_409]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_411:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_412:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_413:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_410]]{{\[}}%[[VAL_412]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_413]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_414:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_414]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_408]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_402]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_396]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_415:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_340]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_416:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_331]]{{\[}}%[[VAL_415]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_417:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_416]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_418:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_395]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_417]], %[[VAL_418]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_419:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_416]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_420:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_395]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_419]], %[[VAL_420]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_421:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_422:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_340]], %[[VAL_421]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_422]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_423:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_424:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_333]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          %[[VAL_425:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_424]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_423]], %[[VAL_425]]) : (!struct.type<@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_426:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_427:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_333]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          %[[VAL_428:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_427]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_426]], %[[VAL_428]]) : (!struct.type<@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_429:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_430:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_333]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          %[[VAL_431:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_430]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_429]], %[[VAL_431]]) : (!struct.type<@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_432:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_433:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_434:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_435:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_436:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_437:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B_2::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_438:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_439:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_440:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_441:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_442:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_443:[0-9a-zA-Z_\.]+]] = %[[VAL_441]] to %[[VAL_440]] step %[[VAL_442]] {
// CONCRETE-NEXT:            %[[VAL_444:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_432]]{{\[}}%[[VAL_443]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_445:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_433]]{{\[}}%[[VAL_443]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_446:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_444]], @b = %[[VAL_445]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_439]]{{\[}}%[[VAL_443]]] = %[[VAL_446]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_447:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_448:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_449:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_450:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_451:[0-9a-zA-Z_\.]+]] = %[[VAL_449]] to %[[VAL_448]] step %[[VAL_450]] {
// CONCRETE-NEXT:            %[[VAL_452:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_434]]{{\[}}%[[VAL_451]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_453:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_435]]{{\[}}%[[VAL_451]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_454:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_452]], @b = %[[VAL_453]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_447]]{{\[}}%[[VAL_451]]] = %[[VAL_454]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_455:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_456:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_457:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_458:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_459:[0-9a-zA-Z_\.]+]] = %[[VAL_457]] to %[[VAL_456]] step %[[VAL_458]] {
// CONCRETE-NEXT:            %[[VAL_460:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_436]]{{\[}}%[[VAL_459]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_461:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_437]]{{\[}}%[[VAL_459]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_462:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_460]], @b = %[[VAL_461]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_455]]{{\[}}%[[VAL_459]]] = %[[VAL_462]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_463:[0-9a-zA-Z_\.]+]] = function.call @B_2::@B_2::@compute(%[[VAL_439]], %[[VAL_447]], %[[VAL_455]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_438]][@"$component"] = %[[VAL_463]] : <@B_2::@"$bus_entry"<[]>>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          %[[VAL_464:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_465:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_466:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_463]][@out] : <@B_2::@B_2<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_467:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_468:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_469:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_470:[0-9a-zA-Z_\.]+]] = %[[VAL_468]] to %[[VAL_467]] step %[[VAL_469]] {
// CONCRETE-NEXT:            %[[VAL_471:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_466]]{{\[}}%[[VAL_470]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_472:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_471]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_464]]{{\[}}%[[VAL_470]]] = %[[VAL_472]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_473:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_471]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_465]]{{\[}}%[[VAL_470]]] = %[[VAL_473]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_438]][@out.a] = %[[VAL_464]] : <@B_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_438]][@out.b] = %[[VAL_465]] : <@B_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_438]] : !struct.type<@B_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_474:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@"$bus_entry"<[]>>, %[[VAL_475:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_476:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_477:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_478:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_479:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_480:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_481:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_482:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_483:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_484:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_485:[0-9a-zA-Z_\.]+]] = %[[VAL_483]] to %[[VAL_482]] step %[[VAL_484]] {
// CONCRETE-NEXT:            %[[VAL_486:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_475]]{{\[}}%[[VAL_485]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_487:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_476]]{{\[}}%[[VAL_485]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_488:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_486]], @b = %[[VAL_487]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_481]]{{\[}}%[[VAL_485]]] = %[[VAL_488]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_489:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_490:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_491:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_492:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_493:[0-9a-zA-Z_\.]+]] = %[[VAL_491]] to %[[VAL_490]] step %[[VAL_492]] {
// CONCRETE-NEXT:            %[[VAL_494:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_477]]{{\[}}%[[VAL_493]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_495:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_478]]{{\[}}%[[VAL_493]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_496:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_494]], @b = %[[VAL_495]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_489]]{{\[}}%[[VAL_493]]] = %[[VAL_496]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_497:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_498:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_499:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_500:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_501:[0-9a-zA-Z_\.]+]] = %[[VAL_499]] to %[[VAL_498]] step %[[VAL_500]] {
// CONCRETE-NEXT:            %[[VAL_502:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_479]]{{\[}}%[[VAL_501]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_503:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_480]]{{\[}}%[[VAL_501]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_504:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_502]], @b = %[[VAL_503]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_497]]{{\[}}%[[VAL_501]]] = %[[VAL_504]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_505:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_474]][@"$component"] : <@B_2::@"$bus_entry"<[]>>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          function.call @B_2::@B_2::@constrain(%[[VAL_505]], %[[VAL_481]], %[[VAL_489]], %[[VAL_497]]) : (!struct.type<@B_2::@B_2<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_506:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_474]][@out.a] : <@B_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_507:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_474]][@out.b] : <@B_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_508:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_505]][@out] : <@B_2::@B_2<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_509:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_510:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_511:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_512:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_513:[0-9a-zA-Z_\.]+]] = %[[VAL_511]] to %[[VAL_510]] step %[[VAL_512]] {
// CONCRETE-NEXT:            %[[VAL_514:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_506]]{{\[}}%[[VAL_513]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_515:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_507]]{{\[}}%[[VAL_513]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_516:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_514]], @b = %[[VAL_515]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_509]]{{\[}}%[[VAL_513]]] = %[[VAL_516]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_517:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_518:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_519:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_520:[0-9a-zA-Z_\.]+]] = %[[VAL_518]] to %[[VAL_517]] step %[[VAL_519]] {
// CONCRETE-NEXT:            %[[VAL_521:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_508]]{{\[}}%[[VAL_520]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_522:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_509]]{{\[}}%[[VAL_520]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_523:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_521]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_524:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_522]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_523]], %[[VAL_524]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_525:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_521]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_526:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_522]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_525]], %[[VAL_526]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
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
// TEMPLATED-NEXT:        struct.member @out : !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_3]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_6]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_8]] -> (!array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) {
// TEMPLATED-NEXT:            struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@n]>>, !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:            scf.yield %[[VAL_0]] : !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:              %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_13]]) %[[VAL_12]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_15]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_18]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              pod.write %[[VAL_19]][@a] = %[[VAL_17]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              array.write %[[VAL_4]]{{\[}}%[[VAL_18]]] = %[[VAL_19]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_21]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_24]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              pod.write %[[VAL_25]][@b] = %[[VAL_23]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              array.write %[[VAL_4]]{{\[}}%[[VAL_24]]] = %[[VAL_25]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_28]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            scf.yield %[[VAL_4]] : !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@A::@A<[@n]>>, !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@n]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_31]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@A::@A<[@n]>>, !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_32]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_35]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_37]] {
// TEMPLATED-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// TEMPLATED-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            scf.for %[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_39]] to %[[VAL_38]] step %[[VAL_40]] {
// TEMPLATED-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_41]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_41]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_44]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_46]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_48]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_50]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_51]]) %[[VAL_50]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_52:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_53]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_56]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_58]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_59]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_62]]] : <@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_64]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_52]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_66]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
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
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @aux : !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:        struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in1"}, %[[VAL_68:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in2"}, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in3"}) -> !struct.type<@B::@B<[@n1, @n2, @n3]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_71]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_73]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_75]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_72]], %[[VAL_74]], %[[VAL_76]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_78]], %[[VAL_85:[0-9a-zA-Z_\.]+]] = %[[VAL_79]], %[[VAL_86:[0-9a-zA-Z_\.]+]] = %[[VAL_82]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_86]], %[[VAL_87]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_88]]) %[[VAL_84]], %[[VAL_85]], %[[VAL_86]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_89:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_90:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, %[[VAL_91:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_92]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_93]] }  : <[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.muli %[[VAL_96]], %[[VAL_98]] : index
// TEMPLATED-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_99]], %[[VAL_100]] : index
// TEMPLATED-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_101]] -> (!struct.type<@A::@A<[#[[$ATTR_0]]]>>) {
// TEMPLATED-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_104]]) {(%[[VAL_106]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              scf.yield %[[VAL_107]] : !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = llzk.nondet : !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              scf.yield %[[VAL_108]] : !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_99]], @params = %[[VAL_95]], @comp = %[[VAL_102]] } (%[[VAL_94]]) : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_89]]{{\[}}%[[VAL_110]]] = %[[VAL_109]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_113:[0-9a-zA-Z_\.]+]] = %[[VAL_89]], %[[VAL_114:[0-9a-zA-Z_\.]+]] = %[[VAL_90]], %[[VAL_115:[0-9a-zA-Z_\.]+]] = %[[VAL_111]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">) {
// TEMPLATED-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_116]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_115]], %[[VAL_117]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_118]]) %[[VAL_113]], %[[VAL_114]], %[[VAL_115]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_119:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_120:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, %[[VAL_121:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_91]], %[[VAL_122]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_123]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>) {
// TEMPLATED-NEXT:                %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_125]]] : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_127]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_127]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_130]]{{\[}}%[[VAL_131]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                array.write %[[VAL_130]]{{\[}}%[[VAL_131]]] = %[[VAL_126]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                pod.write %[[VAL_128]][@in] = %[[VAL_130]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_133]], %[[VAL_134]] : index
// TEMPLATED-NEXT:                %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_135]], %[[VAL_136]], %[[VAL_134]] : index
// TEMPLATED-NEXT:                %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_137]], %[[VAL_138]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_139]] {
// TEMPLATED-NEXT:                  %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:                  %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_140]], %[[VAL_141]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_129]][@count] = %[[VAL_142]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_142]], %[[VAL_143]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_144]] {
// TEMPLATED-NEXT:                    %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                    %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_147]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_149:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_146]]) {(%[[VAL_148]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_129]][@comp] = %[[VAL_149]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_120]]{{\[}}%[[VAL_127]]] = %[[VAL_128]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                array.write %[[VAL_119]]{{\[}}%[[VAL_127]]] = %[[VAL_129]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                scf.yield %[[VAL_119]], %[[VAL_120]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:              } else {
// TEMPLATED-NEXT:                %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:                %[[VAL_151:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_91]], %[[VAL_150]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_152:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_151]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>) {
// TEMPLATED-NEXT:                  %[[VAL_153:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_68]]{{\[}}%[[VAL_153]]] : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_155]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                  %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_155]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                  %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_160:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_158]]{{\[}}%[[VAL_159]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  array.write %[[VAL_158]]{{\[}}%[[VAL_159]]] = %[[VAL_154]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  pod.write %[[VAL_156]][@in] = %[[VAL_158]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                  %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_161]], %[[VAL_162]] : index
// TEMPLATED-NEXT:                  %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                  %[[VAL_165:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_163]], %[[VAL_164]], %[[VAL_162]] : index
// TEMPLATED-NEXT:                  %[[VAL_166:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_165]], %[[VAL_166]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_167]] {
// TEMPLATED-NEXT:                    %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:                    %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_168]], %[[VAL_169]] : index
// TEMPLATED-NEXT:                    pod.write %[[VAL_157]][@count] = %[[VAL_170]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_171]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_172]] {
// TEMPLATED-NEXT:                      %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                      %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                      %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_175]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_177:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_174]]) {(%[[VAL_176]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      pod.write %[[VAL_157]][@comp] = %[[VAL_177]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  array.write %[[VAL_120]]{{\[}}%[[VAL_155]]] = %[[VAL_156]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                  array.write %[[VAL_119]]{{\[}}%[[VAL_155]]] = %[[VAL_157]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  scf.yield %[[VAL_119]], %[[VAL_120]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:                } else {
// TEMPLATED-NEXT:                  %[[VAL_178:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_178]]] : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_180:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_181:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_180]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                  %[[VAL_182:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_180]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                  %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_185:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_183]]{{\[}}%[[VAL_184]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  array.write %[[VAL_183]]{{\[}}%[[VAL_184]]] = %[[VAL_179]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  pod.write %[[VAL_181]][@in] = %[[VAL_183]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                  %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_186]], %[[VAL_187]] : index
// TEMPLATED-NEXT:                  %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                  %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_188]], %[[VAL_189]], %[[VAL_187]] : index
// TEMPLATED-NEXT:                  %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_190]], %[[VAL_191]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_192]] {
// TEMPLATED-NEXT:                    %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:                    %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_193]], %[[VAL_194]] : index
// TEMPLATED-NEXT:                    pod.write %[[VAL_182]][@count] = %[[VAL_195]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_197:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_195]], %[[VAL_196]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_197]] {
// TEMPLATED-NEXT:                      %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                      %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                      %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_201:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_200]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_202:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_199]]) {(%[[VAL_201]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      pod.write %[[VAL_182]][@comp] = %[[VAL_202]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  array.write %[[VAL_120]]{{\[}}%[[VAL_180]]] = %[[VAL_181]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                  array.write %[[VAL_119]]{{\[}}%[[VAL_180]]] = %[[VAL_182]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  scf.yield %[[VAL_119]], %[[VAL_120]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                scf.yield %[[VAL_152]]#0, %[[VAL_152]]#1 : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_121]], %[[VAL_203]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_124]]#0, %[[VAL_124]]#1, %[[VAL_204]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]#0{{\[}}%[[VAL_205]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_207]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_209]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_208]]{{\[}}%[[VAL_210]]] : <? x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_212]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_77]]{{\[}}%[[VAL_212]]] = %[[VAL_211]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_91]], %[[VAL_214]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_112]]#0, %[[VAL_112]]#1, %[[VAL_215]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_70]][@aux$inputs] = %[[VAL_83]]#1 : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_220:[0-9a-zA-Z_\.]+]] = %[[VAL_218]] to %[[VAL_217]] step %[[VAL_219]] {
// TEMPLATED-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]#0{{\[}}%[[VAL_220]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_216]]{{\[}}%[[VAL_220]]] = %[[VAL_222]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_70]][@aux] = %[[VAL_216]] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_70]][@out] = %[[VAL_77]] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          function.return %[[VAL_70]] : !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_223:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n1, @n2, @n3]>>, %[[VAL_224:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in1"}, %[[VAL_225:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in2"}, %[[VAL_226:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_227]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_229]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_231]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_223]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_223]][@aux] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_223]][@aux$inputs] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_228]], %[[VAL_230]], %[[VAL_232]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_240:[0-9a-zA-Z_\.]+]] = %[[VAL_238]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_240]], %[[VAL_241]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_242]]) %[[VAL_240]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_243:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_237]]{{\[}}%[[VAL_244]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_245]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_249:[0-9a-zA-Z_\.]+]] = %[[VAL_247]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_237]]{{\[}}%[[VAL_250]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_249]], %[[VAL_251]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_252]]) %[[VAL_249]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_253:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_243]], %[[VAL_254]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.if %[[VAL_255]] {
// TEMPLATED-NEXT:                %[[VAL_256:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_257:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_224]]{{\[}}%[[VAL_256]]] : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                %[[VAL_258:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_259:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_235]]{{\[}}%[[VAL_258]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                %[[VAL_260:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_259]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_261:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_262:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_260]]{{\[}}%[[VAL_261]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                %[[VAL_263:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_262]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_264:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_257]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                constrain.eq %[[VAL_263]], %[[VAL_264]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_265:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_262]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_266:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_257]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                constrain.eq %[[VAL_265]], %[[VAL_266]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              } else {
// TEMPLATED-NEXT:                %[[VAL_267:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:                %[[VAL_268:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_243]], %[[VAL_267]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                scf.if %[[VAL_268]] {
// TEMPLATED-NEXT:                  %[[VAL_269:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_270:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_225]]{{\[}}%[[VAL_269]]] : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_235]]{{\[}}%[[VAL_271]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                  %[[VAL_273:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_272]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                  %[[VAL_274:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_275:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_273]]{{\[}}%[[VAL_274]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_270]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_276]], %[[VAL_277]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_279:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_270]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_278]], %[[VAL_279]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                } else {
// TEMPLATED-NEXT:                  %[[VAL_280:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_281:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_226]]{{\[}}%[[VAL_280]]] : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_282:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_283:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_235]]{{\[}}%[[VAL_282]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                  %[[VAL_284:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_283]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                  %[[VAL_285:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_286:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_284]]{{\[}}%[[VAL_285]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_287:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_286]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_288:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_281]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_287]], %[[VAL_288]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_286]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_290:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_281]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_289]], %[[VAL_290]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_253]], %[[VAL_291]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_292]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_293]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_294]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_296]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_295]]{{\[}}%[[VAL_297]]] : <? x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_233]]{{\[}}%[[VAL_299]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_302:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_298]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_301]], %[[VAL_302]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_303:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_304:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_298]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_303]], %[[VAL_304]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_243]], %[[VAL_305]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_306]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_308:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_309:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_310:[0-9a-zA-Z_\.]+]] = %[[VAL_308]] to %[[VAL_307]] step %[[VAL_309]] {
// TEMPLATED-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_310]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_235]]{{\[}}%[[VAL_310]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_312]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:            function.call @A::@A::@constrain(%[[VAL_311]], %[[VAL_313]]) : (!struct.type<@A::@A<[#[[$ATTR_0]]]>>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_314:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_315:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_316:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_317:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_318:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_319:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          %[[VAL_321:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_321]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_323]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_325]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_327:[0-9a-zA-Z_\.]+]] = array.new  : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_329:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_331:[0-9a-zA-Z_\.]+]] = %[[VAL_329]] to %[[VAL_328]] step %[[VAL_330]] {
// TEMPLATED-NEXT:            %[[VAL_332:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_314]]{{\[}}%[[VAL_331]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_333:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_315]]{{\[}}%[[VAL_331]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_332]], @b = %[[VAL_333]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_327]]{{\[}}%[[VAL_331]]] = %[[VAL_334]] : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.new  : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_336:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_337:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_338:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_339:[0-9a-zA-Z_\.]+]] = %[[VAL_337]] to %[[VAL_336]] step %[[VAL_338]] {
// TEMPLATED-NEXT:            %[[VAL_340:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_316]]{{\[}}%[[VAL_339]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_341:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_317]]{{\[}}%[[VAL_339]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_342:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_340]], @b = %[[VAL_341]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_335]]{{\[}}%[[VAL_339]]] = %[[VAL_342]] : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_343:[0-9a-zA-Z_\.]+]] = array.new  : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_344:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_345:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_347:[0-9a-zA-Z_\.]+]] = %[[VAL_345]] to %[[VAL_344]] step %[[VAL_346]] {
// TEMPLATED-NEXT:            %[[VAL_348:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_318]]{{\[}}%[[VAL_347]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_349:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_319]]{{\[}}%[[VAL_347]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_350:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_348]], @b = %[[VAL_349]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_343]]{{\[}}%[[VAL_347]]] = %[[VAL_350]] : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_327]], %[[VAL_335]], %[[VAL_343]]) : (!array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_320]][@"$component"] = %[[VAL_351]] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_358:[0-9a-zA-Z_\.]+]] = %[[VAL_356]] to %[[VAL_355]] step %[[VAL_357]] {
// TEMPLATED-NEXT:            %[[VAL_359:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_354]]{{\[}}%[[VAL_358]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_359]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_352]]{{\[}}%[[VAL_358]]] = %[[VAL_360]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_361:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_359]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_353]]{{\[}}%[[VAL_358]]] = %[[VAL_361]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_320]][@out.a] = %[[VAL_352]] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_320]][@out.b] = %[[VAL_353]] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_320]] : !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_362:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>>, %[[VAL_363:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_364:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_365:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_366:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_367:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_368:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_369:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_370:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_369]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_371:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_371]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_373:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_374:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_373]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_375:[0-9a-zA-Z_\.]+]] = array.new  : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_376:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_377:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_378:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_379:[0-9a-zA-Z_\.]+]] = %[[VAL_377]] to %[[VAL_376]] step %[[VAL_378]] {
// TEMPLATED-NEXT:            %[[VAL_380:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_363]]{{\[}}%[[VAL_379]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_364]]{{\[}}%[[VAL_379]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_380]], @b = %[[VAL_381]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_375]]{{\[}}%[[VAL_379]]] = %[[VAL_382]] : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_383:[0-9a-zA-Z_\.]+]] = array.new  : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_384:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_385:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_386:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_387:[0-9a-zA-Z_\.]+]] = %[[VAL_385]] to %[[VAL_384]] step %[[VAL_386]] {
// TEMPLATED-NEXT:            %[[VAL_388:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_365]]{{\[}}%[[VAL_387]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_389:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_366]]{{\[}}%[[VAL_387]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_390:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_388]], @b = %[[VAL_389]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_383]]{{\[}}%[[VAL_387]]] = %[[VAL_390]] : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_391:[0-9a-zA-Z_\.]+]] = array.new  : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_392:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_393:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_394:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_395:[0-9a-zA-Z_\.]+]] = %[[VAL_393]] to %[[VAL_392]] step %[[VAL_394]] {
// TEMPLATED-NEXT:            %[[VAL_396:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_367]]{{\[}}%[[VAL_395]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_397:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_368]]{{\[}}%[[VAL_395]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_398:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_396]], @b = %[[VAL_397]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_391]]{{\[}}%[[VAL_395]]] = %[[VAL_398]] : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_399:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_362]][@"$component"] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_399]], %[[VAL_375]], %[[VAL_383]], %[[VAL_391]]) : (!struct.type<@B::@B<[@n1, @n2, @n3]>>, !array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// TEMPLATED-NEXT:          %[[VAL_400:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_362]][@out.a] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_401:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_362]][@out.b] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_402:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_399]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_403:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_404:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_405:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_406:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_407:[0-9a-zA-Z_\.]+]] = %[[VAL_405]] to %[[VAL_404]] step %[[VAL_406]] {
// TEMPLATED-NEXT:            %[[VAL_408:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_400]]{{\[}}%[[VAL_407]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_409:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_407]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_410:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_408]], @b = %[[VAL_409]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_403]]{{\[}}%[[VAL_407]]] = %[[VAL_410]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_411:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_412:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_413:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_414:[0-9a-zA-Z_\.]+]] = %[[VAL_412]] to %[[VAL_411]] step %[[VAL_413]] {
// TEMPLATED-NEXT:            %[[VAL_415:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_402]]{{\[}}%[[VAL_414]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_416:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_403]]{{\[}}%[[VAL_414]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_417:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_415]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_418:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_416]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_417]], %[[VAL_418]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_419:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_415]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_420:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_416]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_419]], %[[VAL_420]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
