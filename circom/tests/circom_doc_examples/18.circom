// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@B<[2]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @c : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_5]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_9]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_6]][@c] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {signal}
// CHECK-NEXT:        struct.member @temp_a : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        struct.member @temp_a$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@B::@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_15]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_18]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_20]], @params = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_23]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_17]][@a] = %[[VAL_24]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_25]], %[[VAL_26]] : index
// CHECK-NEXT:          pod.write %[[VAL_21]][@count] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:          scf.if %[[VAL_29]] {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_31]], %[[VAL_32]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_21]][@comp] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_35]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_17]][@b] = %[[VAL_36]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:          pod.write %[[VAL_21]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:          scf.if %[[VAL_41]] {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_43]], %[[VAL_44]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_21]][@comp] = %[[VAL_45]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_46]][@c] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_14]][@out] = %[[VAL_47]] : <@B::@B<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_14]][@temp_a$inputs] = %[[VAL_17]] : <@B::@B<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_14]][@temp_a] = %[[VAL_48]] : <@B::@B<[@n]>>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_14]] : !struct.type<@B::@B<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n]>>, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_51]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@out] : <@B::@B<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@temp_a] : <@B::@B<[@n]>>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@temp_a$inputs] : <@B::@B<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_56]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_60]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_62]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_64]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_66]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_54]][@c] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @A::@A::@constrain(%[[VAL_54]], %[[VAL_68]], %[[VAL_69]]) : (!struct.type<@A::@A<[@n]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
