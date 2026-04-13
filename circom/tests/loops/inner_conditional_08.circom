// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// like inner_conditional_7 but with 'i' and 'j' uses swapped (and a larger constant)
template InnerConditional8(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        // Values of 'a' at the header per iteration:
        // i=0: [0, 0, 0, 0]
        // i=1: [1776, 0, 0, 0]
        // i=2: [1776, 1776, 0, 0]
        // i=3: [1776, 1776, 1776, 0]
        for (var j = 0; j < N; j++) {
            if (j > 1) {
                a[i] += 999;
            } else {
                a[i] -= 111;
            }
        }
    }
    // At this point, 'a[x] = 1776' for all 'x', so 'out = 3552'
    out <-- a[0] + a[1];
}

component main = InnerConditional8(4);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerConditional8::@InnerConditional8<[4]>>} {
// CHECK-NEXT:    poly.template @InnerConditional8 {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @InnerConditional8 {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional8::@InnerConditional8<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[V_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional8::@InnerConditional8<[@N]>>
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[V_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_A:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type>
// CHECK-NEXT:          %[[V_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_5:[0-9a-zA-Z_\.]+]] = array.len %[[V_A]], %[[V_4]] : <@N x !felt.type>
// CHECK-NEXT:          %[[V_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[V_8:[0-9a-zA-Z_\.]+]] = %[[V_6]] to %[[V_5]] step %[[V_7]] {
// CHECK-NEXT:            array.write %[[V_A]]{{\[}}%[[V_8]]] = %[[V_2]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_10:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[V_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_13]]) %[[V_A1]], %[[V_I1]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_17:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A3:[0-9a-zA-Z_\.]+]] = %[[V_A2]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[V_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_J1]], %[[V_N]])
// CHECK-NEXT:              scf.condition(%[[V_20]]) %[[V_A3]], %[[V_J1]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_A4:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[V_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_24:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[V_J2]], %[[V_23]])
// CHECK-NEXT:              %[[V_A5:[0-9a-zA-Z_\.]+]] = scf.if %[[V_24]] -> (!array.type<@N x !felt.type>) {
// CHECK-NEXT:                %[[V_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:                %[[V_27:[0-9a-zA-Z_\.]+]] = array.read %[[V_A4]]{{\[}}%[[V_26]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:                %[[V_28:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:                %[[V_29:[0-9a-zA-Z_\.]+]] = felt.add %[[V_27]], %[[V_28]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[V_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:                array.write %[[V_A4]]{{\[}}%[[V_30]]] = %[[V_29]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:                scf.yield %[[V_A4]] : !array.type<@N x !felt.type>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[V_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:                %[[V_32:[0-9a-zA-Z_\.]+]] = array.read %[[V_A4]]{{\[}}%[[V_31]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:                %[[V_33:[0-9a-zA-Z_\.]+]] = felt.const  111
// CHECK-NEXT:                %[[V_34:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_32]], %[[V_33]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[V_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:                array.write %[[V_A4]]{{\[}}%[[V_35]]] = %[[V_34]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:                scf.yield %[[V_A4]] : !array.type<@N x !felt.type>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[V_36:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_J3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J2]], %[[V_36]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[V_A5]], %[[V_J3]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[V_38:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_38]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_17]]#0, %[[V_I3]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_40:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_40]]
// CHECK-NEXT:          %[[V_42:[0-9a-zA-Z_\.]+]] = array.read %[[V_10]]#0{{\[}}%[[V_41]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_43:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_43]]
// CHECK-NEXT:          %[[V_45:[0-9a-zA-Z_\.]+]] = array.read %[[V_10]]#0{{\[}}%[[V_44]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_46:[0-9a-zA-Z_\.]+]] = felt.add %[[V_42]], %[[V_45]] : !felt.type, !felt.type
// CHECK-NEXT:          struct.writem %[[V_0]][@out] = %[[V_46]] : <@InnerConditional8::@InnerConditional8<[@N]>>, !felt.type
// CHECK-NEXT:          function.return %[[V_0]] : !struct.type<@InnerConditional8::@InnerConditional8<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[V_47:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional8::@InnerConditional8<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[V_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[V_47]][@out] : <@InnerConditional8::@InnerConditional8<[@N]>>, !felt.type
// CHECK-NEXT:          %[[V_49:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_A:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type>
// CHECK-NEXT:          %[[V_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_52:[0-9a-zA-Z_\.]+]] = array.len %[[V_A]], %[[V_51]] : <@N x !felt.type>
// CHECK-NEXT:          %[[V_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[V_55:[0-9a-zA-Z_\.]+]] = %[[V_53]] to %[[V_52]] step %[[V_54]] {
// CHECK-NEXT:            array.write %[[V_A]]{{\[}}%[[V_55]]] = %[[V_49]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_56:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_57:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_58:[0-9a-zA-Z_\.]+]] = %[[V_A]], %[[V_59:[0-9a-zA-Z_\.]+]] = %[[V_56]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[V_60:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_59]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_60]]) %[[V_58]], %[[V_59]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_61:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_62:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_63:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_64:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_65:[0-9a-zA-Z_\.]+]] = %[[V_61]], %[[V_66:[0-9a-zA-Z_\.]+]] = %[[V_63]]) : (!array.type<@N x !felt.type>, !felt.type) -> (!array.type<@N x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[V_67:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_66]], %[[V_N]])
// CHECK-NEXT:              scf.condition(%[[V_67]]) %[[V_65]], %[[V_66]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_68:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[V_69:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[V_70:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_71:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[V_69]], %[[V_70]])
// CHECK-NEXT:              %[[V_72:[0-9a-zA-Z_\.]+]] = scf.if %[[V_71]] -> (!array.type<@N x !felt.type>) {
// CHECK-NEXT:                %[[V_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_62]]
// CHECK-NEXT:                %[[V_74:[0-9a-zA-Z_\.]+]] = array.read %[[V_68]]{{\[}}%[[V_73]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:                %[[V_75:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:                %[[V_76:[0-9a-zA-Z_\.]+]] = felt.add %[[V_74]], %[[V_75]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[V_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_62]]
// CHECK-NEXT:                array.write %[[V_68]]{{\[}}%[[V_77]]] = %[[V_76]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:                scf.yield %[[V_68]] : !array.type<@N x !felt.type>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[V_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_62]]
// CHECK-NEXT:                %[[V_79:[0-9a-zA-Z_\.]+]] = array.read %[[V_68]]{{\[}}%[[V_78]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:                %[[V_80:[0-9a-zA-Z_\.]+]] = felt.const  111
// CHECK-NEXT:                %[[V_81:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_79]], %[[V_80]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[V_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_62]]
// CHECK-NEXT:                array.write %[[V_68]]{{\[}}%[[V_82]]] = %[[V_81]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:                scf.yield %[[V_68]] : !array.type<@N x !felt.type>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[V_83:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_84:[0-9a-zA-Z_\.]+]] = felt.add %[[V_69]], %[[V_83]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[V_72]], %[[V_84]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[V_85:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_86:[0-9a-zA-Z_\.]+]] = felt.add %[[V_62]], %[[V_85]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_64]]#0, %[[V_86]] : !array.type<@N x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
