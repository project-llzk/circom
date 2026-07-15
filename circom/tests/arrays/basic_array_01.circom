// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(m) {
  signal input a[m];
  signal output b[m];

  for (var i = 0; i < m; i++) {
    b[i] <== a[i];
  }
}

template Array01(n) {
    signal input a[n];
    signal output b[n];

    component a_cmp = A(n);

    for (var i = 0; i < n; i++) {
      a_cmp.a[i] <== a[i];
    }

    for (var i = 0; i < n; i++) {
      a_cmp.b[i] ==> b[i];
    }
}

component main = Array01(5);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Array01::@Array01<[5]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @m : index
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @b : !array.type<@m x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@m x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[@m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@m]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_12]]] = %[[VAL_11]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_4]] : <@A::@A<[@m]>>, !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@m]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<@m x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_17]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@b] : <@A::@A<[@m]>>, !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_18]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_23]]) %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_25]]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_27]]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_28]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Array01 {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Array01 {
// CHECK-NEXT:        struct.member @b : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a_cmp : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        struct.member @a_cmp$inputs : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@Array01::@Array01<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.new : <@Array01::@Array01<[@n]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_33]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_37]] }  : <[@m: index]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_39]], @params = %[[VAL_38]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@m: index]>]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_36]], %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_41]]) : (!pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_44]], %[[VAL_34]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_45]]) %[[VAL_43]], %[[VAL_44]] : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_46:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_48]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_50]]{{\[}}%[[VAL_51]]] = %[[VAL_49]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_46]][@a] = %[[VAL_50]] : <[@a: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_52]], %[[VAL_53]] : index
// CHECK-NEXT:            pod.write %[[VAL_40]][@count] = %[[VAL_54]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_54]], %[[VAL_55]] : index
// CHECK-NEXT:            scf.if %[[VAL_56]] {
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@m: index]>]>, !pod.type<[@m: index]>
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_58]]) : (!array.type<@n x !felt.type<"bn128">>) -> !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:              pod.write %[[VAL_40]][@comp] = %[[VAL_59]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_47]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_46]], %[[VAL_61]] : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_64:[0-9a-zA-Z_\.]+]] = %[[VAL_62]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_64]], %[[VAL_34]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_65]]) %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_67]][@b] : <@A::@A<[@n]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_68]]{{\[}}%[[VAL_69]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_35]]{{\[}}%[[VAL_71]]] = %[[VAL_70]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_66]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_32]][@a_cmp$inputs] = %[[VAL_42]]#0 : <@Array01::@Array01<[@n]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_32]][@a_cmp] = %[[VAL_74]] : <@Array01::@Array01<[@n]>>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_32]][@b] = %[[VAL_35]] : <@Array01::@Array01<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_32]] : !struct.type<@Array01::@Array01<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_75:[0-9a-zA-Z_\.]+]]: !struct.type<@Array01::@Array01<[@n]>>, %[[VAL_76:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_77]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@b] : <@Array01::@Array01<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@a_cmp] : <@Array01::@Array01<[@n]>>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@a_cmp$inputs] : <@Array01::@Array01<[@n]>>, !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_82]] }  : <[@m: index]>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@m: index]>]>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_87:[0-9a-zA-Z_\.]+]] = %[[VAL_85]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_87]], %[[VAL_78]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_88]]) %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_89:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_90]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_92]]{{\[}}%[[VAL_93]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_94]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_89]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_96]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_99:[0-9a-zA-Z_\.]+]] = %[[VAL_97]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_99]], %[[VAL_78]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_100]]) %[[VAL_99]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_101:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@b] : <@A::@A<[@n]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_103]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_105]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_106]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_101]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@a] : <[@a: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @A::@A::@constrain(%[[VAL_80]], %[[VAL_109]]) : (!struct.type<@A::@A<[@n]>>, !array.type<@n x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
