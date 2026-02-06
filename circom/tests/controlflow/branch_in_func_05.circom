// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function complicated(n){
  var x = 99;
  var y = 88;
  var z = 77;
  if (n < 0) {
    x = 1;
    y = 2;
    z = 4;
  }
  return x + y + z;
}

template C() {
  signal input in;
  signal output out;
  out <-- complicated(in);
}

component main = C();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@C<[]>>} {
// CHECK-LABEL:   function.def @complicated(
// CHECK-SAME:                              %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  88
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  77
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_0]], %[[VAL_4]])
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_5]] -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        scf.yield %[[VAL_7]], %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        scf.yield %[[VAL_1]], %[[VAL_2]], %[[VAL_3]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_6]]#0, %[[VAL_6]]#1 : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_6]]#2 : !felt.type, !felt.type
// CHECK-NEXT:      function.return %[[VAL_11]] : !felt.type
// CHECK-NEXT:    }
//
// CHECK-LABEL:   struct.def @C<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@C<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @complicated(%[[VAL_0]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@C<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@C<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@C<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@out] : <@C<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
