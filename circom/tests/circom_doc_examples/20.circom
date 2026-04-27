// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template A(n){
   signal input a, b;
   signal output c;
   c <== a*b;
}
template B(n){
   signal input in[n];
   signal out <== A(n)(b <== in[1], a <== in[0]);
}
component main = B(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@B::@B<[2]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @c : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_4]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_5]][@c] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_7]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @A_14_363 : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        struct.member @A_14_363$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@B::@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_15]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_17]], @params = %[[VAL_16]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_20]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_14]][@a] = %[[VAL_21]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:          pod.write %[[VAL_18]][@count] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_24]], %[[VAL_25]] : index
// CHECK-NEXT:          scf.if %[[VAL_26]] {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_28]], %[[VAL_29]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_18]][@comp] = %[[VAL_30]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_32]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_14]][@b] = %[[VAL_33]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_34]], %[[VAL_35]] : index
// CHECK-NEXT:          pod.write %[[VAL_18]][@count] = %[[VAL_36]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_36]], %[[VAL_37]] : index
// CHECK-NEXT:          scf.if %[[VAL_38]] {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_40]], %[[VAL_41]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_18]][@comp] = %[[VAL_42]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@c] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_12]][@out] = %[[VAL_44]] : <@B::@B<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_12]][@A_14_363$inputs] = %[[VAL_14]] : <@B::@B<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_12]][@A_14_363] = %[[VAL_45]] : <@B::@B<[@n]>>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_12]] : !struct.type<@B::@B<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_46:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n]>>, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_46]][@out] : <@B::@B<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_46]][@A_14_363] : <@B::@B<[@n]>>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_46]][@A_14_363$inputs] : <@B::@B<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_52]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_54]], @params = %[[VAL_53]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_57]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_59]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_61]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_63]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@c] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_49]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @A::@A::@constrain(%[[VAL_50]], %[[VAL_65]], %[[VAL_66]]) : (!struct.type<@A::@A<[@n]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
