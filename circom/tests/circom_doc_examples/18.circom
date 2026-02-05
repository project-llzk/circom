// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A(n){
   signal input a, b;
   signal output c;
   c <== a*b;
}
template B(n){
   signal input in[n];
   signal out;
   component temp_a = A(n);
   temp_a.a <== in[0];
   temp_a.b <== in[1];
   out <== temp_a.c;
}
component main = B(2);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@B<[2]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      struct.field @c : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@c] = %[[VAL_4]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_5]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_10]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[@n]> {
// CHECK-NEXT:      struct.field @out : !felt.type
// CHECK-NEXT:      struct.field @temp_a : !struct.type<@A<[@n]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[@n]>>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]]
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_15]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_18]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_16]], %[[VAL_19]]) : (!felt.type, !felt.type) -> !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_20]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_12]][@out] = %[[VAL_21]] : <@B<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_12]][@temp_a] = %[[VAL_20]] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        function.return %[[VAL_12]] : !struct.type<@B<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[@n]>>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_22]][@out] : <@B<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_22]][@temp_a] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]]
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_23]]{{\[}}%[[VAL_27]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]]
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_23]]{{\[}}%[[VAL_30]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        function.call @A::@constrain(%[[VAL_25]], %[[VAL_28]], %[[VAL_31]]) : (!struct.type<@A<[@n]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_25]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_33]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
