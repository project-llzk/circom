// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  45
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_5]], %[[VAL_6]], %[[VAL_7]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]], %[[VAL_11]], %[[VAL_12]], %[[VAL_13]], %[[VAL_14]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_16]], %[[VAL_16]], %[[VAL_16]], %[[VAL_16]], %[[VAL_16]], %[[VAL_16]], %[[VAL_16]], %[[VAL_16]], %[[VAL_16]], %[[VAL_16]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  11
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  14
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  16
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  17
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  18
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  19
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_18]], %[[VAL_19]], %[[VAL_20]], %[[VAL_21]], %[[VAL_22]], %[[VAL_23]], %[[VAL_24]], %[[VAL_25]], %[[VAL_26]], %[[VAL_27]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  20
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  21
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  22
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  23
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  24
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  25
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  26
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  27
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  28
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  29
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_31]], %[[VAL_32]], %[[VAL_33]], %[[VAL_34]], %[[VAL_35]], %[[VAL_36]], %[[VAL_37]], %[[VAL_38]], %[[VAL_39]], %[[VAL_40]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_28]]{{\[}}%[[VAL_43]]] = %[[VAL_42]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  46
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_46]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  19
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_47]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_49]], "assertion failed"
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_51]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_52]], %[[VAL_53]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_54]], "assertion failed"
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_56]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_57]], %[[VAL_58]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_59]], "assertion failed"
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_61]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_62]], %[[VAL_63]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_64]], "assertion failed"
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_66]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  20
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_67]], %[[VAL_68]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_69]], "assertion failed"
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_71]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  27
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_72]], %[[VAL_73]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_74]], "assertion failed"
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  46
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_44]], %[[VAL_75]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_76]], "assertion failed"
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@out] : <@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  45
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_81]], %[[VAL_81]], %[[VAL_81]], %[[VAL_81]], %[[VAL_81]], %[[VAL_81]], %[[VAL_81]], %[[VAL_81]], %[[VAL_81]], %[[VAL_81]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_83]], %[[VAL_84]], %[[VAL_85]], %[[VAL_86]], %[[VAL_87]], %[[VAL_88]], %[[VAL_89]], %[[VAL_90]], %[[VAL_91]], %[[VAL_92]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_94]], %[[VAL_94]], %[[VAL_94]], %[[VAL_94]], %[[VAL_94]], %[[VAL_94]], %[[VAL_94]], %[[VAL_94]], %[[VAL_94]], %[[VAL_94]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  11
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  14
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  16
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  17
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  18
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  19
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_96]], %[[VAL_97]], %[[VAL_98]], %[[VAL_99]], %[[VAL_100]], %[[VAL_101]], %[[VAL_102]], %[[VAL_103]], %[[VAL_104]], %[[VAL_105]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_107]], %[[VAL_107]], %[[VAL_107]], %[[VAL_107]], %[[VAL_107]], %[[VAL_107]], %[[VAL_107]], %[[VAL_107]], %[[VAL_107]], %[[VAL_107]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  20
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  21
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  22
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  23
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  24
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  25
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  26
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  27
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  28
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  29
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_109]], %[[VAL_110]], %[[VAL_111]], %[[VAL_112]], %[[VAL_113]], %[[VAL_114]], %[[VAL_115]], %[[VAL_116]], %[[VAL_117]], %[[VAL_118]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_106]]{{\[}}%[[VAL_121]]] = %[[VAL_120]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  46
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_124]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  19
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_125]], %[[VAL_126]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_127]], "assertion failed"
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_129]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_130]], %[[VAL_131]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_132]], "assertion failed"
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_134]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_135]], %[[VAL_136]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_137]], "assertion failed"
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_139]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_140]], %[[VAL_141]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_142]], "assertion failed"
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_143]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_144]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  20
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_145]], %[[VAL_146]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_147]], "assertion failed"
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_149]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  27
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_150]], %[[VAL_151]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_152]], "assertion failed"
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  46
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_122]], %[[VAL_153]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_154]], "assertion failed"
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
