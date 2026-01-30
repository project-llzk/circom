// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template A(n){
   signal input a;
   signal output b, c, d;
   b <== a * a;
   c <== a + 2;
   d <== a * a + 2;
}
template B(n){
   signal input in;
   signal output out1;
   (_,out1,_) <== A(n)(in);
}
component main = B(3);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      struct.field @b : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @c : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @d : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@b] = %[[VAL_3]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@c] = %[[VAL_5]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_6]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@d] = %[[VAL_8]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_9]][@b] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_9]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_9]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_10]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_13]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_14]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_16]], %[[VAL_15]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_10]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_20]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[@n]> {
// CHECK-NEXT:      struct.field @out1 : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @[[TEMP:[0-9a-zA-Z_\.]+]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[@n]>>
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_21]]) : (!felt.type) -> !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_24]][@b] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_24]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_22]][@out1] = %[[VAL_26]] : <@B<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_24]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_22]][@[[TEMP]]] = %[[VAL_24]] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        function.return %[[VAL_22]] : !struct.type<@B<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[@n]>>, %[[VAL_29:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_28]][@out1] : <@B<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_28]][@[[TEMP]]] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        function.call @A::@constrain(%[[VAL_31]], %[[VAL_29]]) : (!struct.type<@A<[@n]>>, !felt.type) -> ()
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_31]][@b] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_31]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_34]], %[[VAL_33]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_31]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
