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
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<10 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<10 x !felt.type<"bn128">> = [ 0 : <"bn128">,  1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">,  8 : <"bn128">,  9 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<10 x !felt.type<"bn128">> = [ 10 : <"bn128">,  11 : <"bn128">,  12 : <"bn128">,  13 : <"bn128">,  14 : <"bn128">,  15 : <"bn128">,  16 : <"bn128">,  17 : <"bn128">,  18 : <"bn128">,  19 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_3 : !array.type<10 x !felt.type<"bn128">> = [ 20 : <"bn128">,  21 : <"bn128">,  22 : <"bn128">,  23 : <"bn128">,  24 : <"bn128">,  25 : <"bn128">,  26 : <"bn128">,  27 : <"bn128">,  28 : <"bn128">,  29 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @UnknownIndexOverwriteKnown {
// CHECK-NEXT:      struct.def @UnknownIndexOverwriteKnown {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  45 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_28]]{{\[}}%[[VAL_43]]] = %[[VAL_42]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  46 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_46]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_47]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_49]], "assertion failed"
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_51]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_52]], %[[VAL_53]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_54]], "assertion failed"
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_56]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_57]], %[[VAL_58]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_59]], "assertion failed"
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_61]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_62]], %[[VAL_63]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_64]], "assertion failed"
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_66]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  20 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_67]], %[[VAL_68]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_69]], "assertion failed"
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_71]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  27 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_72]], %[[VAL_73]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_74]], "assertion failed"
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  46 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_44]], %[[VAL_75]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_76]], "assertion failed"
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@out] : <@UnknownIndexOverwriteKnown::@UnknownIndexOverwriteKnown<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  45 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_106]]{{\[}}%[[VAL_121]]] = %[[VAL_120]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  46 : <"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_124]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  19 : <"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_125]], %[[VAL_126]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_127]], "assertion failed"
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_129]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_130]], %[[VAL_131]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_132]], "assertion failed"
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_134]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_135]], %[[VAL_136]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_137]], "assertion failed"
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_139]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_140]], %[[VAL_141]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_142]], "assertion failed"
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_143]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_144]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  20 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_145]], %[[VAL_146]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_147]], "assertion failed"
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_149]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  27 : <"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_150]], %[[VAL_151]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_152]], "assertion failed"
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  46 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_122]], %[[VAL_153]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_154]], "assertion failed"
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
