// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@B<[3]>>, veridise.lang = "llzk"} {
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
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_9]][@b] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_9]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_9]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_10]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_12]], %[[VAL_15]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_16]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_13]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_10]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_14]], %[[VAL_20]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[@n]> {
// CHECK-NEXT:      struct.field @out1 : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @[[ANON:[0-9a-zA-Z_\.]+]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      struct.field @[[ANON]]$inputs : !pod.type<[@a: !felt.type]>
// CHECK-NEXT:      function.def @compute(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[@n]>>
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_24]] }  : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type]>
// CHECK-NEXT:        pod.write %[[VAL_26]][@a] = %[[VAL_21]] : <[@a: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@count] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:        pod.write %[[VAL_25]][@count] = %[[VAL_29]] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_29]], %[[VAL_30]] : index
// CHECK-NEXT:        scf.if %[[VAL_31]] {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@a] : <[@a: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_32]]) : (!felt.type) -> !struct.type<@A<[@n]>>
// CHECK-NEXT:          pod.write %[[VAL_25]][@comp] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@comp] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_34]][@b] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@comp] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_36]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_22]][@out1] = %[[VAL_37]] : <@B<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@comp] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_38]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_22]][@[[ANON]]$inputs] = %[[VAL_26]] : <@B<[@n]>>, !pod.type<[@a: !felt.type]>
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@comp] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        struct.writef %[[VAL_22]][@[[ANON]]] = %[[VAL_40]] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        function.return %[[VAL_22]] : !struct.type<@B<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[@n]>>, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_41]][@out1] : <@B<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_41]][@[[ANON]]] : <@B<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_41]][@[[ANON]]$inputs] : <@B<[@n]>>, !pod.type<[@a: !felt.type]>
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@a: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_47]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_45]][@b] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_45]][@c] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_44]], %[[VAL_49]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_45]][@d] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@a: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @A::@constrain(%[[VAL_45]], %[[VAL_51]]) : (!struct.type<@A<[@n]>>, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
