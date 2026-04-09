// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
  signal input in1;
  signal input in2;
  signal output out;

  var x;
  if (in1 > 0) {
    x = in1;
  } else {
    x = in2;
  }
  out <-- x;
}

component main = B();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@B<[]>>} {
// CHECK-LABEL:   struct.def @B<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_0]], %[[VAL_4]])
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_5]] -> (!felt.type) {
// CHECK-NEXT:          scf.yield %[[VAL_0]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_1]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_2]][@out] = %[[VAL_6]] : <@B<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %{{[0-9a-zA-Z_\.]+}} = struct.readm %[[VAL_7]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_8]], %[[VAL_11]])
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_12]] -> (!felt.type) {
// CHECK-NEXT:          scf.yield %[[VAL_8]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_9]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
