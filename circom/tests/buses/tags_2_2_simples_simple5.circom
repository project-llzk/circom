// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus Bus1(){
    signal a[5];
    signal {value} b[2];
}

template B(){
    Bus1 input in;
    Bus1 output out <== in;

    in.b.value === 4;
}

template A(){
    signal input a[5];
    signal output b[5];

    signal {value} s;
    s.value = 4;
    s <== 5;

    signal {value} inter[3];
    inter.value = 4;
    inter[0] <== s;
    inter[1] <== s;
    inter[2] <== s;

    Bus1 aux;
    aux.a <== a;
    aux.b[0] <== inter[0];
    aux.b[1] <== inter[1];

    aux.b.value === 4;
    Bus1 output out <== B()(aux);

    b <== a;
}

component main = A();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_1::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @A_1 {
// CONCRETE-NEXT:      struct.def @A_1 {
// CONCRETE-NEXT:        struct.member @b : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @inter : !array.type<3 x !felt.type<"bn128">> {signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_8]] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_10]]] = %[[VAL_8]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_12]]] = %[[VAL_8]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_14]]] = %[[VAL_8]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_17]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_21]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_19]]{{\[}}%[[VAL_21]]] = %[[VAL_18]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_19]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_24]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_28]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_26]]{{\[}}%[[VAL_28]]] = %[[VAL_25]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_26]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          pod.write %[[VAL_7]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_31]], %[[VAL_32]] : index
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_33]], %[[VAL_34]], %[[VAL_32]] : index
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_35]], %[[VAL_36]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_37]] {
// CONCRETE-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CONCRETE-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_38]], %[[VAL_39]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_40]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_40]], %[[VAL_41]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_42]] {
// CONCRETE-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @B_0::@B_0::@compute(%[[VAL_44]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_45]] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_46]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_47]] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_0]] : <@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_7]] : <@A_1::@A_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_0::@B_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_48]] : <@A_1::@A_1<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@inter] = %[[VAL_3]] : <@A_1::@A_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@b] : <@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@s] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@inter] : <@A_1::@A_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@aux] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@B_[[MEMBER0]]] : <@A_1::@A_1<[]>>, !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@B_[[MEMBER0]]$inputs] : <@A_1::@A_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_60]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_61]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_63]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_64]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_66]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_67]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_68]], %[[VAL_50]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_70]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_74]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_75]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_77]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_81]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_82]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_83]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_86]], %[[VAL_87]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_88]], %[[VAL_89]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_91]], %[[VAL_92]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_93]], %[[VAL_94]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_51]], %[[VAL_50]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.call @B_0::@B_0::@constrain(%[[VAL_56]], %[[VAL_95]]) : (!struct.type<@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:        struct.member @b : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_96:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_1::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = function.call @A_1::@A_1::@compute(%[[VAL_96]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_97]][@"$component"] = %[[VAL_98]] : <@A_1::@"$bus_entry"<[]>>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_98]][@b] : <@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_98]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_97]][@b] = %[[VAL_99]] : <@A_1::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_97]][@out.a] = %[[VAL_101]] : <@A_1::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_97]][@out.b] = %[[VAL_102]] : <@A_1::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_97]] : !struct.type<@A_1::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_103:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@"$bus_entry"<[]>>, %[[VAL_104:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@"$component"] : <@A_1::@"$bus_entry"<[]>>, !struct.type<@A_1::@A_1<[]>>
// CONCRETE-NEXT:          function.call @A_1::@A_1::@constrain(%[[VAL_105]], %[[VAL_104]]) : (!struct.type<@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@b] : <@A_1::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@out.a] : <@A_1::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@out.b] : <@A_1::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@b] : <@A_1::@A_1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_109]], %[[VAL_106]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@out] : <@A_1::@A_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_107]], @b = %[[VAL_108]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_112]], %[[VAL_113]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_114]], %[[VAL_115]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_0 {
// CONCRETE-NEXT:      struct.def @B_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_116:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@B_0::@B_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = struct.new : <@B_0::@B_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_117]][@out] = %[[VAL_116]] : <@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_117]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_118:[0-9a-zA-Z_\.]+]]: !struct.type<@B_0::@B_0<[]>>, %[[VAL_119:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_118]][@out] : <@B_0::@B_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_121]], %[[VAL_122]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_123]], %[[VAL_124]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_125]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @b : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @inter : !array.type<3 x !felt.type<"bn128">> {signal}
// TEMPLATED-NEXT:        struct.member @aux : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[4]>>
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_4]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_5]]{{\[}}%[[VAL_7]]] = %[[VAL_4]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_5]]{{\[}}%[[VAL_9]]] = %[[VAL_4]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_5]]{{\[}}%[[VAL_11]]] = %[[VAL_4]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_14]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_18]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_16]]{{\[}}%[[VAL_18]]] = %[[VAL_15]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_16]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_21]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_23]]{{\[}}%[[VAL_25]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_25]]] = %[[VAL_22]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_23]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$b$value" = %[[VAL_27]] }  : <[@"$tag$in$b$value": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_29]], @params = %[[VAL_28]] }  : <[@count: index, @comp: !struct.type<@B::@B<[4]>>, @params: !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[4]>>, @params: !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_32]], %[[VAL_33]] : index
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_34]], %[[VAL_35]], %[[VAL_33]] : index
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_36]], %[[VAL_37]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_38]] {
// TEMPLATED-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[4]>>, @params: !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// TEMPLATED-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_39]], %[[VAL_40]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_30]][@count] = %[[VAL_41]] : <[@count: index, @comp: !struct.type<@B::@B<[4]>>, @params: !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_41]], %[[VAL_42]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_43]] {
// TEMPLATED-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[4]>>, @params: !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_45]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@B::@B<[4]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_30]][@comp] = %[[VAL_46]] : <[@count: index, @comp: !struct.type<@B::@B<[4]>>, @params: !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[4]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[4]>>, @params: !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[4]>>
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_47]][@out] : <@B::@B<[4]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_48]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_0]] : <@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_3]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[4]>>, @params: !pod.type<[@"$tag$in$b$value": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[4]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_49]] : <@A::@A<[]>>, !struct.type<@B::@B<[4]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@inter] = %[[VAL_5]] : <@A::@A<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_50:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_51:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@b] : <@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@s] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@inter] : <@A::@A<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@aux] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[4]>>
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_61]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_62]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_64]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_65]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_67]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_68]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_69]], %[[VAL_51]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_71]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_75]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_76]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_78]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_82]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_83]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_84]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_87]], %[[VAL_88]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_89]], %[[VAL_90]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_57]][@out] : <@B::@B<[4]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_92]], %[[VAL_93]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_94]], %[[VAL_95]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_52]], %[[VAL_51]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_57]], %[[VAL_96]]) : (!struct.type<@B::@B<[4]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @b : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_97:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_97]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_98]][@"$component"] = %[[VAL_99]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_99]][@b] : <@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_99]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_98]][@b] = %[[VAL_100]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_98]][@out.a] = %[[VAL_102]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_98]][@out.b] = %[[VAL_103]] : <@A::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_98]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_104:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_105:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_104]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_106]], %[[VAL_105]]) : (!struct.type<@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_104]][@b] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_104]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_104]][@out.b] : <@A::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_106]][@b] : <@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_110]], %[[VAL_107]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_106]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_108]], @b = %[[VAL_109]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_113]], %[[VAL_114]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_115]], %[[VAL_116]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$value"
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_117:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[@"$tag$in$b$value"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@"$tag$in$b$value"]>>
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$value" : !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_118]][@out] = %[[VAL_117]] : <@B::@B<[@"$tag$in$b$value"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_118]] : !struct.type<@B::@B<[@"$tag$in$b$value"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_120:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@"$tag$in$b$value"]>>, %[[VAL_121:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$value" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@out] : <@B::@B<[@"$tag$in$b$value"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_124]], %[[VAL_125]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_126]], %[[VAL_127]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_122]], %[[VAL_128]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
