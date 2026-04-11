// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:    function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @T {
// CHECK-NEXT:      struct.def @T {
// CHECK-NEXT:        struct.member @temp : !felt.type
// CHECK-NEXT:        function.def @compute(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@T::@T<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.new : <@T::@T<[]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_1]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_4]][@temp] = %[[VAL_5]] : <@T::@T<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_4]] : !struct.type<@T::@T<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !struct.type<@T::@T<[]>>, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_6]][@temp] : <@T::@T<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
