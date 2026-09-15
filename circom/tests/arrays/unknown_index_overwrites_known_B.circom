// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template UnknownIndexOverwriteKnown() {
    signal input in;
    signal output out;

    var scalar1 = 45;
    var arr1[10] = [00, 01, 02, 03, 04, 05, 06, 07, 08, 09];
    var arr2[10] = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
    var arr3[10] = [20, 21, 22, 23, 24, 25, 26, 27, 28, 29];

    arr2[in] = 99;
    scalar1 = 46;

    assert(arr2[9] == 19);
    assert(arr2[9] == 99);

    assert(arr1[9] == 09);
    assert(arr1[4] == 04);
    assert(arr3[0] == 20);
    assert(arr3[7] == 27);

    assert(scalar1 == 46);
}

component main = UnknownIndexOverwriteKnown();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>} {
// CHECK-NEXT:    poly.template @UnknownIndexOverwriteKnown {
// CHECK-NEXT:      struct.def @UnknownIndexOverwriteKnown {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  45 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = global.read const @array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = global.read const @array_const_2 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_8]]{{\[}}%[[VAL_13]]] = %[[VAL_12]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  46 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_16]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_17]], %[[VAL_18]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_19]], "assertion failed"
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_21]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_22]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_24]], "assertion failed"
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_26]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_27]], %[[VAL_28]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_29]], "assertion failed"
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_31]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_32]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_34]], "assertion failed"
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_36]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  20 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_37]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_39]], "assertion failed"
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_41]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  27 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_42]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_44]], "assertion failed"
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  46 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_14]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_46]], "assertion failed"
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_47]][@out] : <@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  45 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_51]], %[[VAL_51]], %[[VAL_51]], %[[VAL_51]], %[[VAL_51]], %[[VAL_51]], %[[VAL_51]], %[[VAL_51]], %[[VAL_51]], %[[VAL_51]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_54]], %[[VAL_54]], %[[VAL_54]], %[[VAL_54]], %[[VAL_54]], %[[VAL_54]], %[[VAL_54]], %[[VAL_54]], %[[VAL_54]], %[[VAL_54]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = global.read const @array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_57]], %[[VAL_57]], %[[VAL_57]], %[[VAL_57]], %[[VAL_57]], %[[VAL_57]], %[[VAL_57]], %[[VAL_57]], %[[VAL_57]], %[[VAL_57]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = global.read const @array_const_2 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_56]]{{\[}}%[[VAL_61]]] = %[[VAL_60]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  46 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_64]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_65]], %[[VAL_66]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_67]], "assertion failed"
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_69]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_70]], %[[VAL_71]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_72]], "assertion failed"
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_74]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_75]], %[[VAL_76]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_77]], "assertion failed"
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_79]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_80]], %[[VAL_81]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_82]], "assertion failed"
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_84]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  20 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_85]], %[[VAL_86]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_87]], "assertion failed"
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_88]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_89]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  27 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_90]], %[[VAL_91]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_92]], "assertion failed"
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  46 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_62]], %[[VAL_93]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_94]], "assertion failed"
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<10 x !felt.type<"bn128">> = [ 0 : <"bn128">,  1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">,  8 : <"bn128">,  9 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_1 : !array.type<10 x !felt.type<"bn128">> = [ 10 : <"bn128">,  11 : <"bn128">,  12 : <"bn128">,  13 : <"bn128">,  14 : <"bn128">,  15 : <"bn128">,  16 : <"bn128">,  17 : <"bn128">,  18 : <"bn128">,  19 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_2 : !array.type<10 x !felt.type<"bn128">> = [ 20 : <"bn128">,  21 : <"bn128">,  22 : <"bn128">,  23 : <"bn128">,  24 : <"bn128">,  25 : <"bn128">,  26 : <"bn128">,  27 : <"bn128">,  28 : <"bn128">,  29 : <"bn128">]
// CHECK-NEXT:  }
