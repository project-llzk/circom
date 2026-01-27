// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(N) {
    signal output out;
    var a = 0;
    for (var i = 0; i < N; i++) {
        for (var j = 0; j < N; j++) {
            a += 99;
        }
    }
    out <-- a;
}

component main = InnerLoops(2);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @InnerLoops<[@N]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@InnerLoops<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[SELF:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops<[@N]>>
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_7]]) %[[V_A1]], %[[V_I1]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A3:[0-9a-zA-Z_\.]+]] = %[[V_A2]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[V_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_J1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_14]]) %[[V_A3]], %[[V_J1]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A4:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_17:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:            %[[V_A5:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A4]], %[[V_17]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[V_19:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_J3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J2]], %[[V_19]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_A5]], %[[V_J3]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_21]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_11]]#0, %[[V_I3]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[SELF]][@out] = %[[V_4]]#0 : <@InnerLoops<[@N]>>, !felt.type
// CHECK-NEXT:        function.return %[[SELF]] : !struct.type<@InnerLoops<[@N]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[SELF:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[V_A0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_27:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_30]]) %[[V_A1]], %[[V_I1]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_34:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A3:[0-9a-zA-Z_\.]+]] = %[[V_A2]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[V_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_J1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_37]]) %[[V_A3]], %[[V_J1]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A4:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_40:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:            %[[V_A5:[0-9a-zA-Z_\.]+]] = felt.add %[[V_A4]], %[[V_40]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[V_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_J3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J2]], %[[V_42]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_A5]], %[[V_J3]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_44:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_44]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_34]]#0, %[[V_I3]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_46:[0-9a-zA-Z_\.]+]] = struct.readf %[[SELF]][@out] : <@InnerLoops<[@N]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
