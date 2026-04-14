// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function myAdd(x1,y1,x2,y2) {
    var res[2] = [0x1 + y1, x2 + y2];
    return res;
}

function myFun() {
    var out[1][1];
    var dbl[2] = [18446744073709551557,18446744073709551557];
    for (var i=0; i < 4; i++) {
        dbl = myAdd(dbl[0], dbl[1], dbl[0], dbl[1]);
    }
    return out;
}

template A() {
    var table[1][1];
    table = myFun();
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A_0::@A_0<[]>>} {
// CHECK-NEXT:    function.def @myAdd_1(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_4]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_4]]{{\[}}%[[VAL_10]]] = %[[VAL_8]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_4]]{{\[}}%[[VAL_14]]] = %[[VAL_12]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_4]]{{\[}}%[[VAL_17]]] = %[[VAL_15]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      function.return %[[VAL_4]] : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:    }
// CHECK-NEXT:    function.def @myFun_0() -> !array.type<1,1 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_18:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:      %[[VAL_19:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:      %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_19]]{{\[}}%[[VAL_22]]] = %[[VAL_20]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:      array.insert %[[VAL_18]]{{\[}}%[[VAL_24]]] = %[[VAL_19]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:      %[[VAL_25:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:      %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_25]]{{\[}}%[[VAL_28]]] = %[[VAL_26]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_25]]{{\[}}%[[VAL_31]]] = %[[VAL_29]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  18446744073709551557
// CHECK-NEXT:      %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_25]]{{\[}}%[[VAL_34]]] = %[[VAL_32]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  18446744073709551557
// CHECK-NEXT:      %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:      array.write %[[VAL_25]]{{\[}}%[[VAL_37]]] = %[[VAL_35]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_39:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_25]], %[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_38]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        scf.condition(%[[VAL_43]]) %[[VAL_40]], %[[VAL_41]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_47]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_50]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_53]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_56]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = function.call @myAdd_1(%[[VAL_48]], %[[VAL_51]], %[[VAL_54]], %[[VAL_57]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_45]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        scf.yield %[[VAL_58]], %[[VAL_60]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_18]] : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @A_0 {
// CHECK-NEXT:      struct.def @A_0 {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_63]]{{\[}}%[[VAL_66]]] = %[[VAL_64]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_62]]{{\[}}%[[VAL_68]]] = %[[VAL_63]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = function.call @myFun_0() : () -> !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_61]] : !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_70:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_72]]{{\[}}%[[VAL_75]]] = %[[VAL_73]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_71]]{{\[}}%[[VAL_77]]] = %[[VAL_72]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = function.call @myFun_0() : () -> !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
