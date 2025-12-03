// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(a, b) {
    return a + b;
}

template T() {
    signal input inp1;
    signal input inp2;
    signal input inp3;

    // Circom generates constraint "inp1 = inp2 + inp3"
    inp1 === f(inp2, inp3);
}

component main = T();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:.*]]: !felt.type,
// CHECK-SAME:                    %[[VAL_1:.*]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      %[[VAL_2:.*]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:      function.return %[[VAL_2]] : !felt.type
// CHECK-NEXT:    }

// CHECK-LABEL:   struct.def @T<[]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type, %[[VAL_1:.*]]: !felt.type, %[[VAL_2:.*]]: !felt.type) -> !struct.type<@T<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:.*]] = struct.new : <@T<[]>>
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@T<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_4:.*]]: !struct.type<@T<[]>>, %[[VAL_5:.*]]: !felt.type, %[[VAL_6:.*]]: !felt.type, %[[VAL_7:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_8:.*]] = function.call @f(%[[VAL_6]], %[[VAL_7]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_5]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
