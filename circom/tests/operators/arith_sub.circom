// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithSubtract() {
    signal input a;
    signal input b;
    signal input c;
    signal output x;
    x <== a - (b - 10);
}

component main = ArithSubtract();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ArithSubtract::@ArithSubtract<[]>>} {
// CHECK-NEXT:    poly.template @ArithSubtract {
// CHECK-NEXT:      struct.def @ArithSubtract {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@ArithSubtract::@ArithSubtract<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@ArithSubtract::@ArithSubtract<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_1]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_0]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@x] = %[[VAL_6]] : <@ArithSubtract::@ArithSubtract<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@ArithSubtract::@ArithSubtract<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@ArithSubtract::@ArithSubtract<[]>>, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_7]][@x] : <@ArithSubtract::@ArithSubtract<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_9]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
