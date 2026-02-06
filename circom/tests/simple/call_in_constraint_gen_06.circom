// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(i) {
    return i;
}

template T() {
    signal input inp1;
    signal input inp2;
    signal input inp3;
    signal temp;

    temp <-- f(inp1);
    inp2 + inp3 === temp;
}

component main = T();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@T<[]>>} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type
// CHECK-NEXT:    }
//
// CHECK-LABEL:   struct.def @T<[]> {
// CHECK-NEXT:      struct.member @temp : !felt.type
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@T<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@T<[]>>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_0]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_3]][@temp] = %[[VAL_4]] : <@T<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@T<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@T<[]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_5]][@temp] : <@T<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_7]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_10]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
