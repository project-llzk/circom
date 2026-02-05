// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

template A(n){
   signal input a, b, c;
   signal output d;
   d <== a*b+c;
   a * b === c;
}
template B(n){
   signal input in[n];
   _ <== A(n)(in[0],in[1],in[2]);
}
component main = B(3);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@B<[3]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      struct.field @d : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_5]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_3]][@d] = %[[VAL_6]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_7]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_14]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_15]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[@n]> {
// CHECK-NEXT:      struct.field @[[TEMP:[0-9a-zA-Z_\.]+]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[@n]>>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_20]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_23]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_26]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_21]], %[[VAL_24]], %[[VAL_27]]) : (!felt.type, !felt.type, !felt.type) -> !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_28]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_17]][@[[TEMP]]] = %[[VAL_28]] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        function.return %[[VAL_17]] : !struct.type<@B<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[@n]>>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_30]][@[[TEMP]]] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]]
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_35]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]]
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_38]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]]
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_41]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        function.call @A::@constrain(%[[VAL_33]], %[[VAL_36]], %[[VAL_39]], %[[VAL_42]]) : (!struct.type<@A<[@n]>>, !felt.type, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_33]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
