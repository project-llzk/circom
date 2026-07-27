// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @myAdd {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_arg3 : !poly.tvar<@T_arg3>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @myAdd(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "x1"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "y1"}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2> {function.arg_name = "x2"}, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg3> {function.arg_name = "y2"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_4]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_6]], %[[VAL_7]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_8]], %[[VAL_11]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_12]] : (!array.type<2 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_13]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @myFun {
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @myFun() -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_14]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new  : <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_16]]{{\[}}%[[VAL_17]]] = %[[VAL_15]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_18]], %[[VAL_18]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  18446744073709551557 : <"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  18446744073709551557 : <"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_20]], %[[VAL_21]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_22]], %[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_23]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_26]], %[[VAL_27]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_28]]) %[[VAL_25]], %[[VAL_26]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_32]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_35]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_38]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_41]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = function.call @myAdd::@myAdd(%[[VAL_33]], %[[VAL_36]], %[[VAL_39]], %[[VAL_42]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_43]], %[[VAL_45]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_16]] : (!array.type<1,1 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_46]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_48]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.new  : <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_50]]{{\[}}%[[VAL_51]]] = %[[VAL_49]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = function.call @myFun::@myFun() : () -> !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_47]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_54]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.new  : <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_56]]{{\[}}%[[VAL_57]]] = %[[VAL_55]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = function.call @myFun::@myFun() : () -> !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
