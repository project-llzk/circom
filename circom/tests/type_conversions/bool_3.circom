// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(x) {
  signal input in;
  signal output out;

  var z = 0;
  if (in || x) {
    z = 1;
  }
  out <-- z;
}

component main = A(99);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@x]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[@x]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@x]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_0]], %[[VAL_4]])
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_2]], %[[VAL_6]])
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_5]], %[[VAL_7]] : i1, i1
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_8]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          scf.yield %[[VAL_10]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_3]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_9]] : <@A<[@x]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[@x]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@x]>>, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_12]], %[[VAL_15]])
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_13]], %[[VAL_17]])
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_16]], %[[VAL_18]] : i1, i1
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_19]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          scf.yield %[[VAL_21]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_14]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_11]][@out] : <@A<[@x]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
