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
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_10]], %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!array.type<5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_15]], %[[VAL_16]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_17]]) %[[VAL_13]], %[[VAL_14]], %[[VAL_15]] : !array.type<5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_22]], @params = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_18]]{{\[}}%[[VAL_24]]] = %[[VAL_23]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_25]]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_26]][@a] = %[[VAL_20]] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_27]]] = %[[VAL_26]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_28]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_30]]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@count] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_32]], %[[VAL_33]] : index
// CHECK-NEXT:            pod.write %[[VAL_29]][@count] = %[[VAL_34]] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_34]], %[[VAL_35]] : index
// CHECK-NEXT:            scf.if %[[VAL_36]] {
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@params] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @Foo::@Foo::@compute(%[[VAL_38]]) : (!felt.type<"bn128">) -> !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:              pod.write %[[VAL_29]][@comp] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_18]]{{\[}}%[[VAL_40]]] = %[[VAL_29]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_41]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@comp] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@b] : <@Foo::@Foo<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_1]]{{\[}}%[[VAL_45]]] = %[[VAL_44]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_18]], %[[VAL_19]], %[[VAL_47]] : !array.type<5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@foo$inputs] = %[[VAL_12]]#1 : <@Array1::@Array1<[]>>, !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !struct.type<@Foo::@Foo<[]>>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_50]] to %[[VAL_49]] step %[[VAL_51]] {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]#0{{\[}}%[[VAL_52]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@comp] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            array.write %[[VAL_48]]{{\[}}%[[VAL_52]]] = %[[VAL_54]] : <5 x !struct.type<@Foo::@Foo<[]>>>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@foo] = %[[VAL_48]] : <@Array1::@Array1<[]>>, !array.type<5 x !struct.type<@Foo::@Foo<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_1]] : <@Array1::@Array1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Array1::@Array1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_55:[0-9a-zA-Z_\.]+]]: !struct.type<@Array1::@Array1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_55]][@out] : <@Array1::@Array1<[]>>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_55]][@foo] : <@Array1::@Array1<[]>>, !array.type<5 x !struct.type<@Foo::@Foo<[]>>>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_55]][@foo$inputs] : <@Array1::@Array1<[]>>, !array.type<5 x !pod.type<[@a: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_59]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_61]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_63]]) %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_67]]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_69]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_70]]] : <5 x !struct.type<@Foo::@Foo<[]>>>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@b] : <@Foo::@Foo<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_73]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_74]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_64]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_78]] to %[[VAL_77]] step %[[VAL_79]] {
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_80]]] : <5 x !struct.type<@Foo::@Foo<[]>>>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_80]]] : <5 x !pod.type<[@a: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@a] : <[@a: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Foo::@Foo::@constrain(%[[VAL_81]], %[[VAL_83]]) : (!struct.type<@Foo::@Foo<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Foo {
// CHECK-NEXT:      struct.def @Foo {
// CHECK-NEXT:        struct.member @b : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) -> !struct.type<@Foo::@Foo<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo::@Foo<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_85]][@b] = %[[VAL_84]] : <@Foo::@Foo<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_85]] : !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[]>>, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_86]][@b] : <@Foo::@Foo<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_88]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
