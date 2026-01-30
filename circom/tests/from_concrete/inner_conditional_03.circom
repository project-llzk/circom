// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional3(N) {
    signal output out;
    signal input in;

    var acc = 0;
    for (var i = 1; i <= N; i++) {
        if (in == 0) { // unknown condition
            acc += i;
        } else {
            acc -= i;
        }
    }

    out <-- acc;
}

component main = InnerConditional3(3);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @InnerConditional3<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[V_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@InnerConditional3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[SELF:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional3<[]>>
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_7:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[V_8:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_I1]], %[[V_7]])
// CHECK-NEXT:          scf.condition(%[[V_8]]) %[[V_A1]], %[[V_I1]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_12:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_0]], %[[V_11]])
// CHECK-NEXT:          %[[V_13:[0-9a-zA-Z_\.]+]] = scf.if %[[V_12]] -> (!felt.type) {
// CHECK-NEXT:            %[[V_14:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A2]], %[[V_I2]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_14]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[V_15:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_A2]], %[[V_I2]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_15]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_17:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_16]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_13]], %[[V_17]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[SELF]][@out] = %[[V_4]]#0 : <@InnerConditional3<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[SELF]] : !struct.type<@InnerConditional3<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[SELF:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional3<[]>>, %[[V_19:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_36:[0-9a-zA-Z_\.]+]] = struct.readf %[[SELF]][@out] : <@InnerConditional3<[]>>, !felt.type
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_22:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_25:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[V_26:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_I1]], %[[V_25]])
// CHECK-NEXT:          scf.condition(%[[V_26]]) %[[V_A1]], %[[V_I1]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_30:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_19]], %[[V_29]])
// CHECK-NEXT:          %[[V_31:[0-9a-zA-Z_\.]+]] = scf.if %[[V_30]] -> (!felt.type) {
// CHECK-NEXT:            %[[V_32:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A2]], %[[V_I2]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_32]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[V_33:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_A2]], %[[V_I2]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_33]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_35:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_34]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_31]], %[[V_35]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
