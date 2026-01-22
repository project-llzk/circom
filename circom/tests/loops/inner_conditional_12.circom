// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// This test contains inner loops with different iteration counts. Further, one is
//  independent of the outer loop induction variable and the other loop depends on it.
template InnerConditional12(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        if (i < 2) {
            // runs when i∈{0,1}
            for (var j = 0; j < N; j++) {
                a[i] += 999;
            }
        } else {
            // runs when i∈{2,3}
            for (var j = 0; j < i; j++) {
                a[i] += 888;
            }
        }
    }
    out <-- a[0] + a[1];
}

component main = InnerConditional12(4);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @InnerConditional12<[@N]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@InnerConditional12<[@N]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional12<[@N]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_3]], %[[VAL_4]] : <@N x !felt.type>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_5]] step %[[VAL_7]] {
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_8]]] = %[[VAL_2]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_1]])
// CHECK-NEXT:          scf.condition(%[[VAL_13]]) %[[VAL_11]], %[[VAL_12]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_15]], %[[VAL_16]])
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_17]] -> (!array.type<@N x !felt.type>) {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_1]])
// CHECK-NEXT:              scf.condition(%[[VAL_23]]) %[[VAL_21]], %[[VAL_22]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_26]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_28]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:              array.write %[[VAL_24]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_24]], %[[VAL_32]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_20]]#0 : !array.type<@N x !felt.type>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_36]], %[[VAL_15]])
// CHECK-NEXT:              scf.condition(%[[VAL_37]]) %[[VAL_35]], %[[VAL_36]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_40]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  888
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:              array.write %[[VAL_38]]{{\[}}%[[VAL_44]]] = %[[VAL_43]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_45]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_38]], %[[VAL_46]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_34]]#0 : !array.type<@N x !felt.type>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_47]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_18]], %[[VAL_48]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]]
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]#0{{\[}}%[[VAL_50]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]]
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]#0{{\[}}%[[VAL_53]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_54]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_0]][@out] = %[[VAL_55]] : <@InnerConditional12<[@N]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@InnerConditional12<[@N]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional12<[@N]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type>
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_59]], %[[VAL_60]] : <@N x !felt.type>
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_64:[0-9a-zA-Z_\.]+]] = %[[VAL_62]] to %[[VAL_61]] step %[[VAL_63]] {
// CHECK-NEXT:          array.write %[[VAL_59]]{{\[}}%[[VAL_64]]] = %[[VAL_58]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_59]], %[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_65]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_68]], %[[VAL_57]])
// CHECK-NEXT:          scf.condition(%[[VAL_69]]) %[[VAL_67]], %[[VAL_68]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_70:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_71:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_71]], %[[VAL_72]])
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_73]] -> (!array.type<@N x !felt.type>) {
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_70]], %[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_75]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_78]], %[[VAL_57]])
// CHECK-NEXT:              scf.condition(%[[VAL_79]]) %[[VAL_77]], %[[VAL_78]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]]
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_82]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_84]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]]
// CHECK-NEXT:              array.write %[[VAL_80]]{{\[}}%[[VAL_86]]] = %[[VAL_85]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_81]], %[[VAL_87]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_80]], %[[VAL_88]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_76]]#0 : !array.type<@N x !felt.type>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_91:[0-9a-zA-Z_\.]+]] = %[[VAL_70]], %[[VAL_92:[0-9a-zA-Z_\.]+]] = %[[VAL_89]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_92]], %[[VAL_71]])
// CHECK-NEXT:              scf.condition(%[[VAL_93]]) %[[VAL_91]], %[[VAL_92]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_94:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_95:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]]
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_96]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  888
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_98]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]]
// CHECK-NEXT:              array.write %[[VAL_94]]{{\[}}%[[VAL_100]]] = %[[VAL_99]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_95]], %[[VAL_101]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_94]], %[[VAL_102]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_90]]#0 : !array.type<@N x !felt.type>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_71]], %[[VAL_103]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_74]], %[[VAL_104]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_56]][@out] : <@InnerConditional12<[@N]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
