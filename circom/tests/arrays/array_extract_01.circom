// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
    signal input in[17][13];
    signal output out;

    var sum = 0;
    for(var i = 0; i < 17; i++) {
        var tmp[13];
        tmp = in[i];

        sum += tmp[i % 13];
    }
}

component main = A();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[A_0:[0-9a-zA-Z_\.]+]]: !array.type<17,13 x !felt.type>) -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[V_S0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]], %[[V_S1:[0-9a-zA-Z_\.]+]] = %[[V_S0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_7:[0-9a-zA-Z_\.]+]] = felt.const  17
// CHECK-NEXT:          %[[V_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_7]])
// CHECK-NEXT:          scf.condition(%[[V_8]]) %[[V_I1]], %[[V_S1]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_S2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[C0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_12:[0-9a-zA-Z_\.]+]] = array.new %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]] : <13 x !felt.type>
// CHECK-NEXT:          %[[V_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:          %[[V_14:[0-9a-zA-Z_\.]+]] = array.extract %[[A_0]]{{\[}}%[[V_13]]] : <17,13 x !felt.type>
// CHECK-NEXT:          %[[V_15:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:          %[[V_16:[0-9a-zA-Z_\.]+]] = felt.umod %[[V_I2]], %[[V_15]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_16]]
// CHECK-NEXT:          %[[V_18:[0-9a-zA-Z_\.]+]] = array.read %[[V_14]]{{\[}}%[[V_17]]] : <13 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_S3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_S2]], %[[V_18]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_20:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_20]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_I3]], %[[V_S3]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[V_1]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_22:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>, %[[V_23:[0-9a-zA-Z_\.]+]]: !array.type<17,13 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %{{[0-9a-zA-Z_\.]+}} = struct.readf %[[V_22]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[V_S0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_26:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]], %[[V_S1:[0-9a-zA-Z_\.]+]] = %[[V_S0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_29:[0-9a-zA-Z_\.]+]] = felt.const  17
// CHECK-NEXT:          %[[V_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_29]])
// CHECK-NEXT:          scf.condition(%[[V_30]]) %[[V_I1]], %[[V_S1]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_S2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[C0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_34:[0-9a-zA-Z_\.]+]] = array.new %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]], %[[C0]] : <13 x !felt.type>
// CHECK-NEXT:          %[[V_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:          %[[V_36:[0-9a-zA-Z_\.]+]] = array.extract %[[V_23]]{{\[}}%[[V_35]]] : <17,13 x !felt.type>
// CHECK-NEXT:          %[[V_37:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:          %[[V_38:[0-9a-zA-Z_\.]+]] = felt.umod %[[V_I2]], %[[V_37]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_38]]
// CHECK-NEXT:          %[[V_40:[0-9a-zA-Z_\.]+]] = array.read %[[V_36]]{{\[}}%[[V_39]]] : <13 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_S3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_S2]], %[[V_40]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_42]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_I3]], %[[V_S3]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
