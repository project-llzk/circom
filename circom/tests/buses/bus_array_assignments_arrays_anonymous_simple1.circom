// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus miBus(n){
    signal a;
    signal b;
}

template B(){
    miBus(3) input in;
    miBus(3) output out[3] <== [in, in, in];
}

template A(){
    miBus(3) input in[3];

    miBus(3) output out[3][3] <== [in, B()(in[1]), in];

    in[1].a === out[1][1].a;
}

component main = A();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_1::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @A_1 {
// CONCRETE-NEXT:      struct.def @A_1 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_8]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_6]][@in] = %[[VAL_9]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_11]], %[[VAL_12]] : index
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_13]], %[[VAL_14]], %[[VAL_12]] : index
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_15]], %[[VAL_16]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_17]] {
// CONCRETE-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_18]], %[[VAL_19]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_5]][@count] = %[[VAL_20]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_20]], %[[VAL_21]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_22]] {
// CONCRETE-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = function.call @B_0::@B_0::@compute(%[[VAL_24]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_5]][@comp] = %[[VAL_25]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_2]]{{\[}}%[[VAL_27]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          array.insert %[[VAL_2]]{{\[}}%[[VAL_27]]] = %[[VAL_0]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@B_0::@B_0<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_2]]{{\[}}%[[VAL_32]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          array.insert %[[VAL_2]]{{\[}}%[[VAL_32]]] = %[[VAL_30]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_2]]{{\[}}%[[VAL_35]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          array.insert %[[VAL_2]]{{\[}}%[[VAL_35]]] = %[[VAL_0]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_6]] : <@A_1::@A_1<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_37]] : <@A_1::@A_1<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@A_1::@A_1<[]>>, !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@out] : <@A_1::@A_1<[]>>, !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@B_[[MEMBER0]]] : <@A_1::@A_1<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@B_[[MEMBER0]]$inputs] : <@A_1::@A_1<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_44]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_49]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_40]]{{\[}}%[[VAL_52]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_57:[0-9a-zA-Z_\.]+]] = %[[VAL_55]] to %[[VAL_54]] step %[[VAL_56]] {
// CONCRETE-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_57]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_57]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_60]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_62]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@out] : <@B_0::@B_0<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_40]]{{\[}}%[[VAL_66]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_69]] to %[[VAL_68]] step %[[VAL_70]] {
// CONCRETE-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_71]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_71]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_74]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_76]], %[[VAL_77]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_40]]{{\[}}%[[VAL_79]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_82]] to %[[VAL_81]] step %[[VAL_83]] {
// CONCRETE-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_84]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_84]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_87]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_89]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_92]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_40]]{{\[}}%[[VAL_96]], %[[VAL_98]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_94]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @B_0::@B_0::@constrain(%[[VAL_41]], %[[VAL_101]]) : (!struct.type<@B_0::@B_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<3,3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<3,3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_102:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_103:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b"}) -> !struct.type<@A_1::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_107]] to %[[VAL_106]] step %[[VAL_108]] {
// CONCRETE-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_109]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_109]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_110]], @b = %[[VAL_111]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_105]]{{\[}}%[[VAL_109]]] = %[[VAL_112]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_105]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_104]][@"$component"] = %[[VAL_113]] : <@A_1::@"$bus_entry"<[]>>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@out] : <@A_1::@A_1<[]>>, !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_119]] to %[[VAL_117]] step %[[VAL_120]] {
// CONCRETE-NEXT:            scf.for %[[VAL_122:[0-9a-zA-Z_\.]+]] = %[[VAL_119]] to %[[VAL_118]] step %[[VAL_120]] {
// CONCRETE-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_121]], %[[VAL_122]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              array.write %[[VAL_114]]{{\[}}%[[VAL_121]], %[[VAL_122]]] = %[[VAL_124]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              array.write %[[VAL_115]]{{\[}}%[[VAL_121]], %[[VAL_122]]] = %[[VAL_125]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_104]][@out.a] = %[[VAL_114]] : <@A_1::@"$bus_entry"<[]>>, !array.type<3,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_104]][@out.b] = %[[VAL_115]] : <@A_1::@"$bus_entry"<[]>>, !array.type<3,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_104]] : !struct.type<@A_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_126:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@"$bus_entry"<[]>>, %[[VAL_127:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_128:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_131]] to %[[VAL_130]] step %[[VAL_132]] {
// CONCRETE-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_133]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_133]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_134]], @b = %[[VAL_135]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_129]]{{\[}}%[[VAL_133]]] = %[[VAL_136]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_126]][@"$component"] : <@A_1::@"$bus_entry"<[]>>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_137]], %[[VAL_129]]) : (!struct.type<@A_1::@A_1<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_126]][@out.a] : <@A_1::@"$bus_entry"<[]>>, !array.type<3,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_126]][@out.b] : <@A_1::@"$bus_entry"<[]>>, !array.type<3,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_137]][@out] : <@A_1::@A_1<[]>>, !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_146:[0-9a-zA-Z_\.]+]] = %[[VAL_144]] to %[[VAL_142]] step %[[VAL_145]] {
// CONCRETE-NEXT:            scf.for %[[VAL_147:[0-9a-zA-Z_\.]+]] = %[[VAL_144]] to %[[VAL_143]] step %[[VAL_145]] {
// CONCRETE-NEXT:              %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_146]], %[[VAL_147]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_146]], %[[VAL_147]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_148]], @b = %[[VAL_149]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              array.write %[[VAL_141]]{{\[}}%[[VAL_146]], %[[VAL_147]]] = %[[VAL_150]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_155:[0-9a-zA-Z_\.]+]] = %[[VAL_153]] to %[[VAL_151]] step %[[VAL_154]] {
// CONCRETE-NEXT:            scf.for %[[VAL_156:[0-9a-zA-Z_\.]+]] = %[[VAL_153]] to %[[VAL_152]] step %[[VAL_154]] {
// CONCRETE-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_155]], %[[VAL_156]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_155]], %[[VAL_156]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              constrain.eq %[[VAL_159]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              constrain.eq %[[VAL_161]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_0 {
// CONCRETE-NEXT:      struct.def @B_0 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_163:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@B_0::@B_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = struct.new : <@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_166]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_165]]{{\[}}%[[VAL_167]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          array.write %[[VAL_165]]{{\[}}%[[VAL_167]]] = %[[VAL_163]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_165]]{{\[}}%[[VAL_170]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          array.write %[[VAL_165]]{{\[}}%[[VAL_170]]] = %[[VAL_163]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_165]]{{\[}}%[[VAL_173]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          array.write %[[VAL_165]]{{\[}}%[[VAL_173]]] = %[[VAL_163]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_164]][@out] = %[[VAL_165]] : <@B_0::@B_0<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_164]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_175:[0-9a-zA-Z_\.]+]]: !struct.type<@B_0::@B_0<[]>>, %[[VAL_176:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_175]][@out] : <@B_0::@B_0<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_178]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_179]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_181]], %[[VAL_182]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_183]], %[[VAL_184]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_185]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_186]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_188]], %[[VAL_189]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_190]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_192]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_193]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_195]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_197]], %[[VAL_198]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_7]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@in] = %[[VAL_8]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_10]], %[[VAL_11]] : index
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_12]], %[[VAL_13]], %[[VAL_11]] : index
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_14]], %[[VAL_15]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_16]] {
// TEMPLATED-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// TEMPLATED-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_17]], %[[VAL_18]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_5]][@count] = %[[VAL_19]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// TEMPLATED-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_19]], %[[VAL_20]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_21]] {
// TEMPLATED-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// TEMPLATED-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_23]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_5]][@comp] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_27]]{{\[}}%[[VAL_28]]] = %[[VAL_0]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_27]]{{\[}}%[[VAL_29]]] = %[[VAL_26]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_27]]{{\[}}%[[VAL_30]]] = %[[VAL_0]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_27]] : <@A::@A<[]>>, !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_31]] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@out] : <@A::@A<[]>>, !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_38]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_41]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_46]]{{\[}}%[[VAL_47]]] = %[[VAL_33]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_46]]{{\[}}%[[VAL_48]]] = %[[VAL_45]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_46]]{{\[}}%[[VAL_49]]] = %[[VAL_33]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]] to %[[VAL_50]] step %[[VAL_53]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_52]] to %[[VAL_51]] step %[[VAL_53]] {
// TEMPLATED-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_54]], %[[VAL_55]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_54]], %[[VAL_55]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_58]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_60]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_63]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_67]], %[[VAL_69]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_65]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_35]], %[[VAL_72]]) : (!struct.type<@B::@B<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<3,3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<3,3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_78]] to %[[VAL_77]] step %[[VAL_79]] {
// TEMPLATED-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_80]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_80]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_81]], @b = %[[VAL_82]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_80]]] = %[[VAL_83]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_76]]) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_75]][@"$component"] = %[[VAL_84]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@out] : <@A::@A<[]>>, !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_92:[0-9a-zA-Z_\.]+]] = %[[VAL_90]] to %[[VAL_88]] step %[[VAL_91]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_93:[0-9a-zA-Z_\.]+]] = %[[VAL_90]] to %[[VAL_89]] step %[[VAL_91]] {
// TEMPLATED-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_92]], %[[VAL_93]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              array.write %[[VAL_85]]{{\[}}%[[VAL_92]], %[[VAL_93]]] = %[[VAL_95]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              array.write %[[VAL_86]]{{\[}}%[[VAL_92]], %[[VAL_93]]] = %[[VAL_96]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_75]][@out.a] = %[[VAL_85]] : <@A::@"$bus_entry"<[]>>, !array.type<3,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_75]][@out.b] = %[[VAL_86]] : <@A::@"$bus_entry"<[]>>, !array.type<3,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_75]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_97:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_98:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a"}, %[[VAL_99:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]] to %[[VAL_101]] step %[[VAL_103]] {
// TEMPLATED-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_98]]{{\[}}%[[VAL_104]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_104]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_105]], @b = %[[VAL_106]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_100]]{{\[}}%[[VAL_104]]] = %[[VAL_107]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_97]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_108]], %[[VAL_100]]) : (!struct.type<@A::@A<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> ()
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_97]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<3,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_97]][@out.b] : <@A::@"$bus_entry"<[]>>, !array.type<3,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_108]][@out] : <@A::@A<[]>>, !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_117:[0-9a-zA-Z_\.]+]] = %[[VAL_115]] to %[[VAL_113]] step %[[VAL_116]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_118:[0-9a-zA-Z_\.]+]] = %[[VAL_115]] to %[[VAL_114]] step %[[VAL_116]] {
// TEMPLATED-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_109]]{{\[}}%[[VAL_117]], %[[VAL_118]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_110]]{{\[}}%[[VAL_117]], %[[VAL_118]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_119]], @b = %[[VAL_120]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              array.write %[[VAL_112]]{{\[}}%[[VAL_117]], %[[VAL_118]]] = %[[VAL_121]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_126:[0-9a-zA-Z_\.]+]] = %[[VAL_124]] to %[[VAL_122]] step %[[VAL_125]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_127:[0-9a-zA-Z_\.]+]] = %[[VAL_124]] to %[[VAL_123]] step %[[VAL_125]] {
// TEMPLATED-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_126]], %[[VAL_127]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]{{\[}}%[[VAL_126]], %[[VAL_127]]] : <3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_130]], %[[VAL_131]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_132]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_134:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_134]], %[[VAL_134]], %[[VAL_134]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_135]][@out] = %[[VAL_136]] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          function.return %[[VAL_135]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_137:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_138:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_137]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_138]], %[[VAL_138]], %[[VAL_138]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_144:[0-9a-zA-Z_\.]+]] = %[[VAL_142]] to %[[VAL_141]] step %[[VAL_143]] {
// TEMPLATED-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_144]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_144]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_147]], %[[VAL_148]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_149]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
