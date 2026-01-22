// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional7(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        // Values of 'a' at the header per iteration:
        // i=0: [0, 0, 0, 0]
        // i=1: [-111, -111, -111]
        // i=2: [-222, -222, -222]
        // NOTE: Technically there are no negative values, it's instead wrapped modulo the field prime
        for (var j = 0; j < N; j++) {
            if (i > 1) {
                a[j] += 999;
            } else {
                a[j] -= 111;
            }
        }
    }
    // At this point, 'a[x] = 777' for all 'x', so 'out = 1554'
    out <-- a[0] + a[1];
}

component main = InnerConditional7(3);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @InnerConditional7<[@N]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@InnerConditional7<[@N]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional7<[@N]>>
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
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_16]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_19]], %[[VAL_1]])
// CHECK-NEXT:            scf.condition(%[[VAL_20]]) %[[VAL_18]], %[[VAL_19]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_15]], %[[VAL_23]])
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_24]] -> (!array.type<@N x !felt.type>) {
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_26]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_28]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:              array.write %[[VAL_21]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_21]] : !array.type<@N x !felt.type>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_31]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  111
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_32]], %[[VAL_33]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:              array.write %[[VAL_21]]{{\[}}%[[VAL_35]]] = %[[VAL_34]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_21]] : !array.type<@N x !felt.type>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_36]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_25]], %[[VAL_37]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_38]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_17]]#0, %[[VAL_39]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]]
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]#0{{\[}}%[[VAL_41]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]]
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]#0{{\[}}%[[VAL_44]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_45]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_0]][@out] = %[[VAL_46]] : <@InnerConditional7<[@N]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@InnerConditional7<[@N]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional7<[@N]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type>
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_50]], %[[VAL_51]] : <@N x !felt.type>
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_53]] to %[[VAL_52]] step %[[VAL_54]] {
// CHECK-NEXT:          array.write %[[VAL_50]]{{\[}}%[[VAL_55]]] = %[[VAL_49]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_50]], %[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_56]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_59]], %[[VAL_48]])
// CHECK-NEXT:          scf.condition(%[[VAL_60]]) %[[VAL_58]], %[[VAL_59]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_61]], %[[VAL_66:[0-9a-zA-Z_\.]+]] = %[[VAL_63]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_66]], %[[VAL_48]])
// CHECK-NEXT:            scf.condition(%[[VAL_67]]) %[[VAL_65]], %[[VAL_66]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_62]], %[[VAL_70]])
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_71]] -> (!array.type<@N x !felt.type>) {
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]]
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_68]]{{\[}}%[[VAL_73]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_74]], %[[VAL_75]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]]
// CHECK-NEXT:              array.write %[[VAL_68]]{{\[}}%[[VAL_77]]] = %[[VAL_76]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_68]] : !array.type<@N x !felt.type>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]]
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_68]]{{\[}}%[[VAL_78]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  111
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_79]], %[[VAL_80]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]]
// CHECK-NEXT:              array.write %[[VAL_68]]{{\[}}%[[VAL_82]]] = %[[VAL_81]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_68]] : !array.type<@N x !felt.type>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_83]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_72]], %[[VAL_84]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_85]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_64]]#0, %[[VAL_86]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_47]][@out] : <@InnerConditional7<[@N]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
