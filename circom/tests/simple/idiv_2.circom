// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
    signal output c <== n \ 4;
}

component main = A(12);

// COM: TODO: This output will change once 'uintdiv' op is available in LLZK.
//
// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      struct.field @c : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A<[@n]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toint %[[VAL_1]] : i254
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toint %[[VAL_2]] : i254
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.divui %[[VAL_3]], %[[VAL_4]] : i254
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_5]] : i254
// CHECK-NEXT:        struct.writef %[[VAL_0]][@c] = %[[VAL_6]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toint %[[VAL_8]] : i254
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toint %[[VAL_9]] : i254
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.divui %[[VAL_10]], %[[VAL_11]] : i254
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_12]] : i254
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_7]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_14]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
