// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// This test demonstrates that the VCP computes the largest possible return size from `POSEIDON_M`
// and uses that for the entire function, even in branches where the actual array size is smaller.
// Although dimension sizes may be different, the number of dimensions must be the same.
function sum2(a, t) {
    var s = 0;
    for(var i = 0; i < t; i++) {
        for(var j = 0; j < t; j++) {
            s += a[i][j];
        }
    }
    return s;
}

function POSEIDON_M(t) {
   if (t == 3) {
        return [
            [12, 11, 10],
            [23, 24, 25],
            [53, 55, 54]
        ];
    } else if (t == 2) {
        return [
            [33, 99],
            [88, 77]
        ];
    } else  {
        return [[0]];
    }
}

template Poseidon() {
    signal input inputs[2];
    signal output out;

    var x = 0;
    {
        var i = 2;
        var M[i][i] = POSEIDON_M(i);
        // VCP contains computed sum2() as 297 with no call to `sum2` at all.
        x += sum2(M, i) * inputs[i-1];
    }
    {
        var i = 1;
        var M[i][i] = POSEIDON_M(i);
        // VCP contains computed sum2() as 0 with no call to `sum2` at all.
        x += sum2(M, i) * inputs[i-1];
    }
    out <== x;
}

component main = Poseidon();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Poseidon_0::@Poseidon_0<[]>>} {
// CHECK-NEXT:    poly.template @POSEIDON_M_0 {
// CHECK-NEXT:      function.def @POSEIDON_M_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "t"}) -> !array.type<3,3 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!array.type<3,3 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  11 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_10]]] = %[[VAL_8]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_13]]] = %[[VAL_11]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  23 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_14]]{{\[}}%[[VAL_17]]] = %[[VAL_15]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  24 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_14]]{{\[}}%[[VAL_20]]] = %[[VAL_18]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  25 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_14]]{{\[}}%[[VAL_23]]] = %[[VAL_21]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  53 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_24]]{{\[}}%[[VAL_27]]] = %[[VAL_25]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  55 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_24]]{{\[}}%[[VAL_30]]] = %[[VAL_28]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  54 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_24]]{{\[}}%[[VAL_33]]] = %[[VAL_31]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_34]]{{\[}}%[[VAL_36]]] = %[[VAL_4]] : <3,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_34]]{{\[}}%[[VAL_38]]] = %[[VAL_14]] : <3,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_34]]{{\[}}%[[VAL_40]]] = %[[VAL_24]] : <3,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          scf.yield %[[VAL_34]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_42]] -> (!array.type<3,3 x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_44]]{{\[}}%[[VAL_47]]] = %[[VAL_45]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_44]]{{\[}}%[[VAL_50]]] = %[[VAL_48]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  88 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_51]]{{\[}}%[[VAL_54]]] = %[[VAL_52]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_51]]{{\[}}%[[VAL_57]]] = %[[VAL_55]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_58]]{{\[}}%[[VAL_60]]] = %[[VAL_44]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_58]]{{\[}}%[[VAL_62]]] = %[[VAL_51]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_64]], %[[VAL_65]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_63]]{{\[}}%[[VAL_64]], %[[VAL_65]]] = %[[VAL_66]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_67]], %[[VAL_68]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_63]]{{\[}}%[[VAL_67]], %[[VAL_68]]] = %[[VAL_69]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_70]], %[[VAL_71]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_63]]{{\[}}%[[VAL_70]], %[[VAL_71]]] = %[[VAL_72]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_73]], %[[VAL_74]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_63]]{{\[}}%[[VAL_73]], %[[VAL_74]]] = %[[VAL_75]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_63]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_79]]] = %[[VAL_77]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_80]]{{\[}}%[[VAL_82]]] = %[[VAL_76]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_84]], %[[VAL_85]]] : <1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_83]]{{\[}}%[[VAL_84]], %[[VAL_85]]] = %[[VAL_86]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_83]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_43]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_3]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Poseidon_0 {
// CHECK-NEXT:      struct.def @Poseidon_0 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_87:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "inputs"}) -> !struct.type<@Poseidon_0::@Poseidon_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.new : <@Poseidon_0::@Poseidon_0<[]>>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_92]]{{\[}}%[[VAL_95]]] = %[[VAL_93]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_92]]{{\[}}%[[VAL_98]]] = %[[VAL_96]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_99]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_91]]{{\[}}%[[VAL_100]]] = %[[VAL_92]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_91]]{{\[}}%[[VAL_102]]] = %[[VAL_92]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_103]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_107]] to %[[VAL_105]] step %[[VAL_108]] {
// CHECK-NEXT:            scf.for %[[VAL_110:[0-9a-zA-Z_\.]+]] = %[[VAL_107]] to %[[VAL_106]] step %[[VAL_108]] {
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_109]], %[[VAL_110]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_91]]{{\[}}%[[VAL_109]], %[[VAL_110]]] = %[[VAL_111]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  297 : <"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_115]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_113]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_112]], %[[VAL_117]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_121]]{{\[}}%[[VAL_124]]] = %[[VAL_122]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_120]]{{\[}}%[[VAL_126]]] = %[[VAL_121]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_127]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_131]] to %[[VAL_129]] step %[[VAL_132]] {
// CHECK-NEXT:            scf.for %[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_131]] to %[[VAL_130]] step %[[VAL_132]] {
// CHECK-NEXT:              %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_133]], %[[VAL_134]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_120]]{{\[}}%[[VAL_133]], %[[VAL_134]]] = %[[VAL_135]] : <1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_137]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_138]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_136]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_118]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_88]][@out] = %[[VAL_141]] : <@Poseidon_0::@Poseidon_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_88]] : !struct.type<@Poseidon_0::@Poseidon_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_142:[0-9a-zA-Z_\.]+]]: !struct.type<@Poseidon_0::@Poseidon_0<[]>>, %[[VAL_143:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "inputs"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_142]][@out] : <@Poseidon_0::@Poseidon_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_150]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_148]]{{\[}}%[[VAL_151]]] = %[[VAL_149]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_148]]{{\[}}%[[VAL_154]]] = %[[VAL_152]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_147]]{{\[}}%[[VAL_156]]] = %[[VAL_148]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_147]]{{\[}}%[[VAL_158]]] = %[[VAL_148]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_159]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_165:[0-9a-zA-Z_\.]+]] = %[[VAL_163]] to %[[VAL_161]] step %[[VAL_164]] {
// CHECK-NEXT:            scf.for %[[VAL_166:[0-9a-zA-Z_\.]+]] = %[[VAL_163]] to %[[VAL_162]] step %[[VAL_164]] {
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_160]]{{\[}}%[[VAL_165]], %[[VAL_166]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_147]]{{\[}}%[[VAL_165]], %[[VAL_166]]] = %[[VAL_167]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  297 : <"bn128">
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_143]]{{\[}}%[[VAL_171]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_169]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_168]], %[[VAL_173]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_179]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_177]]{{\[}}%[[VAL_180]]] = %[[VAL_178]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_176]]{{\[}}%[[VAL_182]]] = %[[VAL_177]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_183]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_189:[0-9a-zA-Z_\.]+]] = %[[VAL_187]] to %[[VAL_185]] step %[[VAL_188]] {
// CHECK-NEXT:            scf.for %[[VAL_190:[0-9a-zA-Z_\.]+]] = %[[VAL_187]] to %[[VAL_186]] step %[[VAL_188]] {
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_184]]{{\[}}%[[VAL_189]], %[[VAL_190]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_176]]{{\[}}%[[VAL_189]], %[[VAL_190]]] = %[[VAL_191]] : <1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_193]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_143]]{{\[}}%[[VAL_194]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_192]], %[[VAL_195]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_174]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_144]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
