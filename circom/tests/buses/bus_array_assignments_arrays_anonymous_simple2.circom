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

bus otroBus(n){
    miBus(n) a[3];
}

template B(){
    miBus(3) input in;
    miBus(3) output out[3] <== [in, in, in];
}

template A(){
    otroBus(3) input in;
    miBus(3) input in1;

    miBus(3) output out[2][3] <== [in.a, B()(in1)];

    out[0][1].a === in.a[1].a;
    out[1][1].a === in1.a;
}

component main = A();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_1::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @A_1 {
// CONCRETE-NEXT:      struct.def @A_1 {
// CONCRETE-NEXT:        struct.member @out : !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]> {function.arg_name = "in"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in1"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_7]][@in] = %[[VAL_1]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_9]], %[[VAL_10]] : index
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_11]], %[[VAL_12]], %[[VAL_10]] : index
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_13]], %[[VAL_14]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_15]] {
// CONCRETE-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_16]], %[[VAL_17]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_20]] {
// CONCRETE-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @B_0::@B_0::@compute(%[[VAL_22]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_3]]{{\[}}%[[VAL_26]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          array.insert %[[VAL_3]]{{\[}}%[[VAL_26]]] = %[[VAL_24]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@out] : <@B_0::@B_0<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_3]]{{\[}}%[[VAL_31]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          array.insert %[[VAL_3]]{{\[}}%[[VAL_31]]] = %[[VAL_29]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_2]][@B_[[MEMBER0]]$inputs] = %[[VAL_7]] : <@A_1::@A_1<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_2]][@B_[[MEMBER0]]] = %[[VAL_33]] : <@A_1::@A_1<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@A_1::@A_1<[]>>, !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_2]] : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]> {function.arg_name = "in"}, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in1"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@out] : <@A_1::@A_1<[]>>, !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@B_[[MEMBER0]]] : <@A_1::@A_1<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@B_[[MEMBER0]]$inputs] : <@A_1::@A_1<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_41]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@a] : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_37]]{{\[}}%[[VAL_47]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_50]] to %[[VAL_49]] step %[[VAL_51]] {
// CONCRETE-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_52]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_52]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_55]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_57]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@out] : <@B_0::@B_0<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_37]]{{\[}}%[[VAL_61]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_66:[0-9a-zA-Z_\.]+]] = %[[VAL_64]] to %[[VAL_63]] step %[[VAL_65]] {
// CONCRETE-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_66]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_66]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_69]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_71]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_74]], %[[VAL_76]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@a] : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_81]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_78]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_85]], %[[VAL_87]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_89]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @B_0::@B_0::@constrain(%[[VAL_38]], %[[VAL_91]]) : (!struct.type<@B_0::@B_0<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<2,3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<2,3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_92:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}, %[[VAL_93:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a.b"}, %[[VAL_94:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.a"}, %[[VAL_95:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.b"}) -> !struct.type<@A_1::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_99]] to %[[VAL_98]] step %[[VAL_100]] {
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_92]]{{\[}}%[[VAL_101]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_101]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_102]], @b = %[[VAL_103]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_97]]{{\[}}%[[VAL_101]]] = %[[VAL_104]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_97]] }  : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_94]], @b = %[[VAL_95]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_105]], %[[VAL_106]]) : (!pod.type<[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_96]][@"$component"] = %[[VAL_107]] : <@A_1::@"$bus_entry"<[]>>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_107]][@out] : <@A_1::@A_1<[]>>, !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_115:[0-9a-zA-Z_\.]+]] = %[[VAL_113]] to %[[VAL_111]] step %[[VAL_114]] {
// CONCRETE-NEXT:            scf.for %[[VAL_116:[0-9a-zA-Z_\.]+]] = %[[VAL_113]] to %[[VAL_112]] step %[[VAL_114]] {
// CONCRETE-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_110]]{{\[}}%[[VAL_115]], %[[VAL_116]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              array.write %[[VAL_108]]{{\[}}%[[VAL_115]], %[[VAL_116]]] = %[[VAL_118]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              array.write %[[VAL_109]]{{\[}}%[[VAL_115]], %[[VAL_116]]] = %[[VAL_119]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_96]][@out.a] = %[[VAL_108]] : <@A_1::@"$bus_entry"<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_96]][@out.b] = %[[VAL_109]] : <@A_1::@"$bus_entry"<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_96]] : !struct.type<@A_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_120:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@"$bus_entry"<[]>>, %[[VAL_121:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}, %[[VAL_122:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a.b"}, %[[VAL_123:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.a"}, %[[VAL_124:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_129:[0-9a-zA-Z_\.]+]] = %[[VAL_127]] to %[[VAL_126]] step %[[VAL_128]] {
// CONCRETE-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_129]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_122]]{{\[}}%[[VAL_129]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_130]], @b = %[[VAL_131]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_125]]{{\[}}%[[VAL_129]]] = %[[VAL_132]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_125]] }  : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_123]], @b = %[[VAL_124]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@"$component"] : <@A_1::@"$bus_entry"<[]>>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_135]], %[[VAL_133]], %[[VAL_134]]) : (!struct.type<@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@out.a] : <@A_1::@"$bus_entry"<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@out.b] : <@A_1::@"$bus_entry"<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@out] : <@A_1::@A_1<[]>>, !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.new  : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_144:[0-9a-zA-Z_\.]+]] = %[[VAL_142]] to %[[VAL_140]] step %[[VAL_143]] {
// CONCRETE-NEXT:            scf.for %[[VAL_145:[0-9a-zA-Z_\.]+]] = %[[VAL_142]] to %[[VAL_141]] step %[[VAL_143]] {
// CONCRETE-NEXT:              %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_144]], %[[VAL_145]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_147:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_144]], %[[VAL_145]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_146]], @b = %[[VAL_147]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              array.write %[[VAL_139]]{{\[}}%[[VAL_144]], %[[VAL_145]]] = %[[VAL_148]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CONCRETE-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_153:[0-9a-zA-Z_\.]+]] = %[[VAL_151]] to %[[VAL_149]] step %[[VAL_152]] {
// CONCRETE-NEXT:            scf.for %[[VAL_154:[0-9a-zA-Z_\.]+]] = %[[VAL_151]] to %[[VAL_150]] step %[[VAL_152]] {
// CONCRETE-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_153]], %[[VAL_154]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_153]], %[[VAL_154]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              constrain.eq %[[VAL_157]], %[[VAL_158]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              constrain.eq %[[VAL_159]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_0 {
// CONCRETE-NEXT:      struct.def @B_0 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_161:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@B_0::@B_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = struct.new : <@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_163]]{{\[}}%[[VAL_165]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          array.write %[[VAL_163]]{{\[}}%[[VAL_165]]] = %[[VAL_161]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_167]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_163]]{{\[}}%[[VAL_168]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          array.write %[[VAL_163]]{{\[}}%[[VAL_168]]] = %[[VAL_161]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_163]]{{\[}}%[[VAL_171]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          array.write %[[VAL_163]]{{\[}}%[[VAL_171]]] = %[[VAL_161]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_162]][@out] = %[[VAL_163]] : <@B_0::@B_0<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_162]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_173:[0-9a-zA-Z_\.]+]]: !struct.type<@B_0::@B_0<[]>>, %[[VAL_174:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_173]][@out] : <@B_0::@B_0<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_175]]{{\[}}%[[VAL_177]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_179]], %[[VAL_180]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_181]], %[[VAL_182]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_183]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_175]]{{\[}}%[[VAL_184]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_186]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_188]], %[[VAL_189]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_175]]{{\[}}%[[VAL_191]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_193]], %[[VAL_194]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_195]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]> {function.arg_name = "in"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in1"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@in] = %[[VAL_1]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_8]], %[[VAL_9]] : index
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_10]], %[[VAL_11]], %[[VAL_9]] : index
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_12]], %[[VAL_13]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_14]] {
// TEMPLATED-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// TEMPLATED-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_15]], %[[VAL_16]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// TEMPLATED-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_17]], %[[VAL_18]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_19]] {
// TEMPLATED-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// TEMPLATED-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_21]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_24]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.new  : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_26]]{{\[}}%[[VAL_27]]] = %[[VAL_23]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_26]]{{\[}}%[[VAL_28]]] = %[[VAL_25]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_26]] : <@A::@A<[]>>, !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_2]][@B_[[MEMBER0]]$inputs] = %[[VAL_3]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_2]][@B_[[MEMBER0]]] = %[[VAL_29]] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          function.return %[[VAL_2]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]> {function.arg_name = "in"}, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in1"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@out] : <@A::@A<[]>>, !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@a] : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.new  : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_43]]{{\[}}%[[VAL_44]]] = %[[VAL_41]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          array.insert %[[VAL_43]]{{\[}}%[[VAL_45]]] = %[[VAL_42]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_48]] to %[[VAL_46]] step %[[VAL_49]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_51:[0-9a-zA-Z_\.]+]] = %[[VAL_48]] to %[[VAL_47]] step %[[VAL_49]] {
// TEMPLATED-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_50]], %[[VAL_51]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_50]], %[[VAL_51]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_54]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_56]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_59]], %[[VAL_61]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@a] : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_66]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_63]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_70]], %[[VAL_72]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_74]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_34]], %[[VAL_76]]) : (!struct.type<@B::@B<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<2,3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<2,3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a.b"}, %[[VAL_79:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.a"}, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.b"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_86:[0-9a-zA-Z_\.]+]] = %[[VAL_84]] to %[[VAL_83]] step %[[VAL_85]] {
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_86]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_86]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_87]], @b = %[[VAL_88]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_82]]{{\[}}%[[VAL_86]]] = %[[VAL_89]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_82]] }  : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_79]], @b = %[[VAL_80]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_90]], %[[VAL_91]]) : (!pod.type<[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_81]][@"$component"] = %[[VAL_92]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_92]][@out] : <@A::@A<[]>>, !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_100:[0-9a-zA-Z_\.]+]] = %[[VAL_98]] to %[[VAL_96]] step %[[VAL_99]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_98]] to %[[VAL_97]] step %[[VAL_99]] {
// TEMPLATED-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_100]], %[[VAL_101]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              array.write %[[VAL_93]]{{\[}}%[[VAL_100]], %[[VAL_101]]] = %[[VAL_103]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              array.write %[[VAL_94]]{{\[}}%[[VAL_100]], %[[VAL_101]]] = %[[VAL_104]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_81]][@out.a] = %[[VAL_93]] : <@A::@"$bus_entry"<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_81]][@out.b] = %[[VAL_94]] : <@A::@"$bus_entry"<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_81]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_105:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_106:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}, %[[VAL_107:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "in.a.b"}, %[[VAL_108:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.a"}, %[[VAL_109:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_114:[0-9a-zA-Z_\.]+]] = %[[VAL_112]] to %[[VAL_111]] step %[[VAL_113]] {
// TEMPLATED-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_114]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_107]]{{\[}}%[[VAL_114]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_115]], @b = %[[VAL_116]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_110]]{{\[}}%[[VAL_114]]] = %[[VAL_117]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_110]] }  : <[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_108]], @b = %[[VAL_109]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_120]], %[[VAL_118]], %[[VAL_119]]) : (!struct.type<@A::@A<[]>>, !pod.type<[@a: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@out.b] : <@A::@"$bus_entry"<[]>>, !array.type<2,3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@out] : <@A::@A<[]>>, !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.new  : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_129:[0-9a-zA-Z_\.]+]] = %[[VAL_127]] to %[[VAL_125]] step %[[VAL_128]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_130:[0-9a-zA-Z_\.]+]] = %[[VAL_127]] to %[[VAL_126]] step %[[VAL_128]] {
// TEMPLATED-NEXT:              %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_129]], %[[VAL_130]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_122]]{{\[}}%[[VAL_129]], %[[VAL_130]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_131]], @b = %[[VAL_132]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              array.write %[[VAL_124]]{{\[}}%[[VAL_129]], %[[VAL_130]]] = %[[VAL_133]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_138:[0-9a-zA-Z_\.]+]] = %[[VAL_136]] to %[[VAL_134]] step %[[VAL_137]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_139:[0-9a-zA-Z_\.]+]] = %[[VAL_136]] to %[[VAL_135]] step %[[VAL_137]] {
// TEMPLATED-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_123]]{{\[}}%[[VAL_138]], %[[VAL_139]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_138]], %[[VAL_139]]] : <2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_142]], %[[VAL_143]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_144]], %[[VAL_145]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_146:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_146]], %[[VAL_146]], %[[VAL_146]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_147]][@out] = %[[VAL_148]] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          function.return %[[VAL_147]] : !struct.type<@B::@B<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_149:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_150:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_149]][@out] : <@B::@B<[]>>, !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_150]], %[[VAL_150]], %[[VAL_150]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_156:[0-9a-zA-Z_\.]+]] = %[[VAL_154]] to %[[VAL_153]] step %[[VAL_155]] {
// TEMPLATED-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_156]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_156]]] : <3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_159]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_161]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
