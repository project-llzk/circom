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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@FibonacciTmpl::@FibonacciTmpl<[5]>>} {
// CHECK-NEXT:    poly.template @FibonacciTmpl {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @FibonacciTmpl {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[SELF:[0-9a-zA-Z_\.]+]] = struct.new : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_B0:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_X0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_5:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_B1:[0-9a-zA-Z_\.]+]] = %[[V_B0]], %[[V_C1:[0-9a-zA-Z_\.]+]] = %[[V_N]], %[[V_X1:[0-9a-zA-Z_\.]+]] = %[[V_X0]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_10:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[V_11:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[V_C1]], %[[V_10]])
// CHECK-NEXT:            scf.condition(%[[V_11]]) %[[V_A1]], %[[V_B1]], %[[V_C1]], %[[V_X1]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[V_B2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[V_C2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[V_X2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[V_X3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A2]], %[[V_B2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[V_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_C3:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_C2]], %[[V_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_B2]], %[[V_X3]], %[[V_C3]], %[[V_X3]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_20:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_N]], %[[V_19]])
// CHECK-NEXT:          %[[V_21:[0-9a-zA-Z_\.]+]] = scf.if %[[V_20]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            struct.writem %[[SELF]][@out] = %[[V_22]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_22]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[V_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_24:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_N]], %[[V_23]])
// CHECK-NEXT:            %[[V_25:[0-9a-zA-Z_\.]+]] = scf.if %[[V_24]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[V_26:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              struct.writem %[[SELF]][@out] = %[[V_26]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[V_26]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[V_27:[0-9a-zA-Z_\.]+]] = felt.add %[[V_5]]#0, %[[V_5]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              struct.writem %[[SELF]][@out] = %[[V_27]] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[V_27]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[V_25]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[SELF]] : !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[SELF:[0-9a-zA-Z_\.]+]]: !struct.type<@FibonacciTmpl::@FibonacciTmpl<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %{{[0-9a-zA-Z_\.]+}} = struct.readm %[[SELF]][@out] : <@FibonacciTmpl::@FibonacciTmpl<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_B0:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_X0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_33:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_B1:[0-9a-zA-Z_\.]+]] = %[[V_B0]], %[[V_C1:[0-9a-zA-Z_\.]+]] = %[[V_N]], %[[V_X1:[0-9a-zA-Z_\.]+]] = %[[V_X0]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_38:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[V_39:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[V_C1]], %[[V_38]])
// CHECK-NEXT:            scf.condition(%[[V_39]]) %[[V_A1]], %[[V_B1]], %[[V_C1]], %[[V_X1]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[V_B2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[V_C2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[V_X2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[V_X3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A2]], %[[V_B2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[V_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_C3:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_C2]], %[[V_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_B2]], %[[V_X3]], %[[V_C3]], %[[V_X3]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_47:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_48:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_N]], %[[V_47]])
// CHECK-NEXT:          scf.if %[[V_48]] {
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[V_51:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_52:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_N]], %[[V_51]])
// CHECK-NEXT:            scf.if %[[V_52]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
