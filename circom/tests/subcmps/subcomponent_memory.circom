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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @b : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[@x: !felt.type<"bn128">, @y: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:        struct.member @c : !array.type<2,1 x !struct.type<@C::@C<[]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<2,1 x !pod.type<[@f: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_2]], @params = %[[VAL_1]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@x: !felt.type<"bn128">, @y: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_9]] to %[[VAL_7]] step %[[VAL_10]] {
// CHECK-NEXT:            scf.for %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_9]] to %[[VAL_8]] step %[[VAL_10]] {
// CHECK-NEXT:              %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_13]], @params = %[[VAL_6]] }  : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              array.write %[[VAL_5]]{{\[}}%[[VAL_11]], %[[VAL_12]]] = %[[VAL_14]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !pod.type<[@f: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_5]]{{\[}}%[[VAL_23]], %[[VAL_25]]] = %[[VAL_21]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_5]]{{\[}}%[[VAL_30]], %[[VAL_32]]] = %[[VAL_28]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@b$inputs] = %[[VAL_4]] : <@A::@A<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@b] = %[[VAL_33]] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@c$inputs] = %[[VAL_15]] : <@A::@A<[]>>, !array.type<2,1 x !pod.type<[@f: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !struct.type<@C::@C<[]>>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_37]] to %[[VAL_35]] step %[[VAL_38]] {
// CHECK-NEXT:            scf.for %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_37]] to %[[VAL_36]] step %[[VAL_38]] {
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_39]], %[[VAL_40]]] : <2,1 x !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:              array.write %[[VAL_34]]{{\[}}%[[VAL_39]], %[[VAL_40]]] = %[[VAL_42]] : <2,1 x !struct.type<@C::@C<[]>>>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@c] = %[[VAL_34]] : <@A::@A<[]>>, !array.type<2,1 x !struct.type<@C::@C<[]>>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@b] : <@A::@A<[]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@b$inputs] : <@A::@A<[]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@c] : <@A::@A<[]>>, !array.type<2,1 x !struct.type<@C::@C<[]>>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@c$inputs] : <@A::@A<[]>>, !array.type<2,1 x !pod.type<[@f: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@C::@C<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@x] : <[@x: !felt.type<"bn128">, @y: !array.type<10 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@y] : <[@x: !felt.type<"bn128">, @y: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_44]], %[[VAL_54]], %[[VAL_55]]) : (!struct.type<@B::@B<[]>>, !felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_56]] step %[[VAL_59]] {
// CHECK-NEXT:            scf.for %[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_57]] step %[[VAL_59]] {
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_60]], %[[VAL_61]]] : <2,1 x !struct.type<@C::@C<[]>>>, !struct.type<@C::@C<[]>>
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_60]], %[[VAL_61]]] : <2,1 x !pod.type<[@f: !felt.type<"bn128">]>>, !pod.type<[@f: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@f] : <[@f: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              function.call @C::@C::@constrain(%[[VAL_62]], %[[VAL_64]]) : (!struct.type<@C::@C<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        function.def @compute(%[[VAL_65:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_66:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">>) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          function.return %[[VAL_67]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C {
// CHECK-NEXT:      struct.def @C {
// CHECK-NEXT:        function.def @compute(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@C::@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[]>>
// CHECK-NEXT:          function.return %[[VAL_72]] : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[]>>, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
