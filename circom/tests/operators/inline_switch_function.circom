// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function InlineSwitch(cond, a, b) {
    return cond ? a : b;
}

template CallInlineSwitch() {
    signal input in;
    signal output out <-- InlineSwitch(in != 0, 1 / in, 0);
}

component main = CallInlineSwitch();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@CallInlineSwitch::@CallInlineSwitch<[]>>} {
// CHECK-NEXT:    poly.template @InlineSwitch {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @InlineSwitch(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "cond"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "a"}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2> {function.arg_name = "b"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> i1
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_3]] -> (!poly.tvar<@T_arg1>) {
// CHECK-NEXT:          scf.yield %[[VAL_1]] : !poly.tvar<@T_arg1>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !poly.tvar<@T_arg1>
// CHECK-NEXT:          scf.yield %[[VAL_5]] : !poly.tvar<@T_arg1>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!poly.tvar<@T_arg1>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_6]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallInlineSwitch {
// CHECK-NEXT:      struct.def @CallInlineSwitch {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@CallInlineSwitch::@CallInlineSwitch<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@CallInlineSwitch::@CallInlineSwitch<[]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_7]], %[[VAL_9]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_11]], %[[VAL_7]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @InlineSwitch::@InlineSwitch(%[[VAL_10]], %[[VAL_12]], %[[VAL_13]]) : (i1, !felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_8]][@out] = %[[VAL_14]] : <@CallInlineSwitch::@CallInlineSwitch<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_8]] : !struct.type<@CallInlineSwitch::@CallInlineSwitch<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@CallInlineSwitch::@CallInlineSwitch<[]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@out] : <@CallInlineSwitch::@CallInlineSwitch<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
