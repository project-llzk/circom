// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional4(N) {
    signal output out[N];
    signal input in;

    for (var i = 0; i < N; i++) {
        if (i < 3) {
            out[i] <-- -in;
        } else {
            out[i] <-- in;
        }
    }
}

component main = InnerConditional4(6);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@InnerConditional4::@InnerConditional4<[6]>>} {
// CHECK-NEXT:    poly.template @InnerConditional4 {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @InnerConditional4 {
// CHECK-NEXT:        struct.member @out : !array.type<@N x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@InnerConditional4::@InnerConditional4<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional4::@InnerConditional4<[@N]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_11]] {
// CHECK-NEXT:              %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4]]{{\[}}%[[VAL_13]]] = %[[VAL_12]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4]]{{\[}}%[[VAL_14]]] = %[[VAL_0]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@InnerConditional4::@InnerConditional4<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@InnerConditional4::@InnerConditional4<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional4::@InnerConditional4<[@N]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@InnerConditional4::@InnerConditional4<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_20]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_26]], %[[VAL_27]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_28]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
