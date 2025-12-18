// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template C() {
  signal input in;
  signal output out;
  out <-- negative(in);
}

function negative(n){
  if (n < 0) {
    return 1;
  } else {
    return 0;
  }
}

component main = C();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @negative(
// CHECK-SAME:                           %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_0]], %[[VAL_1]])
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!felt.type) {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        scf.yield %[[VAL_4]] : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        scf.yield %[[VAL_5]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_3]] : !felt.type
// CHECK-NEXT:    }
//
// CHECK-LABEL:   struct.def @C<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@C<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@C<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @negative(%[[VAL_0]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_2]] : <@C<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@C<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@C<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_3]][@out] : <@C<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
