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
        for (var j_m = 0; j_m < sizes_m[i]; j_m++){
            if (i == 0){
                aux[i].in[j_m].a <-- in1[j_m].a;
                aux[i].in[j_m].b <-- in1[j_m].b;
                in1[j_m].a === aux[i].in[j_m].a;
                aux[i].in[j_m].b === in1[j_m].b;
            } else if (i == 1){
                aux[i].in[j_m].a <-- in2[j_m].a;
                aux[i].in[j_m].b <-- in2[j_m].b;
                aux[i].in[j_m].a === in2[j_m].a;
                in2[j_m].b === aux[i].in[j_m].b;
            } else{
                aux[i].in[j_m].a <-- in3[j_m].a;
                aux[i].in[j_m].b <-- in3[j_m].b;
                in3[j_m].a === aux[i].in[j_m].a;
                in3[j_m].b === aux[i].in[j_m].b;
            }
        }

        out[i] <-- aux[i].out[0].b[0];
        out[i] === aux[i].out[0].b[0];
    }
}

component main = B(2, 5, 6,3,8,3);

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_3::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    module @global {
// CONCRETE-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  6 : <"bn128">,  8 : <"bn128">]
// CONCRETE-NEXT:      global.def const @array_const_1 : !array.type<3 x !felt.type<"bn128">> = [ 5 : <"bn128">,  3 : <"bn128">,  3 : <"bn128">]
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A_0::@A_0<[]>>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A_0::@A_0<[]>>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_5]] step %[[VAL_7]] {
// CONCRETE-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_8]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_8]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
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
// CONCRETE-NEXT:    poly.template @A_1 {
// CONCRETE-NEXT:      struct.def @A_1 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>> {function.arg_name = "in"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_16]][@out] = %[[VAL_15]] : <@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          function.return %[[VAL_16]] : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_21]] to %[[VAL_20]] step %[[VAL_22]] {
// CONCRETE-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_23]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_23]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@a] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@a] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_26]], %[[VAL_27]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@b] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@b] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_28]], %[[VAL_29]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_2 {
// CONCRETE-NEXT:      struct.def @A_2 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>> {function.arg_name = "in"}) -> !struct.type<@A_2::@A_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@A_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_31]][@out] = %[[VAL_30]] : <@A_2::@A_2<[]>>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          function.return %[[VAL_31]] : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@A_2<[]>>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@out] : <@A_2::@A_2<[]>>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_36]] to %[[VAL_35]] step %[[VAL_37]] {
// CONCRETE-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_38]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_38]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@a] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@a] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_41]], %[[VAL_42]] : !array.type<8 x !felt.type<"bn128">>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@b] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@b] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_43]], %[[VAL_44]] : !array.type<8 x !felt.type<"bn128">>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_3 {
// CONCRETE-NEXT:      struct.def @B_3 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE-NEXT:        struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in1"}, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>> {function.arg_name = "in2"}, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>> {function.arg_name = "in3"}) -> !struct.type<@B_3::@B_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.new : <@B_3::@B_3<[]>>
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 20 : index
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_51]], @params = %[[VAL_50]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 36 : index
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_53]], @params = %[[VAL_50]] }  : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 48 : index
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_55]], @params = %[[VAL_50]] }  : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_52]], @idx_1 = %[[VAL_54]], @idx_2 = %[[VAL_56]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_63:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_64:[0-9a-zA-Z_\.]+]] = %[[VAL_58]], %[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_61]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_65]], %[[VAL_66]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_67]]) %[[VAL_63]], %[[VAL_64]], %[[VAL_65]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_68]], %[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_69]], %[[VAL_75:[0-9a-zA-Z_\.]+]] = %[[VAL_71]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !felt.type<"bn128">) {
// CONCRETE-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_60]]{{\[}}%[[VAL_76]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_75]], %[[VAL_77]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_78]]) %[[VAL_73]], %[[VAL_74]], %[[VAL_75]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_70]], %[[VAL_82]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_83]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_85]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_88]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_89]], %[[VAL_91]] : index
// CONCRETE-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_90]], %[[VAL_92]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_89]], %[[VAL_94]] : index
// CONCRETE-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_90]], %[[VAL_95]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_96]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_97]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_89]], %[[VAL_98]] : index
// CONCRETE-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_90]], %[[VAL_99]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_100]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_101]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_102:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_103:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_93]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@in] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_107]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_108]][@a] = %[[VAL_87]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    array.write %[[VAL_106]]{{\[}}%[[VAL_107]]] = %[[VAL_108]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_105]][@in] = %[[VAL_106]] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_80]][@idx_0] = %[[VAL_105]] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_104]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                    %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_110]], %[[VAL_111]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_104]][@count] = %[[VAL_112]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_112]], %[[VAL_113]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_114]] {
// CONCRETE-NEXT:                      %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_104]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@in] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      %[[VAL_117:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_116]]) : (!array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_104]][@comp] = %[[VAL_117]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_79]][@idx_0] = %[[VAL_104]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_79]], %[[VAL_80]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_118:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_119:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_118]], %[[VAL_119]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_103]]#0, %[[VAL_103]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_120]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_124]], %[[VAL_126]] : index
// CONCRETE-NEXT:                %[[VAL_128:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_125]], %[[VAL_127]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_124]], %[[VAL_129]] : index
// CONCRETE-NEXT:                %[[VAL_131:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_125]], %[[VAL_130]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_132:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_131]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_132]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_124]], %[[VAL_133]] : index
// CONCRETE-NEXT:                %[[VAL_135:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_125]], %[[VAL_134]] : i1, i1
// CONCRETE-NEXT:                %[[VAL_136:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_135]] : i1
// CONCRETE-NEXT:                bool.assert %[[VAL_136]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                %[[VAL_137:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_138:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_128]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]]#1[@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@in] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_142]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    pod.write %[[VAL_143]][@b] = %[[VAL_122]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    array.write %[[VAL_141]]{{\[}}%[[VAL_142]]] = %[[VAL_143]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_140]][@in] = %[[VAL_141]] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_102]]#1[@idx_0] = %[[VAL_140]] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                    %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_139]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                    %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_145]], %[[VAL_146]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_139]][@count] = %[[VAL_147]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_147]], %[[VAL_148]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_149]] {
// CONCRETE-NEXT:                      %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_139]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@in] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      %[[VAL_152:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_151]]) : (!array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_139]][@comp] = %[[VAL_152]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_102]]#0[@idx_0] = %[[VAL_139]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_102]]#0, %[[VAL_102]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_153:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_154:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_153]], %[[VAL_154]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_138]]#0, %[[VAL_138]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_137]]#0, %[[VAL_137]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_156:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_70]], %[[VAL_155]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_157:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_156]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_158]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_159]][@a] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                  %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_165:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_162]], %[[VAL_164]] : index
// CONCRETE-NEXT:                  %[[VAL_166:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_163]], %[[VAL_165]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_167:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_166]] : i1
// CONCRETE-NEXT:                  bool.assert %[[VAL_167]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                  %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_162]], %[[VAL_168]] : index
// CONCRETE-NEXT:                  %[[VAL_170:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_163]], %[[VAL_169]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                  %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_162]], %[[VAL_171]] : index
// CONCRETE-NEXT:                  %[[VAL_173:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_163]], %[[VAL_172]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_174:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_173]] : i1
// CONCRETE-NEXT:                  bool.assert %[[VAL_174]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                  %[[VAL_175:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_176:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_170]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                      %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      %[[VAL_180:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                      %[[VAL_181:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_180]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@a] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      pod.write %[[VAL_181]][@a] = %[[VAL_160]] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      array.write %[[VAL_179]]{{\[}}%[[VAL_180]]] = %[[VAL_181]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      pod.write %[[VAL_178]][@in] = %[[VAL_179]] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_80]][@idx_1] = %[[VAL_178]] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                      %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@count] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CONCRETE-NEXT:                      %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_183]], %[[VAL_184]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_177]][@count] = %[[VAL_185]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_185]], %[[VAL_186]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_187]] {
// CONCRETE-NEXT:                        %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@params] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                        %[[VAL_190:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_189]]) : (!array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_177]][@comp] = %[[VAL_190]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_79]][@idx_1] = %[[VAL_177]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_79]], %[[VAL_80]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_191:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                      %[[VAL_192:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_191]], %[[VAL_192]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_176]]#0, %[[VAL_176]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_194:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_193]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@b] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                  %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_197]], %[[VAL_199]] : index
// CONCRETE-NEXT:                  %[[VAL_201:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_198]], %[[VAL_200]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_202:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_201]] : i1
// CONCRETE-NEXT:                  bool.assert %[[VAL_202]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                  %[[VAL_203:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_204:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_197]], %[[VAL_203]] : index
// CONCRETE-NEXT:                  %[[VAL_205:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_198]], %[[VAL_204]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_206:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                  %[[VAL_207:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_197]], %[[VAL_206]] : index
// CONCRETE-NEXT:                  %[[VAL_208:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_198]], %[[VAL_207]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_209:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_208]] : i1
// CONCRETE-NEXT:                  bool.assert %[[VAL_209]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                  %[[VAL_210:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_211:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_205]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_175]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_213:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_175]]#1[@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                      %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      %[[VAL_215:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                      %[[VAL_216:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_214]]{{\[}}%[[VAL_215]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@b] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      pod.write %[[VAL_216]][@b] = %[[VAL_195]] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      array.write %[[VAL_214]]{{\[}}%[[VAL_215]]] = %[[VAL_216]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      pod.write %[[VAL_213]][@in] = %[[VAL_214]] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_175]]#1[@idx_1] = %[[VAL_213]] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                      %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@count] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_219:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CONCRETE-NEXT:                      %[[VAL_220:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_218]], %[[VAL_219]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_212]][@count] = %[[VAL_220]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_220]], %[[VAL_221]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_222]] {
// CONCRETE-NEXT:                        %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_212]][@params] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_224:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                        %[[VAL_225:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_224]]) : (!array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_212]][@comp] = %[[VAL_225]] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_175]]#0[@idx_1] = %[[VAL_212]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_175]]#0, %[[VAL_175]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_226:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                      %[[VAL_227:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_226]], %[[VAL_227]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_211]]#0, %[[VAL_211]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_210]]#0, %[[VAL_210]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_228:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_229:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_228]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_230:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_229]][@a] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_232:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_231]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_233:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                  %[[VAL_234:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_235:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_232]], %[[VAL_234]] : index
// CONCRETE-NEXT:                  %[[VAL_236:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_233]], %[[VAL_235]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_237:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_236]] : i1
// CONCRETE-NEXT:                  bool.assert %[[VAL_237]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                  %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_239:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_232]], %[[VAL_238]] : index
// CONCRETE-NEXT:                  %[[VAL_240:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_233]], %[[VAL_239]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_241:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_240]] : i1
// CONCRETE-NEXT:                  bool.assert %[[VAL_241]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                  %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                  %[[VAL_243:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_232]], %[[VAL_242]] : index
// CONCRETE-NEXT:                  %[[VAL_244:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_233]], %[[VAL_243]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_245:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_246:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_244]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                      %[[VAL_249:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_248]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                      %[[VAL_251:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_250]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_252:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_251]][@a] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      pod.write %[[VAL_251]][@a] = %[[VAL_230]] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      array.write %[[VAL_249]]{{\[}}%[[VAL_250]]] = %[[VAL_251]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      pod.write %[[VAL_248]][@in] = %[[VAL_249]] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_80]][@idx_2] = %[[VAL_248]] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                      %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@count] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_254:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:                      %[[VAL_255:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_253]], %[[VAL_254]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_247]][@count] = %[[VAL_255]] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_256:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_257:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_255]], %[[VAL_256]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_257]] {
// CONCRETE-NEXT:                        %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@params] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_259:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_248]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                        %[[VAL_260:[0-9a-zA-Z_\.]+]] = function.call @A_2::@A_2::@compute(%[[VAL_259]]) : (!array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_247]][@comp] = %[[VAL_260]] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_79]][@idx_2] = %[[VAL_247]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_79]], %[[VAL_80]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_261:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                      %[[VAL_262:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_261]], %[[VAL_262]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_246]]#0, %[[VAL_246]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  %[[VAL_263:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_264:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_263]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_265:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_264]][@b] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_266:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_266]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_268:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:                  %[[VAL_269:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_270:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_267]], %[[VAL_269]] : index
// CONCRETE-NEXT:                  %[[VAL_271:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_268]], %[[VAL_270]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_272:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_271]] : i1
// CONCRETE-NEXT:                  bool.assert %[[VAL_272]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                  %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_274:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_267]], %[[VAL_273]] : index
// CONCRETE-NEXT:                  %[[VAL_275:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_268]], %[[VAL_274]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_276:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_275]] : i1
// CONCRETE-NEXT:                  bool.assert %[[VAL_276]], "incompatible mixed component bus input"
// CONCRETE-NEXT:                  %[[VAL_277:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                  %[[VAL_278:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_267]], %[[VAL_277]] : index
// CONCRETE-NEXT:                  %[[VAL_279:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_268]], %[[VAL_278]] : i1, i1
// CONCRETE-NEXT:                  %[[VAL_280:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_281:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_279]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>) {
// CONCRETE-NEXT:                      %[[VAL_282:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      %[[VAL_283:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]]#1[@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                      %[[VAL_284:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_283]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      %[[VAL_285:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CONCRETE-NEXT:                      %[[VAL_286:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_284]]{{\[}}%[[VAL_285]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      %[[VAL_287:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_286]][@b] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      pod.write %[[VAL_286]][@b] = %[[VAL_265]] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                      array.write %[[VAL_284]]{{\[}}%[[VAL_285]]] = %[[VAL_286]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                      pod.write %[[VAL_283]][@in] = %[[VAL_284]] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_245]]#1[@idx_2] = %[[VAL_283]] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                      %[[VAL_288:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_282]][@count] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_289:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:                      %[[VAL_290:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_288]], %[[VAL_289]] : index
// CONCRETE-NEXT:                      pod.write %[[VAL_282]][@count] = %[[VAL_290]] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                      %[[VAL_291:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                      %[[VAL_292:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_290]], %[[VAL_291]] : index
// CONCRETE-NEXT:                      scf.if %[[VAL_292]] {
// CONCRETE-NEXT:                        %[[VAL_293:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_282]][@params] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                        %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_283]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                        %[[VAL_295:[0-9a-zA-Z_\.]+]] = function.call @A_2::@A_2::@compute(%[[VAL_294]]) : (!array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                        pod.write %[[VAL_282]][@comp] = %[[VAL_295]] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                      }
// CONCRETE-NEXT:                      pod.write %[[VAL_245]]#0[@idx_2] = %[[VAL_282]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_245]]#0, %[[VAL_245]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    } else {
// CONCRETE-NEXT:                      %[[VAL_296:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                      %[[VAL_297:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                      scf.yield %[[VAL_296]], %[[VAL_297]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    scf.yield %[[VAL_281]]#0, %[[VAL_281]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_280]]#0, %[[VAL_280]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_157]]#0, %[[VAL_157]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_81]], %[[VAL_298]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_84]]#0, %[[VAL_84]]#1, %[[VAL_299]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_302:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_303:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_300]], %[[VAL_302]] : index
// CONCRETE-NEXT:            %[[VAL_304:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_301]], %[[VAL_303]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_306:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_300]], %[[VAL_305]] : index
// CONCRETE-NEXT:            %[[VAL_307:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_301]], %[[VAL_306]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_308:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_300]], %[[VAL_308]] : index
// CONCRETE-NEXT:            %[[VAL_310:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_301]], %[[VAL_309]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_310]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_314:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_313]][@comp] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                %[[VAL_315:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_314]][@out] : <@A_2::@A_2<[]>>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                %[[VAL_316:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_317:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_316]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_318:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_315]]{{\[}}%[[VAL_317]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@b] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_320:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_320]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_322:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_319]]{{\[}}%[[VAL_321]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.yield %[[VAL_322]] : !felt.type<"bn128">
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_323:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_307]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                  %[[VAL_324:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_325:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_324]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  %[[VAL_326:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_325]][@out] : <@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_327:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_328:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_327]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_329:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_326]]{{\[}}%[[VAL_328]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_330:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_329]][@b] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_331:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_332:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_331]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_333:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_330]]{{\[}}%[[VAL_332]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  scf.yield %[[VAL_333]] : !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_334:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_304]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                    %[[VAL_335:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_336:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_335]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    %[[VAL_337:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_336]][@out] : <@A_0::@A_0<[]>>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_338:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_339:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_338]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_340:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_337]]{{\[}}%[[VAL_339]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_341:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_342:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_343:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_342]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_344:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_341]]{{\[}}%[[VAL_343]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    scf.yield %[[VAL_344]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_345:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CONCRETE-NEXT:                    scf.yield %[[VAL_345]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_334]] : !felt.type<"bn128">
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_323]] : !felt.type<"bn128">
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_312]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_49]]{{\[}}%[[VAL_346]]] = %[[VAL_311]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_347:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_70]], %[[VAL_347]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_72]]#0, %[[VAL_72]]#1, %[[VAL_348]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_48]][@aux$inputs] = %[[VAL_62]]#1 : <@B_3::@B_3<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_349]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_351]][@comp] : <[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]]#0[@idx_2] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@A_1::@A_1<[]>>, @params: !pod.type<[]>]>, @idx_2: !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@comp] : <[@count: index, @comp: !struct.type<@A_2::@A_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_350]], @idx_1 = %[[VAL_352]], @idx_2 = %[[VAL_354]] }  : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_48]][@aux] = %[[VAL_355]] : <@B_3::@B_3<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_48]][@out] = %[[VAL_49]] : <@B_3::@B_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_48]] : !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_356:[0-9a-zA-Z_\.]+]]: !struct.type<@B_3::@B_3<[]>>, %[[VAL_357:[0-9a-zA-Z_\.]+]]: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>> {function.arg_name = "in1"}, %[[VAL_358:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>> {function.arg_name = "in2"}, %[[VAL_359:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_360:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_356]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_356]][@aux] : <@B_3::@B_3<[]>>, !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE-NEXT:          %[[VAL_362:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_356]][@aux$inputs] : <@B_3::@B_3<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_363:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_364:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_365:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_366:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_367:[0-9a-zA-Z_\.]+]] = %[[VAL_365]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_368:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_369:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_367]], %[[VAL_368]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_369]]) %[[VAL_367]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_370:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_371:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_372:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_373:[0-9a-zA-Z_\.]+]] = %[[VAL_371]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_374:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_370]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_375:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_364]]{{\[}}%[[VAL_374]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_376:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_373]], %[[VAL_375]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_376]]) %[[VAL_373]] : !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_377:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_378:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_379:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_370]], %[[VAL_378]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.if %[[VAL_379]] {
// CONCRETE-NEXT:                %[[VAL_380:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_381:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_357]]{{\[}}%[[VAL_380]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_382:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_381]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_383:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                %[[VAL_384:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_383]][@in] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                %[[VAL_385:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_386:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_384]]{{\[}}%[[VAL_385]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_387:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_386]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                constrain.eq %[[VAL_382]], %[[VAL_387]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_388:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                %[[VAL_389:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_388]][@in] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                %[[VAL_390:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_391:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_389]]{{\[}}%[[VAL_390]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_392:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_391]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_393:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_394:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_357]]{{\[}}%[[VAL_393]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_395:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_394]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                constrain.eq %[[VAL_392]], %[[VAL_395]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_396:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_397:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_370]], %[[VAL_396]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.if %[[VAL_397]] {
// CONCRETE-NEXT:                  %[[VAL_398:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  %[[VAL_399:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_398]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_400:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_401:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_399]]{{\[}}%[[VAL_400]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_402:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_401]][@a] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_403:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_404:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_358]]{{\[}}%[[VAL_403]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_405:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_404]][@a] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  constrain.eq %[[VAL_402]], %[[VAL_405]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_406:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_407:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_358]]{{\[}}%[[VAL_406]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_408:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_407]][@b] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_409:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  %[[VAL_410:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_409]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_411:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_412:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_410]]{{\[}}%[[VAL_411]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_413:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_412]][@b] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  constrain.eq %[[VAL_408]], %[[VAL_413]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_414:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_415:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_359]]{{\[}}%[[VAL_414]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_416:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_415]][@a] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_417:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  %[[VAL_418:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_417]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_419:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_420:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_418]]{{\[}}%[[VAL_419]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_421:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_420]][@a] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  constrain.eq %[[VAL_416]], %[[VAL_421]] : !array.type<8 x !felt.type<"bn128">>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_422:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_423:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_359]]{{\[}}%[[VAL_422]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_424:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_423]][@b] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_425:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:                  %[[VAL_426:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_425]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_427:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_377]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_428:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_426]]{{\[}}%[[VAL_427]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_429:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_428]][@b] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  constrain.eq %[[VAL_424]], %[[VAL_429]] : !array.type<8 x !felt.type<"bn128">>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_430:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_431:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_377]], %[[VAL_430]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_431]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_432:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_370]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_433:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_360]]{{\[}}%[[VAL_432]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_434:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_370]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_435:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:            %[[VAL_436:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_437:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_434]], %[[VAL_436]] : index
// CONCRETE-NEXT:            %[[VAL_438:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_435]], %[[VAL_437]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_439:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_440:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_434]], %[[VAL_439]] : index
// CONCRETE-NEXT:            %[[VAL_441:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_435]], %[[VAL_440]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_442:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_443:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_434]], %[[VAL_442]] : index
// CONCRETE-NEXT:            %[[VAL_444:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_435]], %[[VAL_443]] : i1, i1
// CONCRETE-NEXT:            %[[VAL_445:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_446:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_444]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                %[[VAL_447:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_361]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:                %[[VAL_448:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_447]][@out] : <@A_2::@A_2<[]>>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                %[[VAL_449:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_450:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_449]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_451:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_448]]{{\[}}%[[VAL_450]]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                %[[VAL_452:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_451]][@b] : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>, !array.type<8 x !felt.type<"bn128">>
// CONCRETE-NEXT:                %[[VAL_453:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_454:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_453]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_455:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_452]]{{\[}}%[[VAL_454]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                scf.yield %[[VAL_455]] : !felt.type<"bn128">
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_456:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_441]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                  %[[VAL_457:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_361]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:                  %[[VAL_458:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_457]][@out] : <@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                  %[[VAL_459:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_460:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_459]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_461:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_458]]{{\[}}%[[VAL_460]]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                  %[[VAL_462:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_461]][@b] : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CONCRETE-NEXT:                  %[[VAL_463:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                  %[[VAL_464:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_463]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_465:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_462]]{{\[}}%[[VAL_464]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                  scf.yield %[[VAL_465]] : !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_466:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_438]] -> (!felt.type<"bn128">) {
// CONCRETE-NEXT:                    %[[VAL_467:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_361]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    %[[VAL_468:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_467]][@out] : <@A_0::@A_0<[]>>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:                    %[[VAL_469:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_470:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_469]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_471:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_468]]{{\[}}%[[VAL_470]]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:                    %[[VAL_472:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_471]][@b] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:                    %[[VAL_473:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:                    %[[VAL_474:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_473]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_475:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_472]]{{\[}}%[[VAL_474]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:                    scf.yield %[[VAL_475]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_476:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CONCRETE-NEXT:                    scf.yield %[[VAL_476]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_466]] : !felt.type<"bn128">
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_456]] : !felt.type<"bn128">
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_446]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            constrain.eq %[[VAL_433]], %[[VAL_445]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_477:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_478:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_370]], %[[VAL_477]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_478]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_479:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_361]][@idx_0] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_480:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_481:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_480]][@in] : <[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_479]], %[[VAL_481]]) : (!struct.type<@A_0::@A_0<[]>>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_482:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_361]][@idx_1] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_483:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_484:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_483]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_482]], %[[VAL_484]]) : (!struct.type<@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_485:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_361]][@idx_2] : <[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_486:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_362]][@idx_2] : <[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_487:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_486]][@in] : <[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          function.call @A_2::@A_2::@constrain(%[[VAL_485]], %[[VAL_487]]) : (!struct.type<@A_2::@A_2<[]>>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_488:[0-9a-zA-Z_\.]+]]: !array.type<5,2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_489:[0-9a-zA-Z_\.]+]]: !array.type<5,2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_490:[0-9a-zA-Z_\.]+]]: !array.type<3,6 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_491:[0-9a-zA-Z_\.]+]]: !array.type<3,6 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_492:[0-9a-zA-Z_\.]+]]: !array.type<3,8 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_493:[0-9a-zA-Z_\.]+]]: !array.type<3,8 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B_3::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_494:[0-9a-zA-Z_\.]+]] = struct.new : <@B_3::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_495:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_496:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CONCRETE-NEXT:          %[[VAL_497:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_498:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_499:[0-9a-zA-Z_\.]+]] = %[[VAL_497]] to %[[VAL_496]] step %[[VAL_498]] {
// CONCRETE-NEXT:            %[[VAL_500:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_488]]{{\[}}%[[VAL_499]]] : <5,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_501:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_489]]{{\[}}%[[VAL_499]]] : <5,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_502:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_500]], @b = %[[VAL_501]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_495]]{{\[}}%[[VAL_499]]] = %[[VAL_502]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_503:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_504:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_505:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_506:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_507:[0-9a-zA-Z_\.]+]] = %[[VAL_505]] to %[[VAL_504]] step %[[VAL_506]] {
// CONCRETE-NEXT:            %[[VAL_508:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_490]]{{\[}}%[[VAL_507]]] : <3,6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_509:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_491]]{{\[}}%[[VAL_507]]] : <3,6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_510:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_508]], @b = %[[VAL_509]] }  : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_503]]{{\[}}%[[VAL_507]]] = %[[VAL_510]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_511:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_512:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_513:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_514:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_515:[0-9a-zA-Z_\.]+]] = %[[VAL_513]] to %[[VAL_512]] step %[[VAL_514]] {
// CONCRETE-NEXT:            %[[VAL_516:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_492]]{{\[}}%[[VAL_515]]] : <3,8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_517:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_493]]{{\[}}%[[VAL_515]]] : <3,8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_518:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_516]], @b = %[[VAL_517]] }  : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_511]]{{\[}}%[[VAL_515]]] = %[[VAL_518]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_519:[0-9a-zA-Z_\.]+]] = function.call @B_3::@B_3::@compute(%[[VAL_495]], %[[VAL_503]], %[[VAL_511]]) : (!array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>) -> !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_494]][@"$component"] = %[[VAL_519]] : <@B_3::@"$bus_entry"<[]>>, !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:          %[[VAL_520:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_519]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_494]][@out] = %[[VAL_520]] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_494]] : !struct.type<@B_3::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_521:[0-9a-zA-Z_\.]+]]: !struct.type<@B_3::@"$bus_entry"<[]>>, %[[VAL_522:[0-9a-zA-Z_\.]+]]: !array.type<5,2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_523:[0-9a-zA-Z_\.]+]]: !array.type<5,2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_524:[0-9a-zA-Z_\.]+]]: !array.type<3,6 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_525:[0-9a-zA-Z_\.]+]]: !array.type<3,6 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_526:[0-9a-zA-Z_\.]+]]: !array.type<3,8 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_527:[0-9a-zA-Z_\.]+]]: !array.type<3,8 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_528:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_529:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CONCRETE-NEXT:          %[[VAL_530:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_531:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_532:[0-9a-zA-Z_\.]+]] = %[[VAL_530]] to %[[VAL_529]] step %[[VAL_531]] {
// CONCRETE-NEXT:            %[[VAL_533:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_522]]{{\[}}%[[VAL_532]]] : <5,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_534:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_523]]{{\[}}%[[VAL_532]]] : <5,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_535:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_533]], @b = %[[VAL_534]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_528]]{{\[}}%[[VAL_532]]] = %[[VAL_535]] : <5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_536:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_537:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_538:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_539:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_540:[0-9a-zA-Z_\.]+]] = %[[VAL_538]] to %[[VAL_537]] step %[[VAL_539]] {
// CONCRETE-NEXT:            %[[VAL_541:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_524]]{{\[}}%[[VAL_540]]] : <3,6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_542:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_525]]{{\[}}%[[VAL_540]]] : <3,6 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_543:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_541]], @b = %[[VAL_542]] }  : <[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_536]]{{\[}}%[[VAL_540]]] = %[[VAL_543]] : <3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_544:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_545:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_546:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_547:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_548:[0-9a-zA-Z_\.]+]] = %[[VAL_546]] to %[[VAL_545]] step %[[VAL_547]] {
// CONCRETE-NEXT:            %[[VAL_549:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_526]]{{\[}}%[[VAL_548]]] : <3,8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_550:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_527]]{{\[}}%[[VAL_548]]] : <3,8 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_551:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_549]], @b = %[[VAL_550]] }  : <[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_544]]{{\[}}%[[VAL_548]]] = %[[VAL_551]] : <3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_552:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_521]][@"$component"] : <@B_3::@"$bus_entry"<[]>>, !struct.type<@B_3::@B_3<[]>>
// CONCRETE-NEXT:          function.call @B_3::@B_3::@constrain(%[[VAL_552]], %[[VAL_528]], %[[VAL_536]], %[[VAL_544]]) : (!struct.type<@B_3::@B_3<[]>>, !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>, !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>, !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_553:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_521]][@out] : <@B_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_554:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_552]][@out] : <@B_3::@B_3<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_554]], %[[VAL_553]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@"$bus_entry"<[2, 5, 6, 3, 8, 3]>>} {
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
// TEMPLATED-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_137]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_136]], %[[VAL_138]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_139]]) %[[VAL_134]], %[[VAL_135]], %[[VAL_136]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_140:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, %[[VAL_141:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, %[[VAL_142:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_103]], %[[VAL_143]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_145:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_144]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>) {
// TEMPLATED-NEXT:                %[[VAL_146:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_147:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_146]]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_147]][@a] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_150:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_149]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                %[[VAL_151:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_149]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_150]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                %[[VAL_153:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_153]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_156:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_148]] : (!array.type<@n1 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_154]][@a] = %[[VAL_156]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                array.write %[[VAL_152]]{{\[}}%[[VAL_153]]] = %[[VAL_154]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                pod.write %[[VAL_150]][@in] = %[[VAL_152]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_158:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_157]], %[[VAL_158]] : index
// TEMPLATED-NEXT:                %[[VAL_160:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_159]], %[[VAL_160]], %[[VAL_158]] : index
// TEMPLATED-NEXT:                %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_161]], %[[VAL_162]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_163]] {
// TEMPLATED-NEXT:                  %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_166:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_164]], %[[VAL_165]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_151]][@count] = %[[VAL_166]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_166]], %[[VAL_167]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_168]] {
// TEMPLATED-NEXT:                    %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_150]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_172:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_171]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_173]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_175:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_170]]) {(%[[VAL_172]]), (%[[VAL_174]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_151]][@comp] = %[[VAL_175]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_141]]{{\[}}%[[VAL_149]]] = %[[VAL_150]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                array.write %[[VAL_140]]{{\[}}%[[VAL_149]]] = %[[VAL_151]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_177:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_176]]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@b] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_179]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                %[[VAL_181:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_179]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                %[[VAL_183:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_184:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_183]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_186:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_178]] : (!array.type<@n1 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                pod.write %[[VAL_184]][@b] = %[[VAL_186]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                array.write %[[VAL_182]]{{\[}}%[[VAL_183]]] = %[[VAL_184]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                pod.write %[[VAL_180]][@in] = %[[VAL_182]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_187]], %[[VAL_188]] : index
// TEMPLATED-NEXT:                %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_189]], %[[VAL_190]], %[[VAL_188]] : index
// TEMPLATED-NEXT:                %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_191]], %[[VAL_192]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_193]] {
// TEMPLATED-NEXT:                  %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_194]], %[[VAL_195]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_181]][@count] = %[[VAL_196]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_197:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_196]], %[[VAL_197]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_198]] {
// TEMPLATED-NEXT:                    %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                    %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_199]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_202:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_201]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_199]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_204:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_203]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_205:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_200]]) {(%[[VAL_202]]), (%[[VAL_204]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_181]][@comp] = %[[VAL_205]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_141]]{{\[}}%[[VAL_179]]] = %[[VAL_180]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                array.write %[[VAL_140]]{{\[}}%[[VAL_179]]] = %[[VAL_181]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                scf.yield %[[VAL_140]], %[[VAL_141]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:              } else {
// TEMPLATED-NEXT:                %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:                %[[VAL_207:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_103]], %[[VAL_206]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_208:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_207]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>) {
// TEMPLATED-NEXT:                  %[[VAL_209:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_210:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_209]]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@a] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_212]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_214:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_212]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_216:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_217:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_215]]{{\[}}%[[VAL_216]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_219:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_211]] : (!array.type<@n2 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  pod.write %[[VAL_217]][@a] = %[[VAL_219]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  array.write %[[VAL_215]]{{\[}}%[[VAL_216]]] = %[[VAL_217]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  pod.write %[[VAL_213]][@in] = %[[VAL_215]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_220]], %[[VAL_221]] : index
// TEMPLATED-NEXT:                  %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                  %[[VAL_224:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_222]], %[[VAL_223]], %[[VAL_221]] : index
// TEMPLATED-NEXT:                  %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_226:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_224]], %[[VAL_225]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_226]] {
// TEMPLATED-NEXT:                    %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_228:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_229:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_227]], %[[VAL_228]] : index
// TEMPLATED-NEXT:                    pod.write %[[VAL_214]][@count] = %[[VAL_229]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_230:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_231:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_229]], %[[VAL_230]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_231]] {
// TEMPLATED-NEXT:                      %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                      %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                      %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_237:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_236]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_238:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_233]]) {(%[[VAL_235]]), (%[[VAL_237]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      pod.write %[[VAL_214]][@comp] = %[[VAL_238]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  array.write %[[VAL_141]]{{\[}}%[[VAL_212]]] = %[[VAL_213]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  array.write %[[VAL_140]]{{\[}}%[[VAL_212]]] = %[[VAL_214]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_239:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_240:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_239]]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_241:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_240]][@b] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_242:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_243:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_242]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_244:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_242]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_243]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_247:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_245]]{{\[}}%[[VAL_246]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_249:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_241]] : (!array.type<@n2 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  pod.write %[[VAL_247]][@b] = %[[VAL_249]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  array.write %[[VAL_245]]{{\[}}%[[VAL_246]]] = %[[VAL_247]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  pod.write %[[VAL_243]][@in] = %[[VAL_245]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_250:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_244]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_251:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_252:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_250]], %[[VAL_251]] : index
// TEMPLATED-NEXT:                  %[[VAL_253:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                  %[[VAL_254:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_252]], %[[VAL_253]], %[[VAL_251]] : index
// TEMPLATED-NEXT:                  %[[VAL_255:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_256:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_254]], %[[VAL_255]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_256]] {
// TEMPLATED-NEXT:                    %[[VAL_257:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_244]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_258:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_259:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_257]], %[[VAL_258]] : index
// TEMPLATED-NEXT:                    pod.write %[[VAL_244]][@count] = %[[VAL_259]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_260:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_261:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_259]], %[[VAL_260]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_261]] {
// TEMPLATED-NEXT:                      %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_244]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                      %[[VAL_263:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_243]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                      %[[VAL_264:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_262]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_266:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_262]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_266]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_268:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_263]]) {(%[[VAL_265]]), (%[[VAL_267]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      pod.write %[[VAL_244]][@comp] = %[[VAL_268]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  array.write %[[VAL_141]]{{\[}}%[[VAL_242]]] = %[[VAL_243]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  array.write %[[VAL_140]]{{\[}}%[[VAL_242]]] = %[[VAL_244]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  scf.yield %[[VAL_140]], %[[VAL_141]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:                } else {
// TEMPLATED-NEXT:                  %[[VAL_269:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_270:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_269]]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_270]][@a] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_272:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_273:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_272]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_274:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_272]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_275:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_273]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_276:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_277:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_275]]{{\[}}%[[VAL_276]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_277]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_279:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_271]] : (!array.type<@n3 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  pod.write %[[VAL_277]][@a] = %[[VAL_279]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  array.write %[[VAL_275]]{{\[}}%[[VAL_276]]] = %[[VAL_277]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  pod.write %[[VAL_273]][@in] = %[[VAL_275]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_281:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_282:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_280]], %[[VAL_281]] : index
// TEMPLATED-NEXT:                  %[[VAL_283:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                  %[[VAL_284:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_282]], %[[VAL_283]], %[[VAL_281]] : index
// TEMPLATED-NEXT:                  %[[VAL_285:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_286:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_284]], %[[VAL_285]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_286]] {
// TEMPLATED-NEXT:                    %[[VAL_287:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_288:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_289:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_287]], %[[VAL_288]] : index
// TEMPLATED-NEXT:                    pod.write %[[VAL_274]][@count] = %[[VAL_289]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_290:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_291:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_289]], %[[VAL_290]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_291]] {
// TEMPLATED-NEXT:                      %[[VAL_292:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                      %[[VAL_293:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_273]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                      %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_292]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_294]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_296:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_292]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_296]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_298:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_293]]) {(%[[VAL_295]]), (%[[VAL_297]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      pod.write %[[VAL_274]][@comp] = %[[VAL_298]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  array.write %[[VAL_141]]{{\[}}%[[VAL_272]]] = %[[VAL_273]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  array.write %[[VAL_140]]{{\[}}%[[VAL_272]]] = %[[VAL_274]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_300:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_299]]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@b] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_302:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_303:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_302]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_304:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_302]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  %[[VAL_305:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_303]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_306:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_307:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_305]]{{\[}}%[[VAL_306]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_308:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_307]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_309:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_301]] : (!array.type<@n3 x !felt.type<"bn128">>) -> !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  pod.write %[[VAL_307]][@b] = %[[VAL_309]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  array.write %[[VAL_305]]{{\[}}%[[VAL_306]]] = %[[VAL_307]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  pod.write %[[VAL_303]][@in] = %[[VAL_305]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_310:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_304]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_311:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_312:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_310]], %[[VAL_311]] : index
// TEMPLATED-NEXT:                  %[[VAL_313:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                  %[[VAL_314:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_312]], %[[VAL_313]], %[[VAL_311]] : index
// TEMPLATED-NEXT:                  %[[VAL_315:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_316:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_314]], %[[VAL_315]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_316]] {
// TEMPLATED-NEXT:                    %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_304]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_318:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_319:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_317]], %[[VAL_318]] : index
// TEMPLATED-NEXT:                    pod.write %[[VAL_304]][@count] = %[[VAL_319]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                    %[[VAL_320:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                    %[[VAL_321:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_319]], %[[VAL_320]] : index
// TEMPLATED-NEXT:                    scf.if %[[VAL_321]] {
// TEMPLATED-NEXT:                      %[[VAL_322:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_304]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                      %[[VAL_323:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_303]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                      %[[VAL_324:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_322]][@n] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_324]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_326:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_322]][@m] : <[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_327:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_326]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                      %[[VAL_328:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_323]]) {(%[[VAL_325]]), (%[[VAL_327]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                      pod.write %[[VAL_304]][@comp] = %[[VAL_328]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    }
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                  array.write %[[VAL_141]]{{\[}}%[[VAL_302]]] = %[[VAL_303]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  array.write %[[VAL_140]]{{\[}}%[[VAL_302]]] = %[[VAL_304]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                  scf.yield %[[VAL_140]], %[[VAL_141]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                scf.yield %[[VAL_208]]#0, %[[VAL_208]]#1 : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_330:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_142]], %[[VAL_329]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_145]]#0, %[[VAL_145]]#1, %[[VAL_330]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_332:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_133]]#0{{\[}}%[[VAL_331]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_333]][@out] : <@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !array.type<? x !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_336:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_335]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_337:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_334]]{{\[}}%[[VAL_336]]] : <? x !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_338:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_337]][@b] : <[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_339:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_340:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_339]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_341:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_338]]{{\[}}%[[VAL_340]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_342:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_89]]{{\[}}%[[VAL_342]]] = %[[VAL_341]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_343:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_344:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_103]], %[[VAL_343]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_133]]#0, %[[VAL_133]]#1, %[[VAL_344]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_74]][@aux$inputs] = %[[VAL_95]]#1 : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_345:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_347:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_348:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_349:[0-9a-zA-Z_\.]+]] = %[[VAL_347]] to %[[VAL_346]] step %[[VAL_348]] {
// TEMPLATED-NEXT:            %[[VAL_350:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_95]]#0{{\[}}%[[VAL_349]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_351:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_350]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @m: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_345]]{{\[}}%[[VAL_349]]] = %[[VAL_351]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_74]][@aux] = %[[VAL_345]] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_74]][@out] = %[[VAL_89]] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_74]] : !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_352:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, %[[VAL_353:[0-9a-zA-Z_\.]+]]: !array.type<@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>> {function.arg_name = "in1"}, %[[VAL_354:[0-9a-zA-Z_\.]+]]: !array.type<@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>> {function.arg_name = "in2"}, %[[VAL_355:[0-9a-zA-Z_\.]+]]: !array.type<@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_356]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_358:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_359:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_358]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_360:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_360]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_362:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_363:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_362]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_364:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_365:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_364]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_366:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_367:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_366]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_368:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_352]][@out] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_369:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_352]][@aux] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_370:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_352]][@aux$inputs] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED-NEXT:          %[[VAL_371:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_363]], %[[VAL_365]], %[[VAL_367]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_373:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_374:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_357]], %[[VAL_359]], %[[VAL_361]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_376:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_377:[0-9a-zA-Z_\.]+]] = %[[VAL_375]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_378:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_379:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_377]], %[[VAL_378]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_379]]) %[[VAL_377]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_380:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_372]]{{\[}}%[[VAL_381]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_383:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_382]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_384:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_385:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_374]]{{\[}}%[[VAL_384]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_385]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_388:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_389:[0-9a-zA-Z_\.]+]] = %[[VAL_387]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:              %[[VAL_390:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_391:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_374]]{{\[}}%[[VAL_390]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_392:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_389]], %[[VAL_391]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_392]]) %[[VAL_389]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_393:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_394:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_395:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_380]], %[[VAL_394]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.if %[[VAL_395]] {
// TEMPLATED-NEXT:                %[[VAL_396:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_397:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_353]]{{\[}}%[[VAL_396]]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_398:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_397]][@a] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_399:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_400:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_370]]{{\[}}%[[VAL_399]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                %[[VAL_401:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_400]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                %[[VAL_402:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_403:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_402]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_404:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_403]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                constrain.eq %[[VAL_398]], %[[VAL_404]] : !array.type<@n1 x !felt.type<"bn128">>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_405:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_406:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_370]]{{\[}}%[[VAL_405]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                %[[VAL_407:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_406]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                %[[VAL_408:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_409:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_407]]{{\[}}%[[VAL_408]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_410:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_409]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                %[[VAL_411:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_412:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_353]]{{\[}}%[[VAL_411]]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                %[[VAL_413:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_412]][@b] : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                constrain.eq %[[VAL_410]], %[[VAL_413]] : !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, !array.type<@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:              } else {
// TEMPLATED-NEXT:                %[[VAL_414:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:                %[[VAL_415:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_380]], %[[VAL_414]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                scf.if %[[VAL_415]] {
// TEMPLATED-NEXT:                  %[[VAL_416:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_417:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_370]]{{\[}}%[[VAL_416]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_418:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_417]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_419:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_420:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_418]]{{\[}}%[[VAL_419]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_421:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_420]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_422:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_423:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_354]]{{\[}}%[[VAL_422]]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_424:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_423]][@a] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_421]], %[[VAL_424]] : !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_425:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_426:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_354]]{{\[}}%[[VAL_425]]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_427:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_426]][@b] : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>, !array.type<@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_428:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_429:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_370]]{{\[}}%[[VAL_428]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_430:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_429]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_431:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_432:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_430]]{{\[}}%[[VAL_431]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_433:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_432]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_427]], %[[VAL_433]] : !array.type<@n2 x !felt.type<"bn128">>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                } else {
// TEMPLATED-NEXT:                  %[[VAL_434:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_435:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_355]]{{\[}}%[[VAL_434]]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_436:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_435]][@a] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_437:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_438:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_370]]{{\[}}%[[VAL_437]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_439:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_438]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_440:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_441:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_439]]{{\[}}%[[VAL_440]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_442:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_441]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_436]], %[[VAL_442]] : !array.type<@n3 x !felt.type<"bn128">>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_443:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_444:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_355]]{{\[}}%[[VAL_443]]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_445:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_444]][@b] : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>, !array.type<@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  %[[VAL_446:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_447:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_370]]{{\[}}%[[VAL_446]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:                  %[[VAL_448:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_447]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:                  %[[VAL_449:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_450:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_448]]{{\[}}%[[VAL_449]]] : <#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:                  %[[VAL_451:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_450]][@b] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_445]], %[[VAL_451]] : !array.type<@n3 x !felt.type<"bn128">>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              %[[VAL_452:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_453:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_393]], %[[VAL_452]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_453]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_454:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_455:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_368]]{{\[}}%[[VAL_454]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_456:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_457:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_369]]{{\[}}%[[VAL_456]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_458:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_457]][@out] : <@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !array.type<? x !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            %[[VAL_459:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_460:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_459]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_461:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_458]]{{\[}}%[[VAL_460]]] : <? x !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_462:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_461]][@b] : <[@a: !array.type<? x !felt.type<"bn128">>, @b: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_463:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_464:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_463]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_465:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_462]]{{\[}}%[[VAL_464]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_455]], %[[VAL_465]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_466:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_467:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_380]], %[[VAL_466]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_467]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_468:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_469:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_470:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_471:[0-9a-zA-Z_\.]+]] = %[[VAL_469]] to %[[VAL_468]] step %[[VAL_470]] {
// TEMPLATED-NEXT:            %[[VAL_472:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_369]]{{\[}}%[[VAL_471]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_473:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_370]]{{\[}}%[[VAL_471]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:            %[[VAL_474:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_473]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            function.call @A::@A::@constrain(%[[VAL_472]], %[[VAL_474]]) : (!struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_475:[0-9a-zA-Z_\.]+]]: !array.type<@m1,@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_476:[0-9a-zA-Z_\.]+]]: !array.type<@m1,@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_477:[0-9a-zA-Z_\.]+]]: !array.type<@m2,@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_478:[0-9a-zA-Z_\.]+]]: !array.type<@m2,@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_479:[0-9a-zA-Z_\.]+]]: !array.type<@m3,@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_480:[0-9a-zA-Z_\.]+]]: !array.type<@m3,@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_481:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          %[[VAL_482:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_483:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_482]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_484:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_485:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_484]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_486:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_487:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_486]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_488:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_489:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_488]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_490:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_491:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_490]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_492:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_493:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_492]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_494:[0-9a-zA-Z_\.]+]] = array.new  : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_495:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_496:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_497:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_498:[0-9a-zA-Z_\.]+]] = %[[VAL_496]] to %[[VAL_495]] step %[[VAL_497]] {
// TEMPLATED-NEXT:            %[[VAL_499:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_475]]{{\[}}%[[VAL_498]]] : <@m1,@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_500:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_476]]{{\[}}%[[VAL_498]]] : <@m1,@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_501:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_499]], @b = %[[VAL_500]] }  : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_494]]{{\[}}%[[VAL_498]]] = %[[VAL_501]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_502:[0-9a-zA-Z_\.]+]] = array.new  : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_503:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_504:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_505:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_506:[0-9a-zA-Z_\.]+]] = %[[VAL_504]] to %[[VAL_503]] step %[[VAL_505]] {
// TEMPLATED-NEXT:            %[[VAL_507:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_477]]{{\[}}%[[VAL_506]]] : <@m2,@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_508:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_478]]{{\[}}%[[VAL_506]]] : <@m2,@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_509:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_507]], @b = %[[VAL_508]] }  : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_502]]{{\[}}%[[VAL_506]]] = %[[VAL_509]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_510:[0-9a-zA-Z_\.]+]] = array.new  : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_511:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_512:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_513:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_514:[0-9a-zA-Z_\.]+]] = %[[VAL_512]] to %[[VAL_511]] step %[[VAL_513]] {
// TEMPLATED-NEXT:            %[[VAL_515:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_479]]{{\[}}%[[VAL_514]]] : <@m3,@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_516:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_480]]{{\[}}%[[VAL_514]]] : <@m3,@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_517:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_515]], @b = %[[VAL_516]] }  : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_510]]{{\[}}%[[VAL_514]]] = %[[VAL_517]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_518:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_494]], %[[VAL_502]], %[[VAL_510]]) : (!array.type<@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !array.type<@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !array.type<@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>) -> !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_481]][@"$component"] = %[[VAL_518]] : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          %[[VAL_519:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_518]][@out] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_481]][@out] = %[[VAL_519]] : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_481]] : !struct.type<@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_520:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, %[[VAL_521:[0-9a-zA-Z_\.]+]]: !array.type<@m1,@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_522:[0-9a-zA-Z_\.]+]]: !array.type<@m1,@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_523:[0-9a-zA-Z_\.]+]]: !array.type<@m2,@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_524:[0-9a-zA-Z_\.]+]]: !array.type<@m2,@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_525:[0-9a-zA-Z_\.]+]]: !array.type<@m3,@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_526:[0-9a-zA-Z_\.]+]]: !array.type<@m3,@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_527:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_528:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_527]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_529:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_530:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_529]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_531:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_532:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_531]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_533:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_534:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_533]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_535:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_536:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_535]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_537:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_538:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_537]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_539:[0-9a-zA-Z_\.]+]] = array.new  : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_540:[0-9a-zA-Z_\.]+]] = poly.read_const @m1 : index
// TEMPLATED-NEXT:          %[[VAL_541:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_542:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_543:[0-9a-zA-Z_\.]+]] = %[[VAL_541]] to %[[VAL_540]] step %[[VAL_542]] {
// TEMPLATED-NEXT:            %[[VAL_544:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_521]]{{\[}}%[[VAL_543]]] : <@m1,@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_545:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_522]]{{\[}}%[[VAL_543]]] : <@m1,@n1 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_546:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_544]], @b = %[[VAL_545]] }  : <[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_539]]{{\[}}%[[VAL_543]]] = %[[VAL_546]] : <@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_547:[0-9a-zA-Z_\.]+]] = array.new  : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_548:[0-9a-zA-Z_\.]+]] = poly.read_const @m2 : index
// TEMPLATED-NEXT:          %[[VAL_549:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_550:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_551:[0-9a-zA-Z_\.]+]] = %[[VAL_549]] to %[[VAL_548]] step %[[VAL_550]] {
// TEMPLATED-NEXT:            %[[VAL_552:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_523]]{{\[}}%[[VAL_551]]] : <@m2,@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_553:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_524]]{{\[}}%[[VAL_551]]] : <@m2,@n2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_554:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_552]], @b = %[[VAL_553]] }  : <[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_547]]{{\[}}%[[VAL_551]]] = %[[VAL_554]] : <@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_555:[0-9a-zA-Z_\.]+]] = array.new  : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_556:[0-9a-zA-Z_\.]+]] = poly.read_const @m3 : index
// TEMPLATED-NEXT:          %[[VAL_557:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_558:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_559:[0-9a-zA-Z_\.]+]] = %[[VAL_557]] to %[[VAL_556]] step %[[VAL_558]] {
// TEMPLATED-NEXT:            %[[VAL_560:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_525]]{{\[}}%[[VAL_559]]] : <@m3,@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_561:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_526]]{{\[}}%[[VAL_559]]] : <@m3,@n3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_562:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_560]], @b = %[[VAL_561]] }  : <[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_555]]{{\[}}%[[VAL_559]]] = %[[VAL_562]] : <@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_563:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_520]][@"$component"] : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_563]], %[[VAL_539]], %[[VAL_547]], %[[VAL_555]]) : (!struct.type<@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<@m1 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>>, !array.type<@m2 x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !felt.type<"bn128">>]>>, !array.type<@m3 x !pod.type<[@a: !array.type<@n3 x !felt.type<"bn128">>, @b: !array.type<@n3 x !felt.type<"bn128">>]>>) -> ()
// TEMPLATED-NEXT:          %[[VAL_564:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_520]][@out] : <@B::@"$bus_entry"<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_565:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_563]][@out] : <@B::@B<[@n1, @m1, @n2, @m2, @n3, @m3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_565]], %[[VAL_564]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
