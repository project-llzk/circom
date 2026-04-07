// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(n){
  var x; // default initialization to 0
  if (n < 0) {
    var y = 12;
    var x = 23;
  } else {
    var y = 67;
    var x = 74;
    var z = 73;
  }
  return x;
}

template C() {
  signal input in;
  signal output out;
  out <-- f(in);
}

component main = C();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@C<[]>>} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:       %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:       %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:       %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_0]], %[[VAL_2]])
// CHECK-NEXT:       scf.if %[[VAL_3]] {
// CHECK-NEXT:         %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:         %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  23
// CHECK-NEXT:       } else {
// CHECK-NEXT:         %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  67
// CHECK-NEXT:         %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  74
// CHECK-NEXT:         %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  73
// CHECK-NEXT:       }
// CHECK-NEXT:       %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:       function.return %[[VAL_9]] : !felt.type
// CHECK-NEXT:     }
//
// CHECK-LABEL:   struct.def @C<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@C<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_0]]) : (!felt.type) -> !felt.type
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
