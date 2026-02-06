// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Array1<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Array1<[]> {
// CHECK-NEXT:      struct.member @out : !array.type<5 x !felt.type> {llzk.pub}
// CHECK-NEXT:      struct.member @foo : !array.type<5 x !struct.type<@Foo<[]>>>
// CHECK-NEXT:      struct.member @foo$inputs : !array.type<5 x !pod.type<[@a: !felt.type]>>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Array1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Array1<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<5 x !felt.type>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:        scf.for %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_3]] to %[[VAL_5]] step %[[VAL_4]] {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_6]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          pod.write %[[VAL_7]][@count] = %[[VAL_8]] : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_6]]] = %[[VAL_7]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !pod.type<[@a: !felt.type]>>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_9]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!array.type<5 x !pod.type<[@a: !felt.type]>>, !felt.type) -> (!array.type<5 x !pod.type<[@a: !felt.type]>>, !felt.type) {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_14]])
// CHECK-NEXT:          scf.condition(%[[VAL_15]]) %[[VAL_12]], %[[VAL_13]] : !array.type<5 x !pod.type<[@a: !felt.type]>>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<5 x !pod.type<[@a: !felt.type]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]] }  : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_20]]] = %[[VAL_19]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_21]]] : <5 x !pod.type<[@a: !felt.type]>>, !pod.type<[@a: !felt.type]>
// CHECK-NEXT:          pod.write %[[VAL_22]][@a] = %[[VAL_17]] : <[@a: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:          array.write %[[VAL_16]]{{\[}}%[[VAL_23]]] = %[[VAL_22]] : <5 x !pod.type<[@a: !felt.type]>>, !pod.type<[@a: !felt.type]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_24]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@count] : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_26]], %[[VAL_27]] : index
// CHECK-NEXT:          pod.write %[[VAL_25]][@count] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_28]], %[[VAL_29]] : index
// CHECK-NEXT:          scf.if %[[VAL_30]] {
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@a] : <[@a: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = function.call @Foo::@compute(%[[VAL_31]]) : (!felt.type) -> !struct.type<@Foo<[]>>
// CHECK-NEXT:            pod.write %[[VAL_25]][@comp] = %[[VAL_32]] : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo<[]>>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_33]]] = %[[VAL_25]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_34]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@comp] : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo<[]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_36]][@b] : <@Foo<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_38]]] = %[[VAL_37]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_39]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_16]], %[[VAL_40]] : !array.type<5 x !pod.type<[@a: !felt.type]>>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_0]][@foo$inputs] = %[[VAL_11]]#0 : <@Array1<[]>>, !array.type<5 x !pod.type<[@a: !felt.type]>>
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new  : <5 x !struct.type<@Foo<[]>>>
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:        scf.for %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_42]] to %[[VAL_44]] step %[[VAL_43]] {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_45]]] : <5 x !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@comp] : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo<[]>>
// CHECK-NEXT:          array.write %[[VAL_41]]{{\[}}%[[VAL_45]]] = %[[VAL_47]] : <5 x !struct.type<@Foo<[]>>>, !struct.type<@Foo<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_0]][@foo] = %[[VAL_41]] : <@Array1<[]>>, !array.type<5 x !struct.type<@Foo<[]>>>
// CHECK-NEXT:        struct.writem %[[VAL_0]][@out] = %[[VAL_1]] : <@Array1<[]>>, !array.type<5 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@Array1<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !struct.type<@Array1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@out] : <@Array1<[]>>, !array.type<5 x !felt.type>
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@foo] : <@Array1<[]>>, !array.type<5 x !struct.type<@Foo<[]>>>
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@foo$inputs] : <@Array1<[]>>, !array.type<5 x !pod.type<[@a: !felt.type]>>
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_54]], %[[VAL_55]])
// CHECK-NEXT:          scf.condition(%[[VAL_56]]) %[[VAL_54]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_57:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_58]] }  : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]]
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_51]]{{\[}}%[[VAL_60]]] : <5 x !pod.type<[@a: !felt.type]>>, !pod.type<[@a: !felt.type]>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@a] : <[@a: !felt.type]>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_62]], %[[VAL_57]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]]
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_63]]] : <5 x !struct.type<@Foo<[]>>>, !struct.type<@Foo<[]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@b] : <@Foo<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]]
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_49]]{{\[}}%[[VAL_66]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_67]], %[[VAL_65]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_57]], %[[VAL_68]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_69]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:        scf.for %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_70]] to %[[VAL_72]] step %[[VAL_71]] {
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_73]]] : <5 x !struct.type<@Foo<[]>>>, !struct.type<@Foo<[]>>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_51]]{{\[}}%[[VAL_73]]] : <5 x !pod.type<[@a: !felt.type]>>, !pod.type<[@a: !felt.type]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@a] : <[@a: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @Foo::@constrain(%[[VAL_74]], %[[VAL_76]]) : (!struct.type<@Foo<[]>>, !felt.type) -> ()
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Foo<[]> {
// CHECK-NEXT:      struct.member @b : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Foo<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_78]][@b] = %[[VAL_77]] : <@Foo<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_78]] : !struct.type<@Foo<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo<[]>>, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_79]][@b] : <@Foo<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_81]], %[[VAL_80]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
