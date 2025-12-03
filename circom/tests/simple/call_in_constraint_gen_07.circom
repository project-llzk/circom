// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(i) {
    return i;
}

template T() {
    signal input inp1;
    signal input inp2;
    signal input inp3;

    var temp = f(inp1);
    inp2 + inp3 === temp;
}

component main = T();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:.*]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type
// CHECK-NEXT:    }

// CHECK-LABEL:   struct.def @T<[]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type, %[[VAL_1:.*]]: !felt.type, %[[VAL_2:.*]]: !felt.type) -> !struct.type<@T<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:.*]] = struct.new : <@T<[]>>
// CHECK-NEXT:        %[[VAL_4:.*]] = function.call @f(%[[VAL_0]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@T<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_5:.*]]: !struct.type<@T<[]>>, %[[VAL_6:.*]]: !felt.type, %[[VAL_7:.*]]: !felt.type, %[[VAL_8:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_9:.*]] = function.call @f(%[[VAL_6]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_10:.*]] = felt.add %[[VAL_7]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_10]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
