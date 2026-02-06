// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional1(N) {
    signal output out;

    var acc = 0;
    for (var i = 1; i <= N; i++) {
        if (i < 5) {
            acc += i;
        } else {
            acc -= i;
        }
    }
    //Values at loop header per iteration
    //  N, acc, i
    // 10,   0, 1
    // 10,   1, 2
    // 10,   3, 3
    // 10,   6, 4
    // 10,  10, 5
    // 10,   5, 6
    // 10,  -1, 7
    // 10,  -8, 8
    // 10, -16, 9
    // 10, -25, 10

    out <-- acc;
}

component main = InnerConditional1(10);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerConditional1<[10]>>} {
// CHECK-NEXT:    struct.def @InnerConditional1<[@N]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@InnerConditional1<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[SELF:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional1<[@N]>>
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_7:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_7]]) %[[V_A1]], %[[V_I1]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_10:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[V_11:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I2]], %[[V_10]])
// CHECK-NEXT:          %[[V_12:[0-9a-zA-Z_\.]+]] = scf.if %[[V_11]] -> (!felt.type) {
// CHECK-NEXT:            %[[V_13:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A2]], %[[V_I2]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_13]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[V_14:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_A2]], %[[V_I2]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_14]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_16:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_15]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_12]], %[[V_16]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[SELF]][@out] = %[[V_4]]#0 : <@InnerConditional1<[@N]>>, !felt.type
// CHECK-NEXT:        function.return %[[SELF]] : !struct.type<@InnerConditional1<[@N]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[SELF:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional1<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %{{[0-9a-zA-Z_\.]+}} = struct.readm %[[SELF]][@out] : <@InnerConditional1<[@N]>>, !felt.type
// CHECK-NEXT:        %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_21:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_24:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_24]]) %[[V_A1]], %[[V_I1]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_27:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[V_28:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I2]], %[[V_27]])
// CHECK-NEXT:          %[[V_29:[0-9a-zA-Z_\.]+]] = scf.if %[[V_28]] -> (!felt.type) {
// CHECK-NEXT:            %[[V_30:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A2]], %[[V_I2]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_30]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[V_31:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_A2]], %[[V_I2]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_31]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_33:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_32]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_29]], %[[V_33]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
