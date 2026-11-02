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
        if (i == 0){
            aux[i].in <== in1;
        } else if (i == 1){
            aux[i].in <== in2;
        } else{
            aux[i].in <== in3;
        }
        out[i] <== aux[i].out[0];
    }
}

component main = B(2, 2, 2);

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_1::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    module @global {
// CONCRETE-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  2 : <"bn128">,  2 : <"bn128">]
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
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux : !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:        struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in1"}, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in2"}, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in3"}) -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_23]] to %[[VAL_22]] step %[[VAL_24]] {
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_26]], @params = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            array.write %[[VAL_20]]{{\[}}%[[VAL_25]]] = %[[VAL_27]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_28]], %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_30]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_34]], %[[VAL_35]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_36]]) %[[VAL_32]], %[[VAL_33]], %[[VAL_34]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_39]], %[[VAL_40]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_41]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>) {
// CONCRETE-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_44]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_44]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:              pod.write %[[VAL_45]][@in] = %[[VAL_15]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CONCRETE-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_50]], %[[VAL_51]], %[[VAL_49]] : index
// CONCRETE-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_52]], %[[VAL_53]] : index
// CONCRETE-NEXT:              scf.if %[[VAL_54]] {
// CONCRETE-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_55]], %[[VAL_56]] : index
// CONCRETE-NEXT:                pod.write %[[VAL_46]][@count] = %[[VAL_57]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_57]], %[[VAL_58]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_59]] {
// CONCRETE-NEXT:                  %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                  %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_62:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_61]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_46]][@comp] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              array.write %[[VAL_38]]{{\[}}%[[VAL_44]]] = %[[VAL_45]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:              array.write %[[VAL_37]]{{\[}}%[[VAL_44]]] = %[[VAL_46]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              scf.yield %[[VAL_37]], %[[VAL_38]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_39]], %[[VAL_63]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_64]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>) {
// CONCRETE-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_67]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_67]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                pod.write %[[VAL_68]][@in] = %[[VAL_16]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_71]], %[[VAL_72]] : index
// CONCRETE-NEXT:                %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_73]], %[[VAL_74]], %[[VAL_72]] : index
// CONCRETE-NEXT:                %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_75]], %[[VAL_76]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_77]] {
// CONCRETE-NEXT:                  %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:                  %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_78]], %[[VAL_79]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_69]][@count] = %[[VAL_80]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_80]], %[[VAL_81]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_82]] {
// CONCRETE-NEXT:                    %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_85:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_84]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_69]][@comp] = %[[VAL_85]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                array.write %[[VAL_38]]{{\[}}%[[VAL_67]]] = %[[VAL_68]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                array.write %[[VAL_37]]{{\[}}%[[VAL_67]]] = %[[VAL_69]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_37]], %[[VAL_38]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_87]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_87]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                pod.write %[[VAL_88]][@in] = %[[VAL_17]] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_91]], %[[VAL_92]] : index
// CONCRETE-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_93]], %[[VAL_94]], %[[VAL_92]] : index
// CONCRETE-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_95]], %[[VAL_96]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_97]] {
// CONCRETE-NEXT:                  %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:                  %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_98]], %[[VAL_99]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_89]][@count] = %[[VAL_100]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_100]], %[[VAL_101]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_102]] {
// CONCRETE-NEXT:                    %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_105:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_104]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_89]][@comp] = %[[VAL_105]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                array.write %[[VAL_38]]{{\[}}%[[VAL_87]]] = %[[VAL_88]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                array.write %[[VAL_37]]{{\[}}%[[VAL_87]]] = %[[VAL_89]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_37]], %[[VAL_38]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_65]]#0, %[[VAL_65]]#1 : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_42]]#0{{\[}}%[[VAL_106]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_108]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_109]]{{\[}}%[[VAL_111]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_113]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_113]]] = %[[VAL_112]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_42]]#0, %[[VAL_42]]#1, %[[VAL_116]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_18]][@aux$inputs] = %[[VAL_31]]#1 : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_119]] to %[[VAL_118]] step %[[VAL_120]] {
// CONCRETE-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]#0{{\[}}%[[VAL_121]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            array.write %[[VAL_117]]{{\[}}%[[VAL_121]]] = %[[VAL_123]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_18]][@aux] = %[[VAL_117]] : <@B_1::@B_1<[]>>, !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          struct.writem %[[VAL_18]][@out] = %[[VAL_19]] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_18]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_124:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>, %[[VAL_125:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in1"}, %[[VAL_126:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in2"}, %[[VAL_127:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_124]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_124]][@aux] : <@B_1::@B_1<[]>>, !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_124]][@aux$inputs] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_132]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_134]], %[[VAL_135]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_136]]) %[[VAL_134]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_137:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_137]], %[[VAL_138]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.if %[[VAL_139]] {
// CONCRETE-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_140]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_130]]{{\[}}%[[VAL_141]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:              %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              scf.for %[[VAL_147:[0-9a-zA-Z_\.]+]] = %[[VAL_145]] to %[[VAL_144]] step %[[VAL_146]] {
// CONCRETE-NEXT:                %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_143]]{{\[}}%[[VAL_147]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_125]]{{\[}}%[[VAL_147]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                constrain.eq %[[VAL_150]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                constrain.eq %[[VAL_152]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_137]], %[[VAL_154]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.if %[[VAL_155]] {
// CONCRETE-NEXT:                %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_157:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_130]]{{\[}}%[[VAL_157]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                %[[VAL_160:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                scf.for %[[VAL_163:[0-9a-zA-Z_\.]+]] = %[[VAL_161]] to %[[VAL_160]] step %[[VAL_162]] {
// CONCRETE-NEXT:                  %[[VAL_164:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_163]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_126]]{{\[}}%[[VAL_163]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_166]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_168]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:                %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CONCRETE-NEXT:                %[[VAL_172:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_130]]{{\[}}%[[VAL_171]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_172]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:                %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                scf.for %[[VAL_177:[0-9a-zA-Z_\.]+]] = %[[VAL_175]] to %[[VAL_174]] step %[[VAL_176]] {
// CONCRETE-NEXT:                  %[[VAL_178:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_173]]{{\[}}%[[VAL_177]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_177]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_180]], %[[VAL_181]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_182]], %[[VAL_183]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_137]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_185:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_184]]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_185]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_187]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_186]]{{\[}}%[[VAL_188]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_137]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_190]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_191]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_192]], %[[VAL_193]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_191]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_194]], %[[VAL_195]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_137]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_197]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_201:[0-9a-zA-Z_\.]+]] = %[[VAL_199]] to %[[VAL_198]] step %[[VAL_200]] {
// CONCRETE-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_201]]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_130]]{{\[}}%[[VAL_201]]] : <3 x !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_203]][@in] : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:            function.call @A_0::@A_0::@constrain(%[[VAL_202]], %[[VAL_204]]) : (!struct.type<@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_205:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_206:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_207:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_208:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_209:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_210:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B_1::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_216:[0-9a-zA-Z_\.]+]] = %[[VAL_214]] to %[[VAL_213]] step %[[VAL_215]] {
// CONCRETE-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_205]]{{\[}}%[[VAL_216]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_206]]{{\[}}%[[VAL_216]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_217]], @b = %[[VAL_218]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_212]]{{\[}}%[[VAL_216]]] = %[[VAL_219]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_224:[0-9a-zA-Z_\.]+]] = %[[VAL_222]] to %[[VAL_221]] step %[[VAL_223]] {
// CONCRETE-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_207]]{{\[}}%[[VAL_224]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_208]]{{\[}}%[[VAL_224]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_225]], @b = %[[VAL_226]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_220]]{{\[}}%[[VAL_224]]] = %[[VAL_227]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_232:[0-9a-zA-Z_\.]+]] = %[[VAL_230]] to %[[VAL_229]] step %[[VAL_231]] {
// CONCRETE-NEXT:            %[[VAL_233:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_209]]{{\[}}%[[VAL_232]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_234:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_210]]{{\[}}%[[VAL_232]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_233]], @b = %[[VAL_234]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_228]]{{\[}}%[[VAL_232]]] = %[[VAL_235]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = function.call @B_1::@B_1::@compute(%[[VAL_212]], %[[VAL_220]], %[[VAL_228]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_211]][@"$component"] = %[[VAL_236]] : <@B_1::@"$bus_entry"<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_236]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_243:[0-9a-zA-Z_\.]+]] = %[[VAL_241]] to %[[VAL_240]] step %[[VAL_242]] {
// CONCRETE-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_239]]{{\[}}%[[VAL_243]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_244]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_237]]{{\[}}%[[VAL_243]]] = %[[VAL_245]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_244]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_238]]{{\[}}%[[VAL_243]]] = %[[VAL_246]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_211]][@out.a] = %[[VAL_237]] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_211]][@out.b] = %[[VAL_238]] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_211]] : !struct.type<@B_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_247:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@"$bus_entry"<[]>>, %[[VAL_248:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_249:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_250:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_251:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_252:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_253:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_258:[0-9a-zA-Z_\.]+]] = %[[VAL_256]] to %[[VAL_255]] step %[[VAL_257]] {
// CONCRETE-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_248]]{{\[}}%[[VAL_258]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_260:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_258]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_259]], @b = %[[VAL_260]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_254]]{{\[}}%[[VAL_258]]] = %[[VAL_261]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_266:[0-9a-zA-Z_\.]+]] = %[[VAL_264]] to %[[VAL_263]] step %[[VAL_265]] {
// CONCRETE-NEXT:            %[[VAL_267:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_250]]{{\[}}%[[VAL_266]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_268:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_251]]{{\[}}%[[VAL_266]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_269:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_267]], @b = %[[VAL_268]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_262]]{{\[}}%[[VAL_266]]] = %[[VAL_269]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_274:[0-9a-zA-Z_\.]+]] = %[[VAL_272]] to %[[VAL_271]] step %[[VAL_273]] {
// CONCRETE-NEXT:            %[[VAL_275:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_252]]{{\[}}%[[VAL_274]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_276:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_253]]{{\[}}%[[VAL_274]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_275]], @b = %[[VAL_276]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_270]]{{\[}}%[[VAL_274]]] = %[[VAL_277]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_247]][@"$component"] : <@B_1::@"$bus_entry"<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          function.call @B_1::@B_1::@constrain(%[[VAL_278]], %[[VAL_254]], %[[VAL_262]], %[[VAL_270]]) : (!struct.type<@B_1::@B_1<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_247]][@out.a] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_247]][@out.b] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_278]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_283:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_284:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_285:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_286:[0-9a-zA-Z_\.]+]] = %[[VAL_284]] to %[[VAL_283]] step %[[VAL_285]] {
// CONCRETE-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_279]]{{\[}}%[[VAL_286]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_280]]{{\[}}%[[VAL_286]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_287]], @b = %[[VAL_288]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_282]]{{\[}}%[[VAL_286]]] = %[[VAL_289]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_290:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_291:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_292:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_293:[0-9a-zA-Z_\.]+]] = %[[VAL_291]] to %[[VAL_290]] step %[[VAL_292]] {
// CONCRETE-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_281]]{{\[}}%[[VAL_293]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_282]]{{\[}}%[[VAL_293]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_294]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_295]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_296]], %[[VAL_297]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_294]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_295]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_298]], %[[VAL_299]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@"$bus_entry"<[2, 2, 2]>>} {
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
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_91]], %[[VAL_111]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_112]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>) {
// TEMPLATED-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_114]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_114]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_67]] : (!array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_115]][@in] = %[[VAL_118]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_119]], %[[VAL_120]] : index
// TEMPLATED-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_121]], %[[VAL_122]], %[[VAL_120]] : index
// TEMPLATED-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_123]], %[[VAL_124]] : index
// TEMPLATED-NEXT:              scf.if %[[VAL_125]] {
// TEMPLATED-NEXT:                %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:                %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.muli %[[VAL_127]], %[[VAL_128]] : index
// TEMPLATED-NEXT:                %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_126]], %[[VAL_129]] : index
// TEMPLATED-NEXT:                pod.write %[[VAL_116]][@count] = %[[VAL_130]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_130]], %[[VAL_131]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_132]] {
// TEMPLATED-NEXT:                  %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                  %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_135]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_137:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_134]]) {(%[[VAL_136]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  pod.write %[[VAL_116]][@comp] = %[[VAL_137]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              array.write %[[VAL_90]]{{\[}}%[[VAL_114]]] = %[[VAL_115]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              array.write %[[VAL_89]]{{\[}}%[[VAL_114]]] = %[[VAL_116]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              scf.yield %[[VAL_89]], %[[VAL_90]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_91]], %[[VAL_138]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_139]] -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>) {
// TEMPLATED-NEXT:                %[[VAL_141:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_141]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_141]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_145:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_68]] : (!array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                pod.write %[[VAL_142]][@in] = %[[VAL_145]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_147]] : index
// TEMPLATED-NEXT:                %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_148]], %[[VAL_149]], %[[VAL_147]] : index
// TEMPLATED-NEXT:                %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_150]], %[[VAL_151]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_152]] {
// TEMPLATED-NEXT:                  %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:                  %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_156:[0-9a-zA-Z_\.]+]] = arith.muli %[[VAL_154]], %[[VAL_155]] : index
// TEMPLATED-NEXT:                  %[[VAL_157:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_153]], %[[VAL_156]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_143]][@count] = %[[VAL_157]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_158:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_159:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_157]], %[[VAL_158]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_159]] {
// TEMPLATED-NEXT:                    %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                    %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_160]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_163:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_162]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_164:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_161]]) {(%[[VAL_163]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_143]][@comp] = %[[VAL_164]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_90]]{{\[}}%[[VAL_141]]] = %[[VAL_142]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                array.write %[[VAL_89]]{{\[}}%[[VAL_141]]] = %[[VAL_143]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                scf.yield %[[VAL_89]], %[[VAL_90]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:              } else {
// TEMPLATED-NEXT:                %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_165]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_165]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_169:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_69]] : (!array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                pod.write %[[VAL_166]][@in] = %[[VAL_169]] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_167]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_171]] : index
// TEMPLATED-NEXT:                %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_172]], %[[VAL_173]], %[[VAL_171]] : index
// TEMPLATED-NEXT:                %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_174]], %[[VAL_175]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_176]] {
// TEMPLATED-NEXT:                  %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_167]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:                  %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.muli %[[VAL_178]], %[[VAL_179]] : index
// TEMPLATED-NEXT:                  %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_177]], %[[VAL_180]] : index
// TEMPLATED-NEXT:                  pod.write %[[VAL_167]][@count] = %[[VAL_181]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                  %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                  %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_181]], %[[VAL_182]] : index
// TEMPLATED-NEXT:                  scf.if %[[VAL_183]] {
// TEMPLATED-NEXT:                    %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_167]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                    %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                    %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_187:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_186]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                    %[[VAL_188:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_185]]) {(%[[VAL_187]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                    pod.write %[[VAL_167]][@comp] = %[[VAL_188]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  }
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:                array.write %[[VAL_90]]{{\[}}%[[VAL_165]]] = %[[VAL_166]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                array.write %[[VAL_89]]{{\[}}%[[VAL_165]]] = %[[VAL_167]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:                scf.yield %[[VAL_89]], %[[VAL_90]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              scf.yield %[[VAL_140]]#0, %[[VAL_140]]#1 : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_113]]#0{{\[}}%[[VAL_189]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_191]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_193]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_192]]{{\[}}%[[VAL_194]]] : <? x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_196]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_77]]{{\[}}%[[VAL_196]]] = %[[VAL_195]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_91]], %[[VAL_198]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_113]]#0, %[[VAL_113]]#1, %[[VAL_199]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_70]][@aux$inputs] = %[[VAL_83]]#1 : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_204:[0-9a-zA-Z_\.]+]] = %[[VAL_202]] to %[[VAL_201]] step %[[VAL_203]] {
// TEMPLATED-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]#0{{\[}}%[[VAL_204]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_200]]{{\[}}%[[VAL_204]]] = %[[VAL_206]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_70]][@aux] = %[[VAL_200]] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_70]][@out] = %[[VAL_77]] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          function.return %[[VAL_70]] : !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_207:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n1, @n2, @n3]>>, %[[VAL_208:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in1"}, %[[VAL_209:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in2"}, %[[VAL_210:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_211]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_213]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_215]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_207]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_207]][@aux] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_207]][@aux$inputs] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_212]], %[[VAL_214]], %[[VAL_216]] : <3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_224:[0-9a-zA-Z_\.]+]] = %[[VAL_222]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_224]], %[[VAL_225]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_226]]) %[[VAL_224]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_227:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_229:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_221]]{{\[}}%[[VAL_228]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_230:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_232:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_227]], %[[VAL_231]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.if %[[VAL_232]] {
// TEMPLATED-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_219]]{{\[}}%[[VAL_233]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_208]] : (!array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_235]], %[[VAL_237]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:              scf.for %[[VAL_241:[0-9a-zA-Z_\.]+]] = %[[VAL_239]] to %[[VAL_238]] step %[[VAL_240]] {
// TEMPLATED-NEXT:                %[[VAL_242:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_235]]{{\[}}%[[VAL_241]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                %[[VAL_243:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_236]]{{\[}}%[[VAL_241]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                %[[VAL_244:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_242]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_243]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                constrain.eq %[[VAL_244]], %[[VAL_245]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_242]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_243]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                constrain.eq %[[VAL_246]], %[[VAL_247]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_249:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_227]], %[[VAL_248]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.if %[[VAL_249]] {
// TEMPLATED-NEXT:                %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_251:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_219]]{{\[}}%[[VAL_250]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                %[[VAL_252:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_251]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_253:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_209]] : (!array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_254:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_255:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_252]], %[[VAL_254]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_256:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_257:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                scf.for %[[VAL_258:[0-9a-zA-Z_\.]+]] = %[[VAL_256]] to %[[VAL_255]] step %[[VAL_257]] {
// TEMPLATED-NEXT:                  %[[VAL_259:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_252]]{{\[}}%[[VAL_258]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_260:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_253]]{{\[}}%[[VAL_258]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_261:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_259]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_260]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_261]], %[[VAL_262]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_263:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_259]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_264:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_260]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_263]], %[[VAL_264]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              } else {
// TEMPLATED-NEXT:                %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_266:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_219]]{{\[}}%[[VAL_265]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                %[[VAL_267:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_268:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_210]] : (!array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_269:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_270:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_267]], %[[VAL_269]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:                %[[VAL_271:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_272:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                scf.for %[[VAL_273:[0-9a-zA-Z_\.]+]] = %[[VAL_271]] to %[[VAL_270]] step %[[VAL_272]] {
// TEMPLATED-NEXT:                  %[[VAL_274:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_273]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_275:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_268]]{{\[}}%[[VAL_273]]] : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_276]], %[[VAL_277]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_279:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  constrain.eq %[[VAL_278]], %[[VAL_279]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_218]]{{\[}}%[[VAL_280]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_281]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:            %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_283]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_282]]{{\[}}%[[VAL_284]]] : <? x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_217]]{{\[}}%[[VAL_286]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_287]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_288]], %[[VAL_289]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_287]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_290]], %[[VAL_291]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_227]], %[[VAL_292]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_293]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_294:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_295:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_296:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_297:[0-9a-zA-Z_\.]+]] = %[[VAL_295]] to %[[VAL_294]] step %[[VAL_296]] {
// TEMPLATED-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_218]]{{\[}}%[[VAL_297]]] : <3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_219]]{{\[}}%[[VAL_297]]] : <3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_299]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:            function.call @A::@A::@constrain(%[[VAL_298]], %[[VAL_300]]) : (!struct.type<@A::@A<[#[[$ATTR_0]]]>>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_301:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_302:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_303:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_304:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_305:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_306:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) -> !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          %[[VAL_308:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_309:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_308]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_310:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_311:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_310]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_312:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_313:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_312]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_314:[0-9a-zA-Z_\.]+]] = array.new  : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_315:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_316:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_317:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_318:[0-9a-zA-Z_\.]+]] = %[[VAL_316]] to %[[VAL_315]] step %[[VAL_317]] {
// TEMPLATED-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_301]]{{\[}}%[[VAL_318]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_320:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_302]]{{\[}}%[[VAL_318]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_321:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_319]], @b = %[[VAL_320]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_314]]{{\[}}%[[VAL_318]]] = %[[VAL_321]] : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = array.new  : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_326:[0-9a-zA-Z_\.]+]] = %[[VAL_324]] to %[[VAL_323]] step %[[VAL_325]] {
// TEMPLATED-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_303]]{{\[}}%[[VAL_326]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_304]]{{\[}}%[[VAL_326]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_327]], @b = %[[VAL_328]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_322]]{{\[}}%[[VAL_326]]] = %[[VAL_329]] : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = array.new  : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_333:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_334:[0-9a-zA-Z_\.]+]] = %[[VAL_332]] to %[[VAL_331]] step %[[VAL_333]] {
// TEMPLATED-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_305]]{{\[}}%[[VAL_334]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_336:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_306]]{{\[}}%[[VAL_334]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_337:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_335]], @b = %[[VAL_336]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_330]]{{\[}}%[[VAL_334]]] = %[[VAL_337]] : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_338:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_314]], %[[VAL_322]], %[[VAL_330]]) : (!array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_307]][@"$component"] = %[[VAL_338]] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_340:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_341:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_338]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_342:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_343:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_344:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_345:[0-9a-zA-Z_\.]+]] = %[[VAL_343]] to %[[VAL_342]] step %[[VAL_344]] {
// TEMPLATED-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_341]]{{\[}}%[[VAL_345]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_347:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_346]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_339]]{{\[}}%[[VAL_345]]] = %[[VAL_347]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_348:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_346]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_340]]{{\[}}%[[VAL_345]]] = %[[VAL_348]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_307]][@out.a] = %[[VAL_339]] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_307]][@out.b] = %[[VAL_340]] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_307]] : !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_349:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@"$bus_entry"<[@n1, @n2, @n3]>>, %[[VAL_350:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.a"}, %[[VAL_351:[0-9a-zA-Z_\.]+]]: !array.type<@n1 x !felt.type<"bn128">> {function.arg_name = "in1.b"}, %[[VAL_352:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.a"}, %[[VAL_353:[0-9a-zA-Z_\.]+]]: !array.type<@n2 x !felt.type<"bn128">> {function.arg_name = "in2.b"}, %[[VAL_354:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.a"}, %[[VAL_355:[0-9a-zA-Z_\.]+]]: !array.type<@n3 x !felt.type<"bn128">> {function.arg_name = "in3.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_356]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_358:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_359:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_358]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_360:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_360]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_362:[0-9a-zA-Z_\.]+]] = array.new  : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_363:[0-9a-zA-Z_\.]+]] = poly.read_const @n1 : index
// TEMPLATED-NEXT:          %[[VAL_364:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_365:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_366:[0-9a-zA-Z_\.]+]] = %[[VAL_364]] to %[[VAL_363]] step %[[VAL_365]] {
// TEMPLATED-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_350]]{{\[}}%[[VAL_366]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_368:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_351]]{{\[}}%[[VAL_366]]] : <@n1 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_369:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_367]], @b = %[[VAL_368]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_362]]{{\[}}%[[VAL_366]]] = %[[VAL_369]] : <@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_370:[0-9a-zA-Z_\.]+]] = array.new  : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_371:[0-9a-zA-Z_\.]+]] = poly.read_const @n2 : index
// TEMPLATED-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_373:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_374:[0-9a-zA-Z_\.]+]] = %[[VAL_372]] to %[[VAL_371]] step %[[VAL_373]] {
// TEMPLATED-NEXT:            %[[VAL_375:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_352]]{{\[}}%[[VAL_374]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_376:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_353]]{{\[}}%[[VAL_374]]] : <@n2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_377:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_375]], @b = %[[VAL_376]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_370]]{{\[}}%[[VAL_374]]] = %[[VAL_377]] : <@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_378:[0-9a-zA-Z_\.]+]] = array.new  : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_379:[0-9a-zA-Z_\.]+]] = poly.read_const @n3 : index
// TEMPLATED-NEXT:          %[[VAL_380:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_381:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_382:[0-9a-zA-Z_\.]+]] = %[[VAL_380]] to %[[VAL_379]] step %[[VAL_381]] {
// TEMPLATED-NEXT:            %[[VAL_383:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_354]]{{\[}}%[[VAL_382]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_384:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_355]]{{\[}}%[[VAL_382]]] : <@n3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_385:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_383]], @b = %[[VAL_384]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_378]]{{\[}}%[[VAL_382]]] = %[[VAL_385]] : <@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_386:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_349]][@"$component"] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !struct.type<@B::@B<[@n1, @n2, @n3]>>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_386]], %[[VAL_362]], %[[VAL_370]], %[[VAL_378]]) : (!struct.type<@B::@B<[@n1, @n2, @n3]>>, !array.type<@n1 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<@n2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !array.type<@n3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// TEMPLATED-NEXT:          %[[VAL_387:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_349]][@out.a] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_388:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_349]][@out.b] : <@B::@"$bus_entry"<[@n1, @n2, @n3]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_389:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_386]][@out] : <@B::@B<[@n1, @n2, @n3]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_390:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_391:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_392:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_393:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_394:[0-9a-zA-Z_\.]+]] = %[[VAL_392]] to %[[VAL_391]] step %[[VAL_393]] {
// TEMPLATED-NEXT:            %[[VAL_395:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_387]]{{\[}}%[[VAL_394]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_396:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_388]]{{\[}}%[[VAL_394]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_397:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_395]], @b = %[[VAL_396]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_390]]{{\[}}%[[VAL_394]]] = %[[VAL_397]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_398:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_399:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_400:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_401:[0-9a-zA-Z_\.]+]] = %[[VAL_399]] to %[[VAL_398]] step %[[VAL_400]] {
// TEMPLATED-NEXT:            %[[VAL_402:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_389]]{{\[}}%[[VAL_401]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_403:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_390]]{{\[}}%[[VAL_401]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_404:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_402]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_405:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_403]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_404]], %[[VAL_405]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_406:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_402]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_407:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_403]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_406]], %[[VAL_407]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
