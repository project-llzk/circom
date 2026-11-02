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
    miBus(n) a[2];
}

template A(){
    otroBus(3) input in;
    miBus(3) input in1;

    miBus(3) output out[2] <== [in.a[0], in1];

    out[0].b === in.a[0].b;
}

component main = A();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_0::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]> {function.arg_name = "in"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in1"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_6]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_9]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_9]]] = %[[VAL_7]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_12]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_12]]] = %[[VAL_1]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          function.return %[[VAL_2]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]> {function.arg_name = "in"}, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in1"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@a] : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_20]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_23]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_25]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_27]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_30]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_32]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_34]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_37]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@a] : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_40]]{{\[}}%[[VAL_42]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in.a.b"}, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.a"}, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.b"}) -> !struct.type<@A_0::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]] to %[[VAL_51]] step %[[VAL_53]] {
// CONCRETE-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_54]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_54]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_55]], @b = %[[VAL_56]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_50]]{{\[}}%[[VAL_54]]] = %[[VAL_57]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_50]] }  : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_47]], @b = %[[VAL_48]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_58]], %[[VAL_59]]) : (!pod.type<[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_49]][@"$component"] = %[[VAL_60]] : <@A_0::@"$bus_entry"<[]>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_65]] to %[[VAL_64]] step %[[VAL_66]] {
// CONCRETE-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_67]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_61]]{{\[}}%[[VAL_67]]] = %[[VAL_69]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_62]]{{\[}}%[[VAL_67]]] = %[[VAL_70]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_49]][@out.a] = %[[VAL_61]] : <@A_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_49]][@out.b] = %[[VAL_62]] : <@A_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_49]] : !struct.type<@A_0::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@"$bus_entry"<[]>>, %[[VAL_72:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}, %[[VAL_73:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in.a.b"}, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.a"}, %[[VAL_75:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_78]] to %[[VAL_77]] step %[[VAL_79]] {
// CONCRETE-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_80]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_80]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_81]], @b = %[[VAL_82]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_80]]] = %[[VAL_83]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_76]] }  : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_74]], @b = %[[VAL_75]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@"$component"] : <@A_0::@"$bus_entry"<[]>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_86]], %[[VAL_84]], %[[VAL_85]]) : (!struct.type<@A_0::@A_0<[]>>, !pod.type<[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@out.a] : <@A_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@out.b] : <@A_0::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_86]][@out] : <@A_0::@A_0<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_94:[0-9a-zA-Z_\.]+]] = %[[VAL_92]] to %[[VAL_91]] step %[[VAL_93]] {
// CONCRETE-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_94]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_88]]{{\[}}%[[VAL_94]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_95]], @b = %[[VAL_96]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            array.write %[[VAL_90]]{{\[}}%[[VAL_94]]] = %[[VAL_97]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_99]] to %[[VAL_98]] step %[[VAL_100]] {
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_101]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_101]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_104]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_106]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]> {function.arg_name = "in"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in1"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_4]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_5]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_6]], %[[VAL_1]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_7]] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          function.return %[[VAL_2]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]> {function.arg_name = "in"}, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {function.arg_name = "in1"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_8]][@out] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@a] : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_14]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_15]], %[[VAL_10]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]] to %[[VAL_17]] step %[[VAL_19]] {
// TEMPLATED-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_20]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_20]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_23]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_25]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_28]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@a] : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_33]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_30]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}, %[[VAL_37:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in.a.b"}, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.a"}, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.b"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_43]] to %[[VAL_42]] step %[[VAL_44]] {
// TEMPLATED-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_45]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_45]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_46]], @b = %[[VAL_47]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_41]]{{\[}}%[[VAL_45]]] = %[[VAL_48]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_41]] }  : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_38]], @b = %[[VAL_39]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_49]], %[[VAL_50]]) : (!pod.type<[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@"$component"] = %[[VAL_51]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_51]][@out] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_56]] to %[[VAL_55]] step %[[VAL_57]] {
// TEMPLATED-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_58]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_52]]{{\[}}%[[VAL_58]]] = %[[VAL_60]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_53]]{{\[}}%[[VAL_58]]] = %[[VAL_61]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@out.a] = %[[VAL_52]] : <@A::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@out.b] = %[[VAL_53]] : <@A::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_40]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_63:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}, %[[VAL_64:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in.a.b"}, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.a"}, %[[VAL_66:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1.b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_69]] to %[[VAL_68]] step %[[VAL_70]] {
// TEMPLATED-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_71]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_71]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_72]], @b = %[[VAL_73]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_67]]{{\[}}%[[VAL_71]]] = %[[VAL_74]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_67]] }  : <[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_65]], @b = %[[VAL_66]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_77]], %[[VAL_75]], %[[VAL_76]]) : (!struct.type<@A::@A<[]>>, !pod.type<[@a: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@out.b] : <@A::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@out] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_85:[0-9a-zA-Z_\.]+]] = %[[VAL_83]] to %[[VAL_82]] step %[[VAL_84]] {
// TEMPLATED-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_85]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_85]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_86]], @b = %[[VAL_87]] }  : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            array.write %[[VAL_81]]{{\[}}%[[VAL_85]]] = %[[VAL_88]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_92:[0-9a-zA-Z_\.]+]] = %[[VAL_90]] to %[[VAL_89]] step %[[VAL_91]] {
// TEMPLATED-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_92]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_92]]] : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_95]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_97]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
