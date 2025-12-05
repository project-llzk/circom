// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(i) {
    var x = i;
    var y = x*x + 1;
    return y + 1;
}

template T() {
    signal input inp;
    signal output outp;

    outp <== f(inp);
}

component main = T();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:.*]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      %[[VAL_1:.*]] = felt.mul %[[VAL_0]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_2:.*]] = felt.const  1
// CHECK-NEXT:      %[[VAL_3:.*]] = felt.add %[[VAL_1]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_4:.*]] = felt.const  1
// CHECK-NEXT:      %[[VAL_5:.*]] = felt.add %[[VAL_3]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:      function.return %[[VAL_5]] : !felt.type
// CHECK-NEXT:    }

// CHECK-LABEL:   struct.def @T<[]> {
// CHECK-NEXT:      struct.field @outp : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type) -> !struct.type<@T<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:.*]] = struct.new : <@T<[]>>
// CHECK-NEXT:        %[[VAL_2:.*]] = function.call @f(%[[VAL_0]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@outp] = %[[VAL_2]] : <@T<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@T<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_3:.*]]: !struct.type<@T<[]>>, %[[VAL_4:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_5:.*]] = function.call @f(%[[VAL_4]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_6:.*]] = struct.readf %[[VAL_3]][@outp] : <@T<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_6]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
