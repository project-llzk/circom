// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus MiBusPeque{
    signal a[2];
}

bus MiBus{
    signal b;
    MiBusPeque a[2];
}

template A(){
    MiBus input in;
    MiBus output out;

    if (in.b > 10){
        out.a[1].a[0] <-- in.a[0].a[0];
    } else{
        out.a[1].a[0] <-- in.a[0].a[0];
    }
    out.a[0].a <== [3,3];
}

component main = A();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_0::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @A_0 {
// CONCRETE-NEXT:      struct.def @A_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_3]], %[[VAL_4]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          scf.if %[[VAL_5]] {
// CONCRETE-NEXT:            %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_6]]{{\[}}%[[VAL_8]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_12]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_16]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_20]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_18]]{{\[}}%[[VAL_20]]] = %[[VAL_13]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_17]][@a] = %[[VAL_18]] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            array.write %[[VAL_14]]{{\[}}%[[VAL_16]]] = %[[VAL_17]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            pod.write %[[VAL_2]][@a] = %[[VAL_14]] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          } else {
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_24]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_28]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_32]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_36]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_34]]{{\[}}%[[VAL_36]]] = %[[VAL_29]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_33]][@a] = %[[VAL_34]] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            array.write %[[VAL_30]]{{\[}}%[[VAL_32]]] = %[[VAL_33]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            pod.write %[[VAL_2]][@a] = %[[VAL_30]] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_41]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_45]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_43]]{{\[}}%[[VAL_45]]] = %[[VAL_38]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_42]][@a] = %[[VAL_43]] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_39]]{{\[}}%[[VAL_41]]] = %[[VAL_42]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_39]] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_50]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_54]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_52]]{{\[}}%[[VAL_54]]] = %[[VAL_47]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_51]][@a] = %[[VAL_52]] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_48]]{{\[}}%[[VAL_50]]] = %[[VAL_51]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_48]] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@A_0::@A_0<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_59]], %[[VAL_60]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          scf.if %[[VAL_61]] {
// CONCRETE-NEXT:          } else {
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_65]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_69]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_70]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_74]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_78]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_79]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:        struct.member @out.b : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.a.a : !array.type<2,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.b"}, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}) -> !struct.type<@A_0::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_87:[0-9a-zA-Z_\.]+]] = %[[VAL_85]] to %[[VAL_84]] step %[[VAL_86]] {
// CONCRETE-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_81]]{{\[}}%[[VAL_87]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_88]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_83]]{{\[}}%[[VAL_87]]] = %[[VAL_89]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.new { @b = %[[VAL_80]], @a = %[[VAL_83]] }  : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = function.call @A_0::@A_0::@compute(%[[VAL_90]]) : (!pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_82]][@"$component"] = %[[VAL_91]] : <@A_0::@"$bus_entry"<[]>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_91]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_99:[0-9a-zA-Z_\.]+]] = %[[VAL_97]] to %[[VAL_96]] step %[[VAL_98]] {
// CONCRETE-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_99]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            array.insert %[[VAL_92]]{{\[}}%[[VAL_99]]] = %[[VAL_101]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_82]][@out.b] = %[[VAL_94]] : <@A_0::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_82]][@out.a.a] = %[[VAL_92]] : <@A_0::@"$bus_entry"<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_82]] : !struct.type<@A_0::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_102:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@"$bus_entry"<[]>>, %[[VAL_103:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.b"}, %[[VAL_104:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_107]] to %[[VAL_106]] step %[[VAL_108]] {
// CONCRETE-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_104]]{{\[}}%[[VAL_109]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_110]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_105]]{{\[}}%[[VAL_109]]] = %[[VAL_111]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.new { @b = %[[VAL_103]], @a = %[[VAL_105]] }  : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_102]][@"$component"] : <@A_0::@"$bus_entry"<[]>>, !struct.type<@A_0::@A_0<[]>>
// CONCRETE-NEXT:          function.call @A_0::@A_0::@constrain(%[[VAL_113]], %[[VAL_112]]) : (!struct.type<@A_0::@A_0<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_102]][@out.b] : <@A_0::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_102]][@out.a.a] : <@A_0::@"$bus_entry"<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@out] : <@A_0::@A_0<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_119]] to %[[VAL_118]] step %[[VAL_120]] {
// CONCRETE-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_115]]{{\[}}%[[VAL_121]]] : <2,2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_122]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            array.write %[[VAL_117]]{{\[}}%[[VAL_121]]] = %[[VAL_123]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.new { @b = %[[VAL_114]], @a = %[[VAL_117]] }  : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_125]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_132:[0-9a-zA-Z_\.]+]] = %[[VAL_130]] to %[[VAL_129]] step %[[VAL_131]] {
// CONCRETE-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_132]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_132]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_135]], %[[VAL_136]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    module @global {
// TEMPLATED-NEXT:      global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 3 : <"bn128">,  3 : <"bn128">]
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_3]], %[[VAL_4]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_5]] {
// TEMPLATED-NEXT:            %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_6]]{{\[}}%[[VAL_8]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_12]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_16]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_20]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_18]]{{\[}}%[[VAL_20]]] = %[[VAL_13]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_17]][@a] = %[[VAL_18]] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            array.write %[[VAL_14]]{{\[}}%[[VAL_16]]] = %[[VAL_17]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            pod.write %[[VAL_2]][@a] = %[[VAL_14]] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_0]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_24]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_28]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_32]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_36]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_34]]{{\[}}%[[VAL_36]]] = %[[VAL_29]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_33]][@a] = %[[VAL_34]] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            array.write %[[VAL_30]]{{\[}}%[[VAL_32]]] = %[[VAL_33]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            pod.write %[[VAL_2]][@a] = %[[VAL_30]] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_41]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_42]][@a] = %[[VAL_38]] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          array.write %[[VAL_39]]{{\[}}%[[VAL_41]]] = %[[VAL_42]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_39]] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_44]][@out] : <@A::@A<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_47]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_49]] {
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_51]]{{\[}}%[[VAL_53]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_55]], %[[VAL_50]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.b : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.a.a : !array.type<2,2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.b"}, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_63:[0-9a-zA-Z_\.]+]] = %[[VAL_61]] to %[[VAL_60]] step %[[VAL_62]] {
// TEMPLATED-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_57]]{{\[}}%[[VAL_63]]] : <2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_64]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_59]]{{\[}}%[[VAL_63]]] = %[[VAL_65]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.new { @b = %[[VAL_56]], @a = %[[VAL_59]] }  : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_66]]) : (!pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_58]][@"$component"] = %[[VAL_67]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_67]][@out] : <@A::@A<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_75:[0-9a-zA-Z_\.]+]] = %[[VAL_73]] to %[[VAL_72]] step %[[VAL_74]] {
// TEMPLATED-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_75]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            array.insert %[[VAL_68]]{{\[}}%[[VAL_75]]] = %[[VAL_77]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_58]][@out.b] = %[[VAL_70]] : <@A::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_58]][@out.a.a] = %[[VAL_68]] : <@A::@"$bus_entry"<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_58]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_78:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_79:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in.b"}, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "in.a.a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_85:[0-9a-zA-Z_\.]+]] = %[[VAL_83]] to %[[VAL_82]] step %[[VAL_84]] {
// TEMPLATED-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_80]]{{\[}}%[[VAL_85]]] : <2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_86]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_81]]{{\[}}%[[VAL_85]]] = %[[VAL_87]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.new { @b = %[[VAL_79]], @a = %[[VAL_81]] }  : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_89]], %[[VAL_88]]) : (!struct.type<@A::@A<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@out.b] : <@A::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@out.a.a] : <@A::@"$bus_entry"<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_89]][@out] : <@A::@A<[]>>, !pod.type<[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_95]] to %[[VAL_94]] step %[[VAL_96]] {
// TEMPLATED-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_91]]{{\[}}%[[VAL_97]]] : <2,2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_98]] }  : <[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            array.write %[[VAL_93]]{{\[}}%[[VAL_97]]] = %[[VAL_99]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.new { @b = %[[VAL_90]], @a = %[[VAL_93]] }  : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@b] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_101]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@a] : <[@b: !felt.type<"bn128">, @a: !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_106]] to %[[VAL_105]] step %[[VAL_107]] {
// TEMPLATED-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_108]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_108]]] : <2 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@a] : <[@a: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_111]], %[[VAL_112]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
