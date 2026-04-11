// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<17,13 x !felt.type>) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_2]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  17
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_5]], %[[VAL_7]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]], %[[VAL_11]] : <13 x !felt.type>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_0]]{{\[}}%[[VAL_13]]] : <17,13 x !felt.type>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_9]], %[[VAL_15]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_17]]] : <13 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_20]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_21]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !array.type<17,13 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@out] : <@A::@A<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_26]], %[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_25]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  17
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_28]], %[[VAL_30]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_31]]) %[[VAL_28]], %[[VAL_29]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]] : <13 x !felt.type>
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_23]]{{\[}}%[[VAL_36]]] : <17,13 x !felt.type>
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_32]], %[[VAL_38]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_40]]] : <13 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_33]], %[[VAL_41]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_32]], %[[VAL_43]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_44]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
