// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Simple5() {
  signal input a;
  signal input b;
  signal input c;

  signal output x;
  signal output y;
  signal output z;

  x <== a;
  y <-- b;
  y === b;
}

component main = Simple5();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Simple5::@Simple5<[]>>} {
// CHECK-NEXT:    poly.template @Simple5 {
// CHECK-NEXT:      struct.def @Simple5 {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @z : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Simple5::@Simple5<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@Simple5::@Simple5<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_3]][@x] = %[[VAL_0]] : <@Simple5::@Simple5<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@y] = %[[VAL_1]] : <@Simple5::@Simple5<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@Simple5::@Simple5<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Simple5::@Simple5<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@x] : <@Simple5::@Simple5<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@y] : <@Simple5::@Simple5<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@z] : <@Simple5::@Simple5<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_8]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_9]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
