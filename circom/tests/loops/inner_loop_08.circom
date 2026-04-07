// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(N) {
    signal output out;
    var a = 0;
    var b = 1000;
    for (var i = 0; i < N; i++) {
        b += a;
        for (var j = 0; j < N; j++) {
            a += 99;
        }
        b -= 5;
    }
    out <-- a;
}

component main = InnerLoops(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerLoops<[2]>>} {
// CHECK-NEXT:    struct.def @InnerLoops<[@N]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@InnerLoops<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[SELF:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops<[@N]>>
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_B0:[0-9a-zA-Z_\.]+]] = felt.const  1000
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_5:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_B1:[0-9a-zA-Z_\.]+]] = %[[V_B0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_9]]) %[[V_A1]], %[[V_B1]], %[[V_I1]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_B2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_B3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_B2]], %[[V_A2]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_15:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A3:[0-9a-zA-Z_\.]+]] = %[[V_A2]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[V_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_J1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_18]]) %[[V_A3]], %[[V_J1]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A4:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_21:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:            %[[V_A5:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A4]], %[[V_21]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[V_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_J3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J2]], %[[V_23]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_A5]], %[[V_J3]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_25:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[V_B4:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_B3]], %[[V_25]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_27]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_15]]#0, %[[V_B4]], %[[V_I3]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[SELF]][@out] = %[[V_5]]#0 : <@InnerLoops<[@N]>>, !felt.type
// CHECK-NEXT:        function.return %[[SELF]] : !struct.type<@InnerLoops<[@N]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[SELF:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[V_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[SELF]][@out] : <@InnerLoops<[@N]>>, !felt.type
// CHECK-NEXT:        %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_B0:[0-9a-zA-Z_\.]+]] = felt.const  1000
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_34:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_B1:[0-9a-zA-Z_\.]+]] = %[[V_B0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_38:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_38]]) %[[V_A1]], %[[V_B1]], %[[V_I1]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_B2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_B3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_B2]], %[[V_A2]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_44:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A3:[0-9a-zA-Z_\.]+]] = %[[V_A2]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[V_47:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_J1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_47]]) %[[V_A3]], %[[V_J1]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A4:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_50:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:            %[[V_A5:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A4]], %[[V_50]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[V_52:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_J3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J2]], %[[V_52]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_A5]], %[[V_J3]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_54:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[V_B4:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_B3]], %[[V_54]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_56:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_56]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_44]]#0, %[[V_B4]], %[[V_I3]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
