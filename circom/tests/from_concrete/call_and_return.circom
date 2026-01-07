// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk=concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template C() {
  signal input in;
  signal output out;
  var x = 12;
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
// CHECK-NEXT:    function.def @negative_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type {
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
// CHECK-NEXT:    struct.def @C<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@C<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@C<[]>>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = function.call @negative_0(%[[VAL_6]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_7]][@out] = %[[VAL_9]] : <@C<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_7]] : !struct.type<@C<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@C<[]>>, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_10]][@out] : <@C<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
