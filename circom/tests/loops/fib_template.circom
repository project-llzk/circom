// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @FibonacciTmpl {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_9]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_12]]) %[[VAL_7]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_15]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_14]], %[[VAL_17]], %[[VAL_19]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_2]], %[[VAL_20]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_21]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_0]][@out] = %[[VAL_23]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_2]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_25]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              struct.writem %[[VAL_0]][@out] = %[[VAL_27]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_6]]#0, %[[VAL_6]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              struct.writem %[[VAL_0]][@out] = %[[VAL_28]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_30]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_33]], %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_34]], %[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_31]], %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_35]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_39]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_42]]) %[[VAL_37]], %[[VAL_38]], %[[VAL_39]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_45]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_44]], %[[VAL_47]], %[[VAL_49]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_31]], %[[VAL_50]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_51]] {
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_31]], %[[VAL_52]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_53]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
