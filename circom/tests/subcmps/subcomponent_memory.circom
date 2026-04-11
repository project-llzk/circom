// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
  signal input x;
  signal input y[10];
}

template C() {
  signal input f;
}

template A() {
  component b = B();
  component c[2][1];
  c[0][0] = C();
  c[1][0] = C();
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @b : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-NEXT:        struct.member @c : !array.type<2,1 x !struct.type<@C::@C<[]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_1]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]] to %[[VAL_5]] step %[[VAL_8]] {
// CHECK-NEXT:            scf.for %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_7]] to %[[VAL_6]] step %[[VAL_8]] {
// CHECK-NEXT:              %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_9]], %[[VAL_10]]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              pod.write %[[VAL_11]][@count] = %[[VAL_12]] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              array.write %[[VAL_4]]{{\[}}%[[VAL_9]], %[[VAL_10]]] = %[[VAL_11]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_14]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_17]], %[[VAL_19]]] = %[[VAL_15]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_20]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_23]], %[[VAL_25]]] = %[[VAL_21]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@b$inputs] = %[[VAL_3]] : <@A::@A<[]>>, !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@b] = %[[VAL_26]] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@c$inputs] = %[[VAL_13]] : <@A::@A<[]>>, !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !struct.type<@C::@C<[]>>>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_30]] to %[[VAL_28]] step %[[VAL_31]] {
// CHECK-NEXT:            scf.for %[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_30]] to %[[VAL_29]] step %[[VAL_31]] {
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_32]], %[[VAL_33]]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:              array.write %[[VAL_27]]{{\[}}%[[VAL_32]], %[[VAL_33]]] = %[[VAL_35]] : <2,1 x !struct.type<@C::@C<[]>>>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@c] = %[[VAL_27]] : <@A::@A<[]>>, !array.type<2,1 x !struct.type<@C::@C<[]>>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_36]][@b] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_36]][@b$inputs] : <@A::@A<[]>>, !pod.type<[@x: !felt.type, @y: !array.type<10 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_36]][@c] : <@A::@A<[]>>, !array.type<2,1 x !struct.type<@C::@C<[]>>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_36]][@c$inputs] : <@A::@A<[]>>, !array.type<2,1 x !pod.type<[@f: !felt.type]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_41]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_43]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@x] : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>, !felt.type
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@y] : <[@x: !felt.type, @y: !array.type<10 x !felt.type>]>, !array.type<10 x !felt.type>
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_37]], %[[VAL_45]], %[[VAL_46]]) : (!struct.type<@B::@B<[]>>, !felt.type, !array.type<10 x !felt.type>) -> ()
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_51:[0-9a-zA-Z_\.]+]] = %[[VAL_49]] to %[[VAL_47]] step %[[VAL_50]] {
// CHECK-NEXT:            scf.for %[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_49]] to %[[VAL_48]] step %[[VAL_50]] {
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_51]], %[[VAL_52]]] : <2,1 x !struct.type<@C::@C<[]>>>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_40]]{{\[}}%[[VAL_51]], %[[VAL_52]]] : <2,1 x !pod.type<[@f: !felt.type]>>, !pod.type<[@f: !felt.type]>
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@f] : <[@f: !felt.type]>, !felt.type
// CHECK-NEXT:              function.call @C::@C::@constrain(%[[VAL_53]], %[[VAL_55]]) : (!struct.type<@C::@C<[]>>, !felt.type) -> ()
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        function.def @compute(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          function.return %[[VAL_58]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C {
// CHECK-NEXT:      struct.def @C {
// CHECK-NEXT:        function.def @compute(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@C::@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[]>>
// CHECK-NEXT:          function.return %[[VAL_63]] : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[]>>, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
