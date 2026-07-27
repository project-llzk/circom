// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@InnerConditional1::@InnerConditional1<[10]>>} {
// CHECK-NEXT:    poly.template @InnerConditional1 {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @InnerConditional1 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional1::@InnerConditional1<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional1::@InnerConditional1<[@N]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_6]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_11]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_12]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_4]]#0 : <@InnerConditional1::@InnerConditional1<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@InnerConditional1::@InnerConditional1<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional1::@InnerConditional1<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@InnerConditional1::@InnerConditional1<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_24]], %[[VAL_18]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_23]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_27]], %[[VAL_28]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_29]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_30]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
