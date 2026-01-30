// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ForUnknownIndex() {
    signal input in;
    signal output out;

    var arr1[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    var arr2[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    var arr3[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    var acc = 0;
    for (var i = 1; i <= in; i++) {
        acc += i;
    }

    // non-quadractic constraint
    // out <== arr[acc];
    out <-- arr2[acc % 10];
}

component main = ForUnknownIndex();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @ForUnknownIndex<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@ForUnknownIndex<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ForUnknownIndex<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_5]], %[[VAL_6]], %[[VAL_7]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]], %[[VAL_11]], %[[VAL_12]], %[[VAL_13]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_17]], %[[VAL_18]], %[[VAL_19]], %[[VAL_20]], %[[VAL_21]], %[[VAL_22]], %[[VAL_23]], %[[VAL_24]], %[[VAL_25]], %[[VAL_26]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_28]], %[[VAL_28]], %[[VAL_28]], %[[VAL_28]], %[[VAL_28]], %[[VAL_28]], %[[VAL_28]], %[[VAL_28]], %[[VAL_28]], %[[VAL_28]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_30]], %[[VAL_31]], %[[VAL_32]], %[[VAL_33]], %[[VAL_34]], %[[VAL_35]], %[[VAL_36]], %[[VAL_37]], %[[VAL_38]], %[[VAL_39]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_41]], %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_42]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_45]], %[[VAL_0]])
// CHECK-NEXT:          scf.condition(%[[VAL_46]]) %[[VAL_44]], %[[VAL_45]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_47]], %[[VAL_48]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_48]], %[[VAL_50]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_49]], %[[VAL_51]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_43]]#0, %[[VAL_52]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]]
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_54]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_55]] : <@ForUnknownIndex<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@ForUnknownIndex<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !struct.type<@ForUnknownIndex<[]>>, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_56]][@out] : <@ForUnknownIndex<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_58]], %[[VAL_58]], %[[VAL_58]], %[[VAL_58]], %[[VAL_58]], %[[VAL_58]], %[[VAL_58]], %[[VAL_58]], %[[VAL_58]], %[[VAL_58]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_60]], %[[VAL_61]], %[[VAL_62]], %[[VAL_63]], %[[VAL_64]], %[[VAL_65]], %[[VAL_66]], %[[VAL_67]], %[[VAL_68]], %[[VAL_69]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_71]], %[[VAL_71]], %[[VAL_71]], %[[VAL_71]], %[[VAL_71]], %[[VAL_71]], %[[VAL_71]], %[[VAL_71]], %[[VAL_71]], %[[VAL_71]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_73]], %[[VAL_74]], %[[VAL_75]], %[[VAL_76]], %[[VAL_77]], %[[VAL_78]], %[[VAL_79]], %[[VAL_80]], %[[VAL_81]], %[[VAL_82]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_86]], %[[VAL_87]], %[[VAL_88]], %[[VAL_89]], %[[VAL_90]], %[[VAL_91]], %[[VAL_92]], %[[VAL_93]], %[[VAL_94]], %[[VAL_95]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_99:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_100:[0-9a-zA-Z_\.]+]] = %[[VAL_97]], %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_98]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_101]], %[[VAL_57]])
// CHECK-NEXT:          scf.condition(%[[VAL_102]]) %[[VAL_100]], %[[VAL_101]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_103:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_104:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_103]], %[[VAL_104]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_104]], %[[VAL_106]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_105]], %[[VAL_107]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
