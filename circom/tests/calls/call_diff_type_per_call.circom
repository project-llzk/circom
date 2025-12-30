// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function f(a, b) {
    return a + b;
}

// In circom, `signal` and `var` are both field elements, so there's
// actually no difference in the function type between the two calls.
template CallDiffTypeTest() {
    signal input in1;
    signal input in2;
    signal output out1;
    signal output out2;

    out1 <== f(in1, in2); // f: (felt, felt) -> felt

    var a = 1;
    var x = f(a, in2); // f: (felt, felt) -> felt
    out2 <== x;
}

component main = CallDiffTypeTest();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type,
// CHECK-SAME:                    %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type {
// CHECK-NEXT:       %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:       function.return %[[VAL_2]] : !felt.type
// CHECK-NEXT:     }
//
// CHECK-LABEL:   struct.def @CallDiffTypeTest<[]> {
// CHECK-NEXT:      struct.field @out1 : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @out2 : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@CallDiffTypeTest<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@CallDiffTypeTest<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_0]], %[[VAL_1]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@out1] = %[[VAL_3]] : <@CallDiffTypeTest<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_4]], %[[VAL_1]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@out2] = %[[VAL_5]] : <@CallDiffTypeTest<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@CallDiffTypeTest<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_6:[0-9a-zA-Z_\.]+]]: !struct.type<@CallDiffTypeTest<[]>>, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_7]], %[[VAL_8]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_6]][@out1] : <@CallDiffTypeTest<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_10]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_11]], %[[VAL_8]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_6]][@out2] : <@CallDiffTypeTest<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_13]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
