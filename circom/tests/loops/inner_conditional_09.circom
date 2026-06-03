// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional9(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        // Values of 'a' at the header per iteration:
        // i=0: [0, 0, 0, 0]
        // i=1: [3996, 0, 0, 0]
        // i=2: [3996, 3996, 0, 0]
        // i=3: [3996, 3996, 3552, 0]
        if (i < 2) {
            // runs when i∈{0,1}
            for (var j = 0; j < N; j++) {
                a[i] += 999;
            }
        } else {
            // runs when i∈{2,3}
            for (var j = 0; j < N; j++) {
                a[i] += 888;
            }
        }
    }
    // At this point, 'a = [3996, 3996, 3552, 3552]', so 'out = 7992'
    out <-- a[0] + a[1];
}

component main = InnerConditional9(4);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@InnerConditional9::@InnerConditional9<[4]>>} {
// CHECK-NEXT:    poly.template @InnerConditional9 {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @InnerConditional9 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional9::@InnerConditional9<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional9::@InnerConditional9<[@N]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_3]], %[[VAL_4]] : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_5]] step %[[VAL_7]] {
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_8]]] = %[[VAL_2]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_13]]) %[[VAL_11]], %[[VAL_12]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_15]], %[[VAL_16]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_17]] -> (!array.type<@N x !felt.type<"bn128">>) {
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_23]]) %[[VAL_21]], %[[VAL_22]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_26]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:                %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_24]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:                %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_24]], %[[VAL_32]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_20]]#0 : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_36]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_37]]) %[[VAL_35]], %[[VAL_36]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_40]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  888
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_38]]{{\[}}%[[VAL_44]]] = %[[VAL_43]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:                %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_38]], %[[VAL_46]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_34]]#0 : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_18]], %[[VAL_48]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]#0{{\[}}%[[VAL_50]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]#0{{\[}}%[[VAL_53]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_54]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_55]] : <@InnerConditional9::@InnerConditional9<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@InnerConditional9::@InnerConditional9<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional9::@InnerConditional9<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out] : <@InnerConditional9::@InnerConditional9<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_60]], %[[VAL_61]] : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_63]] to %[[VAL_62]] step %[[VAL_64]] {
// CHECK-NEXT:            array.write %[[VAL_60]]{{\[}}%[[VAL_65]]] = %[[VAL_59]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_60]], %[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_66]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_69]], %[[VAL_57]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_70]]) %[[VAL_68]], %[[VAL_69]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_72:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_72]], %[[VAL_73]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_74]] -> (!array.type<@N x !felt.type<"bn128">>) {
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_71]], %[[VAL_79:[0-9a-zA-Z_\.]+]] = %[[VAL_76]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_79]], %[[VAL_57]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_80]]) %[[VAL_78]], %[[VAL_79]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_83]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_81]]{{\[}}%[[VAL_87]]] = %[[VAL_86]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_82]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_81]], %[[VAL_89]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_77]]#0 : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_92:[0-9a-zA-Z_\.]+]] = %[[VAL_71]], %[[VAL_93:[0-9a-zA-Z_\.]+]] = %[[VAL_90]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_93]], %[[VAL_57]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_94]]) %[[VAL_92]], %[[VAL_93]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_95:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_96:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_97]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  888
// CHECK-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_98]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_95]]{{\[}}%[[VAL_101]]] = %[[VAL_100]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:                %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_96]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_95]], %[[VAL_103]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_91]]#0 : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_75]], %[[VAL_105]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
