// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function binop_comp(a, b) {
  return a > b;
}

template A(x) {
  signal input in;
  signal output out;

  out <-- binop_comp(in, x);
}

component main = A(5);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[5]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @binop_comp(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_0]], %[[VAL_1]])
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : i1
// CHECK-NEXT:      function.return %[[VAL_3]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @A<[@x]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[@x]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@x]>>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = function.call @binop_comp(%[[VAL_4]], %[[VAL_6]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_5]][@out] = %[[VAL_7]] : <@A<[@x]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_5]] : !struct.type<@A<[@x]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@x]>>, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_8]][@out] : <@A<[@x]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
