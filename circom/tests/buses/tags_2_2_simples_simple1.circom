// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus Bus1(){
    signal a[5];
    signal {binary} b;
}

template B(){
    Bus1 input in;
    Bus1 output out <== in;

    in.b.binary === 19;
}

template A(){
    signal input a[5];
    signal output b[5];

    Bus1 aux;
    aux.b.binary = 19;
    aux.a <== a;
    aux.b <== 0;

    aux.b.binary === 19;

    Bus1 output out <== B()(aux);

    b <== a;
}

component main = A();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_1::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @A_1 {
// CONCRETE-NEXT:      struct.def @A_1 {
// CONCRETE-NEXT:        struct.member @b : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_8]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_6]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_11]], %[[VAL_12]] : index
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_13]], %[[VAL_14]], %[[VAL_12]] : index
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_15]], %[[VAL_16]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_17]] {
// CONCRETE-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CONCRETE-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_18]], %[[VAL_19]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_5]][@count] = %[[VAL_20]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_20]], %[[VAL_21]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_22]] {
// CONCRETE-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = function.call @B_0::@B_0::@compute(%[[VAL_24]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_5]][@comp] = %[[VAL_25]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_27]] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_0]] : <@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_6]] : <@A_1::@A_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_28]] : <@A_1::@A_1<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@b] : <@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@aux] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@B_[[MEMBER0]]] : <@A_1::@A_1<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@B_[[MEMBER0]]$inputs] : <@A_1::@A_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_36]], %[[VAL_30]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_38]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_42]], %[[VAL_43]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_44]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_48]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_49]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_31]], %[[VAL_30]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @B_0::@B_0::@constrain(%[[VAL_34]], %[[VAL_51]]) : (!struct.type<@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        struct.member @b : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_52:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_1::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_52]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_53]][@"$component"] = %[[VAL_54]] : <@A_1::@"$bus_entry"<[]>>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_54]][@b] : <@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_54]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_53]][@b] = %[[VAL_55]] : <@A_1::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_53]][@out.a] = %[[VAL_57]] : <@A_1::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_53]][@out.b] = %[[VAL_58]] : <@A_1::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_53]] : !struct.type<@A_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@"$bus_entry"<[]>>, %[[VAL_60:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@"$component"] : <@A_1::@"$bus_entry"<[]>>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_61]], %[[VAL_60]]) : (!struct.type<@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@b] : <@A_1::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@out.a] : <@A_1::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@out.b] : <@A_1::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@b] : <@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_65]], %[[VAL_62]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_63]], @b = %[[VAL_64]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_68]], %[[VAL_69]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_70]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_0 {
// CONCRETE-NEXT:      struct.def @B_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_72:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@B_0::@B_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.new : <@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_73]][@out] = %[[VAL_72]] : <@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_73]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_74:[0-9a-zA-Z_\.]+]]: !struct.type<@B_0::@B_0<[]>>, %[[VAL_75:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_77]], %[[VAL_78]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_79]], %[[VAL_80]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_81]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @b : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @aux : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[19]>>
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_5]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$b$binary" = %[[VAL_7]] }  : <[@"$tag$in$b$binary": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@B::@B<[19]>>, @params: !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[19]>>, @params: !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_12]], %[[VAL_13]] : index
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_14]], %[[VAL_15]], %[[VAL_13]] : index
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_16]], %[[VAL_17]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_18]] {
// TEMPLATED-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[19]>>, @params: !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// TEMPLATED-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_19]], %[[VAL_20]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_10]][@count] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@B::@B<[19]>>, @params: !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_21]], %[[VAL_22]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_23]] {
// TEMPLATED-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[19]>>, @params: !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_25]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> !struct.type<@B::@B<[19]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_10]][@comp] = %[[VAL_26]] : <[@count: index, @comp: !struct.type<@B::@B<[19]>>, @params: !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[19]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[19]>>, @params: !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[19]>>
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@out] : <@B::@B<[19]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_28]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_0]] : <@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_3]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[19]>>, @params: !pod.type<[@"$tag$in$b$binary": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[19]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_29]] : <@A::@A<[]>>, !struct.type<@B::@B<[19]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@b] : <@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@aux] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[19]>>
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_31]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_40]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_44]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_45]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@out] : <@B::@B<[19]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_48]], %[[VAL_49]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_50]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_32]], %[[VAL_31]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_35]], %[[VAL_52]]) : (!struct.type<@B::@B<[19]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @b : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_53]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_54]][@"$component"] = %[[VAL_55]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_55]][@b] : <@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_55]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_54]][@b] = %[[VAL_56]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_54]][@out.a] = %[[VAL_58]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_54]][@out.b] = %[[VAL_59]] : <@A::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_54]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_62]], %[[VAL_61]]) : (!struct.type<@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@b] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@out.b] : <@A::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@b] : <@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_66]], %[[VAL_63]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_64]], @b = %[[VAL_65]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_69]], %[[VAL_70]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_71]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$binary"
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[@"$tag$in$b$binary"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@"$tag$in$b$binary"]>>
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$binary" : !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_74]][@out] = %[[VAL_73]] : <@B::@B<[@"$tag$in$b$binary"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_74]] : !struct.type<@B::@B<[@"$tag$in$b$binary"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@"$tag$in$b$binary"]>>, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$binary" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@out] : <@B::@B<[@"$tag$in$b$binary"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_80]], %[[VAL_81]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_82]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_78]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
