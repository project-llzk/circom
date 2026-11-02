// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Simple case, same buses for all the elements in the heterogeneus array of components
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(){
    signal a;
    signal b;
}

template A(n){
    Simple input in;
    Simple output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.b;
        out.b <== in.a;
    }
}

template B(n){
    Simple input in[3];
    Simple output out[3];

    for (var i = 0; i < 3; i++){
        out[i] <== A(n[i])(in[i]);
    }
}

component main = B([2, 2, 2]);

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_1::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    module @global {
// CONCRETE-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  2 : <"bn128">,  2 : <"bn128">]
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @A_[[MEMBER0:[0-9]+_[0-9]+]] : !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:        struct.member @A_[[MEMBER0]]$inputs : !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_15]] to %[[VAL_14]] step %[[VAL_16]] {
// CONCRETE-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]], @params = %[[VAL_13]] }  : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_17]]] = %[[VAL_19]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_22]], %[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_23]]) : (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_28]], %[[VAL_29]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_30]]) %[[VAL_25]], %[[VAL_26]], %[[VAL_27]], %[[VAL_28]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_35]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_37]]] : <3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_37]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            pod.write %[[VAL_38]][@in] = %[[VAL_36]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_41]], %[[VAL_42]] : index
// CONCRETE-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_43]], %[[VAL_44]], %[[VAL_42]] : index
// CONCRETE-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_45]], %[[VAL_46]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_47]] {
// CONCRETE-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_48]], %[[VAL_49]] : index
// CONCRETE-NEXT:              pod.write %[[VAL_39]][@count] = %[[VAL_50]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_50]], %[[VAL_51]] : index
// CONCRETE-NEXT:              scf.if %[[VAL_52]] {
// CONCRETE-NEXT:                %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@params] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_54]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:                pod.write %[[VAL_39]][@comp] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            array.write %[[VAL_32]]{{\[}}%[[VAL_37]]] = %[[VAL_38]] : <3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            array.write %[[VAL_31]]{{\[}}%[[VAL_37]]] = %[[VAL_39]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_56]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_60]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_60]]] = %[[VAL_59]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_33]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_31]], %[[VAL_32]], %[[VAL_65]], %[[VAL_63]] : !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_10]][@A_[[MEMBER0]]$inputs] = %[[VAL_24]]#1 : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_68]] to %[[VAL_67]] step %[[VAL_69]] {
// CONCRETE-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]#0{{\[}}%[[VAL_70]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@comp] : <[@count: index, @comp: !struct.type<@A_0::@A_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            array.write %[[VAL_66]]{{\[}}%[[VAL_70]]] = %[[VAL_72]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_10]][@A_[[MEMBER0]]] = %[[VAL_66]] : <@B_1::@B_1<[]>>, !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          struct.writem %[[VAL_10]][@out] = %[[VAL_11]] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_10]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@A_[[MEMBER0]]] : <@B_1::@B_1<[]>>, !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@A_[[MEMBER0]]$inputs] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_79]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_80]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_83]], %[[VAL_84]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_85]]) %[[VAL_82]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_88]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_90]]] : <3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_93]], %[[VAL_94]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_95]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_97]]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_98]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_100]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_102]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_104]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_109]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_113:[0-9a-zA-Z_\.]+]] = %[[VAL_111]] to %[[VAL_110]] step %[[VAL_112]] {
// CONCRETE-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_113]]] : <3 x !struct.type<@A_0::@A_0<[]>>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_113]]] : <3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            function.call @A_0::@A_0::@constrain(%[[VAL_114]], %[[VAL_116]]) : (!struct.type<@A_0::@A_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_117:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_118:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b"}) -> !struct.type<@B_1::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_124:[0-9a-zA-Z_\.]+]] = %[[VAL_122]] to %[[VAL_121]] step %[[VAL_123]] {
// CONCRETE-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_124]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_118]]{{\[}}%[[VAL_124]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_125]], @b = %[[VAL_126]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_120]]{{\[}}%[[VAL_124]]] = %[[VAL_127]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = function.call @B_1::@B_1::@compute(%[[VAL_120]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_119]][@"$component"] = %[[VAL_128]] : <@B_1::@"$bus_entry"<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_128]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_135:[0-9a-zA-Z_\.]+]] = %[[VAL_133]] to %[[VAL_132]] step %[[VAL_134]] {
// CONCRETE-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_131]]{{\[}}%[[VAL_135]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_129]]{{\[}}%[[VAL_135]]] = %[[VAL_137]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_130]]{{\[}}%[[VAL_135]]] = %[[VAL_138]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_119]][@out.a] = %[[VAL_129]] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_119]][@out.b] = %[[VAL_130]] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_119]] : !struct.type<@B_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_139:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@"$bus_entry"<[]>>, %[[VAL_140:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_141:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_146:[0-9a-zA-Z_\.]+]] = %[[VAL_144]] to %[[VAL_143]] step %[[VAL_145]] {
// CONCRETE-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_146]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_146]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_147]], @b = %[[VAL_148]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_142]]{{\[}}%[[VAL_146]]] = %[[VAL_149]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_139]][@"$component"] : <@B_1::@"$bus_entry"<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          function.call @B_1::@B_1::@constrain(%[[VAL_150]], %[[VAL_142]]) : (!struct.type<@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_139]][@out.a] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_139]][@out.b] : <@B_1::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_150]][@out] : <@B_1::@B_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_158:[0-9a-zA-Z_\.]+]] = %[[VAL_156]] to %[[VAL_155]] step %[[VAL_157]] {
// CONCRETE-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_158]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_158]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_159]], @b = %[[VAL_160]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_154]]{{\[}}%[[VAL_158]]] = %[[VAL_161]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_165:[0-9a-zA-Z_\.]+]] = %[[VAL_163]] to %[[VAL_162]] step %[[VAL_164]] {
// CONCRETE-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_153]]{{\[}}%[[VAL_165]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_154]]{{\[}}%[[VAL_165]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_167]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_168]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_167]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_170]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    module @global {
// TEMPLATED-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// TEMPLATED-NEXT:      global.def const @array_const_1 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  2 : <"bn128">,  2 : <"bn128">]
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      poly.param @n
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_2]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_5]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_7]] -> (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) {
// TEMPLATED-NEXT:            struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_0]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_3]][@a] = %[[VAL_9]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_3]][@b] = %[[VAL_11]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_3]] : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@A::@A<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@n]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@out] : <@A::@A<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_15]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_18]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_20]] {
// TEMPLATED-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_21]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_23]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_26]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_28]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      poly.expr @"anon_var_[[MEMBER0:[0-9]+_[0-9]+]]@[[OFFSET0:[0-9]+]]" {
// TEMPLATED-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_30]] : index
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @A_[[MEMBER1:[0-9]+_[0-9]+]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:        struct.member @A_[[MEMBER1]]$inputs : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_33]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_42:[0-9a-zA-Z_\.]+]] = %[[VAL_36]], %[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_37]], %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_39]], %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_40]]) : (!array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_45]], %[[VAL_46]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_47]]) %[[VAL_42]], %[[VAL_43]], %[[VAL_44]], %[[VAL_45]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_49:[0-9a-zA-Z_\.]+]]: !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_51:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_52]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_53]] }  : <[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_56]], @params = %[[VAL_55]] } (%[[VAL_54]]) : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_48]]{{\[}}%[[VAL_58]]] = %[[VAL_57]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_59]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_49]]{{\[}}%[[VAL_61]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_61]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            pod.write %[[VAL_62]][@in] = %[[VAL_60]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_65]], %[[VAL_66]] : index
// TEMPLATED-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_67]], %[[VAL_68]], %[[VAL_66]] : index
// TEMPLATED-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_69]], %[[VAL_70]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_71]] {
// TEMPLATED-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_72]], %[[VAL_73]] : index
// TEMPLATED-NEXT:              pod.write %[[VAL_63]][@count] = %[[VAL_74]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_74]], %[[VAL_75]] : index
// TEMPLATED-NEXT:              scf.if %[[VAL_76]] {
// TEMPLATED-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_78]]) {(%[[VAL_80]])} : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                pod.write %[[VAL_63]][@comp] = %[[VAL_81]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            array.write %[[VAL_49]]{{\[}}%[[VAL_61]]] = %[[VAL_62]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_48]]{{\[}}%[[VAL_61]]] = %[[VAL_63]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_82]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_86]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_35]]{{\[}}%[[VAL_86]]] = %[[VAL_85]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_50]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_48]], %[[VAL_49]], %[[VAL_91]], %[[VAL_89]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_32]][@A_[[MEMBER1]]$inputs] = %[[VAL_41]]#1 : <@B::@B<[]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.new  : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_96:[0-9a-zA-Z_\.]+]] = %[[VAL_94]] to %[[VAL_93]] step %[[VAL_95]] {
// TEMPLATED-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]#0{{\[}}%[[VAL_96]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_92]]{{\[}}%[[VAL_96]]] = %[[VAL_98]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_32]][@A_[[MEMBER1]]] = %[[VAL_92]] : <@B::@B<[]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_32]][@out] = %[[VAL_35]] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          function.return %[[VAL_32]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_99:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_100:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_101]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_99]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_99]][@A_[[MEMBER1]]] : <@B::@B<[]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_99]][@A_[[MEMBER1]]$inputs] : <@B::@B<[]>>, !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_110:[0-9a-zA-Z_\.]+]] = %[[VAL_107]], %[[VAL_111:[0-9a-zA-Z_\.]+]] = %[[VAL_108]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_111]], %[[VAL_112]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_113]]) %[[VAL_110]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_114:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_115:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_116]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_100]]{{\[}}%[[VAL_119]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_121]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_124]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_126]], %[[VAL_127]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_128]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_129]][@out] : <@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_131]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_133]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_135]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_115]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_114]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_140]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_144:[0-9a-zA-Z_\.]+]] = %[[VAL_142]] to %[[VAL_141]] step %[[VAL_143]] {
// TEMPLATED-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_144]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_144]]] : <@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            function.call @A::@A::@constrain(%[[VAL_145]], %[[VAL_147]]) : (!struct.type<@A::@A<[#[[$ATTR_0]]]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_148:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_149:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b"}) -> !struct.type<@B::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_151]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_157:[0-9a-zA-Z_\.]+]] = %[[VAL_155]] to %[[VAL_154]] step %[[VAL_156]] {
// TEMPLATED-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_148]]{{\[}}%[[VAL_157]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_149]]{{\[}}%[[VAL_157]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_158]], @b = %[[VAL_159]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_153]]{{\[}}%[[VAL_157]]] = %[[VAL_160]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_153]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_150]][@"$component"] = %[[VAL_161]] : <@B::@"$bus_entry"<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_161]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_168:[0-9a-zA-Z_\.]+]] = %[[VAL_166]] to %[[VAL_165]] step %[[VAL_167]] {
// TEMPLATED-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_164]]{{\[}}%[[VAL_168]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_162]]{{\[}}%[[VAL_168]]] = %[[VAL_170]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_163]]{{\[}}%[[VAL_168]]] = %[[VAL_171]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_150]][@out.a] = %[[VAL_162]] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_150]][@out.b] = %[[VAL_163]] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_150]] : !struct.type<@B::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_172:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@"$bus_entry"<[]>>, %[[VAL_173:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_174:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = poly.read_const @"anon_var_[[MEMBER0]]@[[OFFSET0]]" : index
// TEMPLATED-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_175]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_181:[0-9a-zA-Z_\.]+]] = %[[VAL_179]] to %[[VAL_178]] step %[[VAL_180]] {
// TEMPLATED-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_173]]{{\[}}%[[VAL_181]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_183:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_174]]{{\[}}%[[VAL_181]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_182]], @b = %[[VAL_183]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_177]]{{\[}}%[[VAL_181]]] = %[[VAL_184]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_172]][@"$component"] : <@B::@"$bus_entry"<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_185]], %[[VAL_177]]) : (!struct.type<@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// TEMPLATED-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_172]][@out.a] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_172]][@out.b] : <@B::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_185]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_193:[0-9a-zA-Z_\.]+]] = %[[VAL_191]] to %[[VAL_190]] step %[[VAL_192]] {
// TEMPLATED-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_186]]{{\[}}%[[VAL_193]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_187]]{{\[}}%[[VAL_193]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_194]], @b = %[[VAL_195]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_189]]{{\[}}%[[VAL_193]]] = %[[VAL_196]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_200:[0-9a-zA-Z_\.]+]] = %[[VAL_198]] to %[[VAL_197]] step %[[VAL_199]] {
// TEMPLATED-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_188]]{{\[}}%[[VAL_200]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_189]]{{\[}}%[[VAL_200]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_201]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_203]], %[[VAL_204]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_201]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_205]], %[[VAL_206]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
