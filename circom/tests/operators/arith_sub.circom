// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @ArithSubtract<[]> {
// CHECK-NEXT:      struct.field @x : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@ArithSubtract<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@ArithSubtract<[]>>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_1]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_0]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_3]][@x] = %[[VAL_6]] : <@ArithSubtract<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@ArithSubtract<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@ArithSubtract<[]>>, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_9]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_7]][@x] : <@ArithSubtract<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_14]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
