// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @InnerConditional9<[@N]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@InnerConditional9<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional9<[@N]>>
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[V_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_3:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type>
// CHECK-NEXT:        %[[V_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_5:[0-9a-zA-Z_\.]+]] = array.len %[[V_3]], %[[V_4]] : <@N x !felt.type>
// CHECK-NEXT:        %[[V_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[V_8:[0-9a-zA-Z_\.]+]] = %[[V_6]] to %[[V_5]] step %[[V_7]] {
// CHECK-NEXT:          array.write %[[V_3]]{{\[}}%[[V_8]]] = %[[V_2]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_10:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_11:[0-9a-zA-Z_\.]+]] = %[[V_3]], %[[V_12:[0-9a-zA-Z_\.]+]] = %[[V_9]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_12]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_13]]) %[[V_11]], %[[V_12]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_14:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_15:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_16:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_17:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_15]], %[[V_16]])
// CHECK-NEXT:          %[[V_18:[0-9a-zA-Z_\.]+]] = scf.if %[[V_17]] -> (!array.type<@N x !felt.type>) {
// CHECK-NEXT:            %[[V_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_20:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_21:[0-9a-zA-Z_\.]+]] = %[[V_14]], %[[V_22:[0-9a-zA-Z_\.]+]] = %[[V_19]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[V_23:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_22]], %[[V_N]])
// CHECK-NEXT:              scf.condition(%[[V_23]]) %[[V_21]], %[[V_22]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_24:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_25:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[V_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_15]]
// CHECK-NEXT:              %[[V_27:[0-9a-zA-Z_\.]+]] = array.read %[[V_24]]{{\[}}%[[V_26]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[V_28:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:              %[[V_29:[0-9a-zA-Z_\.]+]] = felt.add %[[V_27]], %[[V_28]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[V_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_15]]
// CHECK-NEXT:              array.write %[[V_24]]{{\[}}%[[V_30]]] = %[[V_29]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[V_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_32:[0-9a-zA-Z_\.]+]] = felt.add %[[V_25]], %[[V_31]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[V_24]], %[[V_32]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[V_20]]#0 : !array.type<@N x !felt.type>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[V_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_34:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_35:[0-9a-zA-Z_\.]+]] = %[[V_14]], %[[V_36:[0-9a-zA-Z_\.]+]] = %[[V_33]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[V_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_36]], %[[V_N]])
// CHECK-NEXT:              scf.condition(%[[V_37]]) %[[V_35]], %[[V_36]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_38:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_39:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[V_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_15]]
// CHECK-NEXT:              %[[V_41:[0-9a-zA-Z_\.]+]] = array.read %[[V_38]]{{\[}}%[[V_40]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[V_42:[0-9a-zA-Z_\.]+]] = felt.const  888
// CHECK-NEXT:              %[[V_43:[0-9a-zA-Z_\.]+]] = felt.add %[[V_41]], %[[V_42]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[V_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_15]]
// CHECK-NEXT:              array.write %[[V_38]]{{\[}}%[[V_44]]] = %[[V_43]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[V_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_46:[0-9a-zA-Z_\.]+]] = felt.add %[[V_39]], %[[V_45]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[V_38]], %[[V_46]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[V_34]]#0 : !array.type<@N x !felt.type>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_47:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_48:[0-9a-zA-Z_\.]+]] = felt.add %[[V_15]], %[[V_47]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_18]], %[[V_48]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_49:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_49]]
// CHECK-NEXT:        %[[V_51:[0-9a-zA-Z_\.]+]] = array.read %[[V_10]]#0{{\[}}%[[V_50]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_52:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_52]]
// CHECK-NEXT:        %[[V_54:[0-9a-zA-Z_\.]+]] = array.read %[[V_10]]#0{{\[}}%[[V_53]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_55:[0-9a-zA-Z_\.]+]] = felt.add %[[V_51]], %[[V_54]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[V_0]][@out] = %[[V_55]] : <@InnerConditional9<[@N]>>, !felt.type
// CHECK-NEXT:        function.return %[[V_0]] : !struct.type<@InnerConditional9<[@N]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_56:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional9<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[V_105:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_56]][@out] : <@InnerConditional9<[@N]>>, !felt.type
// CHECK-NEXT:        %[[V_58:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_A:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type>
// CHECK-NEXT:        %[[V_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_61:[0-9a-zA-Z_\.]+]] = array.len %[[V_A]], %[[V_60]] : <@N x !felt.type>
// CHECK-NEXT:        %[[V_62:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_63:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[V_64:[0-9a-zA-Z_\.]+]] = %[[V_62]] to %[[V_61]] step %[[V_63]] {
// CHECK-NEXT:          array.write %[[V_A]]{{\[}}%[[V_64]]] = %[[V_58]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_65:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_66:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_67:[0-9a-zA-Z_\.]+]] = %[[V_A]], %[[V_68:[0-9a-zA-Z_\.]+]] = %[[V_65]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_69:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_68]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_69]]) %[[V_67]], %[[V_68]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_70:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_71:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_72:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_73:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_71]], %[[V_72]])
// CHECK-NEXT:          %[[V_74:[0-9a-zA-Z_\.]+]] = scf.if %[[V_73]] -> (!array.type<@N x !felt.type>) {
// CHECK-NEXT:            %[[V_75:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_76:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_77:[0-9a-zA-Z_\.]+]] = %[[V_70]], %[[V_78:[0-9a-zA-Z_\.]+]] = %[[V_75]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[V_79:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_78]], %[[V_N]])
// CHECK-NEXT:              scf.condition(%[[V_79]]) %[[V_77]], %[[V_78]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_80:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_81:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[V_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_71]]
// CHECK-NEXT:              %[[V_83:[0-9a-zA-Z_\.]+]] = array.read %[[V_80]]{{\[}}%[[V_82]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[V_84:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:              %[[V_85:[0-9a-zA-Z_\.]+]] = felt.add %[[V_83]], %[[V_84]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[V_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_71]]
// CHECK-NEXT:              array.write %[[V_80]]{{\[}}%[[V_86]]] = %[[V_85]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[V_87:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_88:[0-9a-zA-Z_\.]+]] = felt.add %[[V_81]], %[[V_87]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[V_80]], %[[V_88]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[V_76]]#0 : !array.type<@N x !felt.type>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[V_89:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_90:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_91:[0-9a-zA-Z_\.]+]] = %[[V_70]], %[[V_92:[0-9a-zA-Z_\.]+]] = %[[V_89]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[V_93:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_92]], %[[V_N]])
// CHECK-NEXT:              scf.condition(%[[V_93]]) %[[V_91]], %[[V_92]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_94:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_95:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[V_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_71]]
// CHECK-NEXT:              %[[V_97:[0-9a-zA-Z_\.]+]] = array.read %[[V_94]]{{\[}}%[[V_96]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[V_98:[0-9a-zA-Z_\.]+]] = felt.const  888
// CHECK-NEXT:              %[[V_99:[0-9a-zA-Z_\.]+]] = felt.add %[[V_97]], %[[V_98]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[V_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_71]]
// CHECK-NEXT:              array.write %[[V_94]]{{\[}}%[[V_100]]] = %[[V_99]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[V_101:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_102:[0-9a-zA-Z_\.]+]] = felt.add %[[V_95]], %[[V_101]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[V_94]], %[[V_102]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[V_90]]#0 : !array.type<@N x !felt.type>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_103:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_104:[0-9a-zA-Z_\.]+]] = felt.add %[[V_71]], %[[V_103]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_74]], %[[V_104]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
