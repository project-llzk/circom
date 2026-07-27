// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template FibonacciTmpl(N) {
    signal output out;

    var a = 0;
    var b = 1;
    var next = 0;

    var counter = N;
    while (counter > 2) { // known iteration count
        next = a + b;
        a = b;
        b = next;

        counter--;
    }

    if (N == 0) {
        out <-- 0;
    } else if (N == 1) {
        out <-- 1;
    } else {
        out <-- a + b;
    }
}

component main = FibonacciTmpl(5);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@FibonacciTmpl::@FibonacciTmpl<[5]>>} {
// CHECK-NEXT:    poly.template @FibonacciTmpl {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @FibonacciTmpl {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_1]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_8]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_11]]) %[[VAL_6]], %[[VAL_7]], %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_13]], %[[VAL_16]], %[[VAL_18]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_20]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_0]][@out] = %[[VAL_22]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_24]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              struct.writem %[[VAL_0]][@out] = %[[VAL_26]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_5]]#0, %[[VAL_5]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              struct.writem %[[VAL_0]][@out] = %[[VAL_27]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@out] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_31]], %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_32]], %[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_29]], %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_37]], %[[VAL_39]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_40]]) %[[VAL_35]], %[[VAL_36]], %[[VAL_37]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_43]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_42]], %[[VAL_45]], %[[VAL_47]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_29]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_49]] {
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_29]], %[[VAL_50]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_51]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
