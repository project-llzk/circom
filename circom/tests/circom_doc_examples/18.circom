// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

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
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_5]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_9]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[@n]> {
// CHECK-NEXT:      struct.field @out : !felt.type
// CHECK-NEXT:      struct.field @temp_a : !struct.type<@A<[@n]>>
// CHECK-NEXT:      struct.field @temp_a$inputs : !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:      function.def @compute(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[@n]>>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_14]] }  : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_18]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        pod.write %[[VAL_16]][@a] = %[[VAL_19]] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@count] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_20]], %[[VAL_21]] : index
// CHECK-NEXT:        pod.write %[[VAL_15]][@count] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:        scf.if %[[VAL_24]] {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_25]], %[[VAL_26]]) : (!felt.type, !felt.type) -> !struct.type<@A<[@n]>>
// CHECK-NEXT:          pod.write %[[VAL_15]][@comp] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]]
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_29]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        pod.write %[[VAL_16]][@b] = %[[VAL_30]] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@count] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_31]], %[[VAL_32]] : index
// CHECK-NEXT:        pod.write %[[VAL_15]][@count] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:        scf.if %[[VAL_35]] {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_36]], %[[VAL_37]]) : (!felt.type, !felt.type) -> !struct.type<@A<[@n]>>
// CHECK-NEXT:          pod.write %[[VAL_15]][@comp] = %[[VAL_38]] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@comp] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_39]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_12]][@out] = %[[VAL_40]] : <@B<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_12]][@temp_a$inputs] = %[[VAL_16]] : <@B<[@n]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@comp] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        struct.writef %[[VAL_12]][@temp_a] = %[[VAL_41]] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        function.return %[[VAL_12]] : !struct.type<@B<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_42:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[@n]>>, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_42]][@out] : <@B<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_42]][@temp_a] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_42]][@temp_a$inputs] : <@B<[@n]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]]
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_49]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_51]], %[[VAL_50]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]]
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_53]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_55]], %[[VAL_54]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_46]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_45]], %[[VAL_56]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @A::@constrain(%[[VAL_46]], %[[VAL_57]], %[[VAL_58]]) : (!struct.type<@A<[@n]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
