// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(i) {
    return i + 1;
}

template T() {
    signal input inp;
    signal output outp;

    outp <== f(inp);
}

component main = T();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@T<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:      function.return %[[VAL_2]] : !felt.type
// CHECK-NEXT:    }

// CHECK-LABEL:   struct.def @T<[]> {
// CHECK-NEXT:      struct.field @outp : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@T<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@T<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_0]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@outp] = %[[VAL_2]] : <@T<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@T<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@T<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_3]][@outp] : <@T<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_4]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_6]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
