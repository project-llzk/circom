// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          scf.yield %[[VAL_4]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_5]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_6]] -> (!array.type<3,3 x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = global.read const @array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_10]], %[[VAL_11]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_9]]{{\[}}%[[VAL_10]], %[[VAL_11]]] = %[[VAL_12]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_13]], %[[VAL_14]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_9]]{{\[}}%[[VAL_13]], %[[VAL_14]]] = %[[VAL_15]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_16]], %[[VAL_17]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_9]]{{\[}}%[[VAL_16]], %[[VAL_17]]] = %[[VAL_18]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_19]], %[[VAL_20]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_9]]{{\[}}%[[VAL_19]], %[[VAL_20]]] = %[[VAL_21]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_9]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = global.read const @array_const_2 : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_24]], %[[VAL_25]]] : <1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_23]]{{\[}}%[[VAL_24]], %[[VAL_25]]] = %[[VAL_26]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_23]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_7]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_3]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<3,3 x !felt.type<"bn128">> = [ 12 : <"bn128">,  11 : <"bn128">,  10 : <"bn128">,  23 : <"bn128">,  24 : <"bn128">,  25 : <"bn128">,  53 : <"bn128">,  55 : <"bn128">,  54 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_1 : !array.type<2,2 x !felt.type<"bn128">> = [ 33 : <"bn128">,  99 : <"bn128">,  88 : <"bn128">,  77 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_2 : !array.type<1,1 x !felt.type<"bn128">> = [ 0 : <"bn128">]
// CHECK-NEXT:    poly.template @Poseidon_0 {
// CHECK-NEXT:      struct.def @Poseidon_0 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "inputs"}) -> !struct.type<@Poseidon_0::@Poseidon_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.new : <@Poseidon_0::@Poseidon_0<[]>>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_32]]{{\[}}%[[VAL_35]]] = %[[VAL_33]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_32]]{{\[}}%[[VAL_38]]] = %[[VAL_36]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_31]]{{\[}}%[[VAL_40]]] = %[[VAL_32]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_31]]{{\[}}%[[VAL_42]]] = %[[VAL_32]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_43]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_49:[0-9a-zA-Z_\.]+]] = %[[VAL_47]] to %[[VAL_45]] step %[[VAL_48]] {
// CHECK-NEXT:            scf.for %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_47]] to %[[VAL_46]] step %[[VAL_48]] {
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_49]], %[[VAL_50]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_31]]{{\[}}%[[VAL_49]], %[[VAL_50]]] = %[[VAL_51]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  297 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_55]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_53]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_52]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_61]]{{\[}}%[[VAL_64]]] = %[[VAL_62]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_60]]{{\[}}%[[VAL_66]]] = %[[VAL_61]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_67]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_71]] to %[[VAL_69]] step %[[VAL_72]] {
// CHECK-NEXT:            scf.for %[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_71]] to %[[VAL_70]] step %[[VAL_72]] {
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_68]]{{\[}}%[[VAL_73]], %[[VAL_74]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_60]]{{\[}}%[[VAL_73]], %[[VAL_74]]] = %[[VAL_75]] : <1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_78]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_76]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_58]], %[[VAL_80]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_28]][@out] = %[[VAL_81]] : <@Poseidon_0::@Poseidon_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_28]] : !struct.type<@Poseidon_0::@Poseidon_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_82:[0-9a-zA-Z_\.]+]]: !struct.type<@Poseidon_0::@Poseidon_0<[]>>, %[[VAL_83:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "inputs"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_82]][@out] : <@Poseidon_0::@Poseidon_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_88]]{{\[}}%[[VAL_91]]] = %[[VAL_89]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_88]]{{\[}}%[[VAL_94]]] = %[[VAL_92]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_87]]{{\[}}%[[VAL_96]]] = %[[VAL_88]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_87]]{{\[}}%[[VAL_98]]] = %[[VAL_88]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_99]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_105:[0-9a-zA-Z_\.]+]] = %[[VAL_103]] to %[[VAL_101]] step %[[VAL_104]] {
// CHECK-NEXT:            scf.for %[[VAL_106:[0-9a-zA-Z_\.]+]] = %[[VAL_103]] to %[[VAL_102]] step %[[VAL_104]] {
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_100]]{{\[}}%[[VAL_105]], %[[VAL_106]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_87]]{{\[}}%[[VAL_105]], %[[VAL_106]]] = %[[VAL_107]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  297 : <"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_111]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_109]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_108]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_117]]{{\[}}%[[VAL_120]]] = %[[VAL_118]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_116]]{{\[}}%[[VAL_122]]] = %[[VAL_117]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_123]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_129:[0-9a-zA-Z_\.]+]] = %[[VAL_127]] to %[[VAL_125]] step %[[VAL_128]] {
// CHECK-NEXT:            scf.for %[[VAL_130:[0-9a-zA-Z_\.]+]] = %[[VAL_127]] to %[[VAL_126]] step %[[VAL_128]] {
// CHECK-NEXT:              %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_129]], %[[VAL_130]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_116]]{{\[}}%[[VAL_129]], %[[VAL_130]]] = %[[VAL_131]] : <1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_134]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_132]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_114]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_84]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
