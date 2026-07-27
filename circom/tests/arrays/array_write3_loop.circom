// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Foo() {
  signal input a;
  signal output b;

  b <== a;
}

template Array1() {
    signal output out[5];
    component foo[5];

    for (var i = 0; i < 5; i++) {
      foo[i] = Foo();
      foo[i].a <== i;
      out[i] <== foo[i].b;
    }
}

component main = Array1();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Array1::@Array1<[]>>} {
// CHECK-NEXT:    poly.template @Array1 {
// CHECK-NEXT:      struct.def @Array1 {
// CHECK-NEXT:        struct.member @out : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @foo : !array.type<5 x !struct.type<@Foo::@Foo<[]>>>
// CHECK-NEXT:        struct.member @foo$inputs : !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Array1::@Array1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Array1::@Array1<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]] to %[[VAL_4]] step %[[VAL_6]] {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_8]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_7]]] = %[[VAL_9]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_10]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_15]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_16]]) %[[VAL_13]], %[[VAL_14]] : !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_20]], @params = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_22]]] = %[[VAL_21]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_23]]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_24]][@a] = %[[VAL_18]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_25]]] = %[[VAL_24]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_26]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_28]]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@count] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_30]], %[[VAL_31]] : index
// CHECK-NEXT:            pod.write %[[VAL_27]][@count] = %[[VAL_32]] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_32]], %[[VAL_33]] : index
// CHECK-NEXT:            scf.if %[[VAL_34]] {
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@params] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = function.call @Foo::@Foo::@compute(%[[VAL_36]]) : (!felt.type<"bn128">) -> !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:              pod.write %[[VAL_27]][@comp] = %[[VAL_37]] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_2]]{{\[}}%[[VAL_38]]] = %[[VAL_27]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_39]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@comp] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@b] : <@Foo::@Foo<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_1]]{{\[}}%[[VAL_43]]] = %[[VAL_42]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_17]], %[[VAL_45]] : !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@foo$inputs] = %[[VAL_12]]#0 : <@Array1::@Array1<[]>>, !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !struct.type<@Foo::@Foo<[]>>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_48]] to %[[VAL_47]] step %[[VAL_49]] {
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_50]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@comp] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            array.write %[[VAL_46]]{{\[}}%[[VAL_50]]] = %[[VAL_52]] : <5 x !struct.type<@Foo::@Foo<[]>>>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@foo] = %[[VAL_46]] : <@Array1::@Array1<[]>>, !array.type<5 x !struct.type<@Foo::@Foo<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_1]] : <@Array1::@Array1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Array1::@Array1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !struct.type<@Array1::@Array1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@out] : <@Array1::@Array1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@foo] : <@Array1::@Array1<[]>>, !array.type<5 x !struct.type<@Foo::@Foo<[]>>>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@foo$inputs] : <@Array1::@Array1<[]>>, !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_57]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_59]], %[[VAL_60]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_61]]) %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_65]]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_67]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_68]]] : <5 x !struct.type<@Foo::@Foo<[]>>>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@b] : <@Foo::@Foo<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_71]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_72]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_73]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_76]] to %[[VAL_75]] step %[[VAL_77]] {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_78]]] : <5 x !struct.type<@Foo::@Foo<[]>>>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_78]]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Foo::@Foo::@constrain(%[[VAL_79]], %[[VAL_81]]) : (!struct.type<@Foo::@Foo<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Foo {
// CHECK-NEXT:      struct.def @Foo {
// CHECK-NEXT:        struct.member @b : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_82:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) -> !struct.type<@Foo::@Foo<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo::@Foo<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_83]][@b] = %[[VAL_82]] : <@Foo::@Foo<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_83]] : !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_84:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[]>>, %[[VAL_85:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@b] : <@Foo::@Foo<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_86]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
