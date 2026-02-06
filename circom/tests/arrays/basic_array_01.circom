// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
  signal input a[n];
  signal output b[n];

  for (var i = 0; i < n; i++) {
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Array01<[5]>>} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      struct.member @b : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_9]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_11]]] = %[[VAL_10]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@b] = %[[VAL_3]] : <@A<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@b] : <@A<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_16]])
// CHECK-NEXT:          scf.condition(%[[VAL_21]]) %[[VAL_20]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_23]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_25]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_26]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_28]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Array01<[@n]> {
// CHECK-NEXT:      struct.member @b : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      struct.member @a_cmp : !struct.type<@A<[@n]>>
// CHECK-NEXT:      struct.member @a_cmp$inputs : !pod.type<[@a: !array.type<@n x !felt.type>]>
// CHECK-NEXT:      function.def @compute(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Array01<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.new : <@Array01<[@n]>>
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]]
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_33]] }  : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !array.type<@n x !felt.type>]>
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_35]], %[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_36]]) : (!pod.type<[@a: !array.type<@n x !felt.type>]>, !felt.type) -> (!pod.type<[@a: !array.type<@n x !felt.type>]>, !felt.type) {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_39]], %[[VAL_31]])
// CHECK-NEXT:          scf.condition(%[[VAL_40]]) %[[VAL_38]], %[[VAL_39]] : !pod.type<[@a: !array.type<@n x !felt.type>]>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<@n x !felt.type>]>, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]]
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_43]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]]
// CHECK-NEXT:          array.write %[[VAL_45]]{{\[}}%[[VAL_46]]] = %[[VAL_44]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_41]][@a] = %[[VAL_45]] : <[@a: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_47]], %[[VAL_48]] : index
// CHECK-NEXT:          pod.write %[[VAL_34]][@count] = %[[VAL_49]] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_49]], %[[VAL_50]] : index
// CHECK-NEXT:          scf.if %[[VAL_51]] {
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_52]]) : (!array.type<@n x !felt.type>) -> !struct.type<@A<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_34]][@comp] = %[[VAL_53]] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_54]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_41]], %[[VAL_55]] : !pod.type<[@a: !array.type<@n x !felt.type>]>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_56]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_58]], %[[VAL_31]])
// CHECK-NEXT:          scf.condition(%[[VAL_59]]) %[[VAL_58]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@comp] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@b] : <@A<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]]
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_63]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]]
// CHECK-NEXT:          array.write %[[VAL_32]]{{\[}}%[[VAL_65]]] = %[[VAL_64]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_60]], %[[VAL_66]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_67]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_30]][@a_cmp$inputs] = %[[VAL_37]]#0 : <@Array01<[@n]>>, !pod.type<[@a: !array.type<@n x !felt.type>]>
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@comp] : <[@count: index, @comp: !struct.type<@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        struct.writem %[[VAL_30]][@a_cmp] = %[[VAL_68]] : <@Array01<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        struct.writem %[[VAL_30]][@b] = %[[VAL_32]] : <@Array01<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_30]] : !struct.type<@Array01<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !struct.type<@Array01<[@n]>>, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@b] : <@Array01<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@a_cmp] : <@Array01<[@n]>>, !struct.type<@A<[@n]>>
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@a_cmp$inputs] : <@Array01<[@n]>>, !pod.type<[@a: !array.type<@n x !felt.type>]>
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_76:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_75]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_77]], %[[VAL_71]])
// CHECK-NEXT:          scf.condition(%[[VAL_78]]) %[[VAL_77]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]]
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_80]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@a] : <[@a: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]]
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_83]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_84]], %[[VAL_81]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_79]], %[[VAL_85]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_86]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_88:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_89:[0-9a-zA-Z_\.]+]] = %[[VAL_87]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_89]], %[[VAL_71]])
// CHECK-NEXT:          scf.condition(%[[VAL_90]]) %[[VAL_89]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_91:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@b] : <@A<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]]
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_92]]{{\[}}%[[VAL_93]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]]
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_95]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_96]], %[[VAL_94]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_91]], %[[VAL_97]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_98]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@a] : <[@a: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:        function.call @A::@constrain(%[[VAL_73]], %[[VAL_99]]) : (!struct.type<@A<[@n]>>, !array.type<@n x !felt.type>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
