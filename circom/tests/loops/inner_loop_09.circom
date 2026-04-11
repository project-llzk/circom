// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(N) {
    signal input in[N];
    signal output out;
    signal output out2[N];
    var a = 0;
    var b = 0;
    for (var i = 0; i < N; i++) {
        out2[i] <-- in[i] + b;
        for (var j = 0; j < N; j++) {
            a += 99;
        }
        b += 5;
    }
    out <-- a;
}

component main = InnerLoops(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerLoops<[2]>>} {
// CHECK-NEXT:    poly.template @InnerLoops {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @InnerLoops {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        struct.member @out2 : !array.type<@N x !felt.type> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) -> !struct.type<@InnerLoops::@InnerLoops<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops::@InnerLoops<[@N]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@N x !felt.type>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_10]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_11]]) %[[VAL_8]], %[[VAL_9]], %[[VAL_10]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_15]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_18]]] = %[[VAL_17]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:              scf.condition(%[[VAL_23]]) %[[VAL_21]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_28]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_27]], %[[VAL_29]] : !felt.type, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_30]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_20]]#0, %[[VAL_31]], %[[VAL_33]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_7]]#0 : <@InnerLoops::@InnerLoops<[@N]>>, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out2] = %[[VAL_3]] : <@InnerLoops::@InnerLoops<[@N]>>, !array.type<@N x !felt.type>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@InnerLoops::@InnerLoops<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops::@InnerLoops<[@N]>>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@out] : <@InnerLoops::@InnerLoops<[@N]>>, !felt.type
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@out2] : <@InnerLoops::@InnerLoops<[@N]>>, !array.type<@N x !felt.type>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_39]], %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_40]], %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_41]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_45]], %[[VAL_36]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_46]]) %[[VAL_43]], %[[VAL_44]], %[[VAL_45]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_49:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_47]], %[[VAL_53:[0-9a-zA-Z_\.]+]] = %[[VAL_50]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_53]], %[[VAL_36]]) : !felt.type, !felt.type
// CHECK-NEXT:              scf.condition(%[[VAL_54]]) %[[VAL_52]], %[[VAL_53]] : !felt.type, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_55:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_55]], %[[VAL_57]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_59]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_58]], %[[VAL_60]] : !felt.type, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_48]], %[[VAL_61]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_49]], %[[VAL_63]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_51]]#0, %[[VAL_62]], %[[VAL_64]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
