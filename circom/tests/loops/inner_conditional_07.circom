// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@InnerConditional7::@InnerConditional7<[3]>>} {
// CHECK-NEXT:    poly.template @InnerConditional7 {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @InnerConditional7 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional7::@InnerConditional7<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[V_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional7::@InnerConditional7<[@N]>>
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_A:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_5:[0-9a-zA-Z_\.]+]] = array.len %[[V_A]], %[[V_4]] : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[V_8:[0-9a-zA-Z_\.]+]] = %[[V_6]] to %[[V_5]] step %[[V_7]] {
// CHECK-NEXT:            array.write %[[V_A]]{{\[}}%[[V_8]]] = %[[V_2]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_10:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_13]]) %[[V_A1]], %[[V_I1]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_17:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A3:[0-9a-zA-Z_\.]+]] = %[[V_A2]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[V_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_J1]], %[[V_N]])
// CHECK-NEXT:              scf.condition(%[[V_20]]) %[[V_A3]], %[[V_J1]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_A4:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[V_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_24:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[V_I2]], %[[V_23]])
// CHECK-NEXT:              %[[V_A5:[0-9a-zA-Z_\.]+]] = scf.if %[[V_24]] -> (!array.type<@N x !felt.type<"bn128">>) {
// CHECK-NEXT:                %[[V_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:                %[[V_27:[0-9a-zA-Z_\.]+]] = array.read %[[V_A4]]{{\[}}%[[V_26]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[V_28:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:                %[[V_29:[0-9a-zA-Z_\.]+]] = felt.add %[[V_27]], %[[V_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[V_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:                array.write %[[V_A4]]{{\[}}%[[V_30]]] = %[[V_29]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[V_A4]] : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[V_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:                %[[V_32:[0-9a-zA-Z_\.]+]] = array.read %[[V_A4]]{{\[}}%[[V_31]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[V_33:[0-9a-zA-Z_\.]+]] = felt.const  111
// CHECK-NEXT:                %[[V_34:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_32]], %[[V_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[V_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:                array.write %[[V_A4]]{{\[}}%[[V_35]]] = %[[V_34]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[V_A4]] : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[V_36:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_J3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J2]], %[[V_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[V_A5]], %[[V_J3]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[V_38:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_17]]#0, %[[V_I3]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_40:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_40]]
// CHECK-NEXT:          %[[V_42:[0-9a-zA-Z_\.]+]] = array.read %[[V_10]]#0{{\[}}%[[V_41]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[V_43:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_43]]
// CHECK-NEXT:          %[[V_45:[0-9a-zA-Z_\.]+]] = array.read %[[V_10]]#0{{\[}}%[[V_44]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[V_46:[0-9a-zA-Z_\.]+]] = felt.add %[[V_42]], %[[V_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[V_0]][@out] = %[[V_46]] : <@InnerConditional7::@InnerConditional7<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[V_0]] : !struct.type<@InnerConditional7::@InnerConditional7<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[V_47:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional7::@InnerConditional7<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[V_47]][@out] : <@InnerConditional7::@InnerConditional7<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[V_49:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_A:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_52:[0-9a-zA-Z_\.]+]] = array.len %[[V_A]], %[[V_51]] : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[V_55:[0-9a-zA-Z_\.]+]] = %[[V_53]] to %[[V_52]] step %[[V_54]] {
// CHECK-NEXT:            array.write %[[V_A]]{{\[}}%[[V_55]]] = %[[V_49]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_57:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A1:[0-9a-zA-Z_\.]+]] = %[[V_A]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_60:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_60]]) %[[V_A1]], %[[V_I1]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_A2:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_64:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_A3:[0-9a-zA-Z_\.]+]] = %[[V_A2]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[V_67:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_J1]], %[[V_N]])
// CHECK-NEXT:              scf.condition(%[[V_67]]) %[[V_A3]], %[[V_J1]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_A4:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[V_70:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_71:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[V_I2]], %[[V_70]])
// CHECK-NEXT:              %[[V_A5:[0-9a-zA-Z_\.]+]] = scf.if %[[V_71]] -> (!array.type<@N x !felt.type<"bn128">>) {
// CHECK-NEXT:                %[[V_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:                %[[V_74:[0-9a-zA-Z_\.]+]] = array.read %[[V_A4]]{{\[}}%[[V_73]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[V_75:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:                %[[V_76:[0-9a-zA-Z_\.]+]] = felt.add %[[V_74]], %[[V_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[V_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:                array.write %[[V_A4]]{{\[}}%[[V_77]]] = %[[V_76]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[V_A4]] : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[V_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:                %[[V_79:[0-9a-zA-Z_\.]+]] = array.read %[[V_A4]]{{\[}}%[[V_78]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[V_80:[0-9a-zA-Z_\.]+]] = felt.const  111
// CHECK-NEXT:                %[[V_81:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_79]], %[[V_80]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[V_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:                array.write %[[V_A4]]{{\[}}%[[V_82]]] = %[[V_81]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[V_A4]] : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[V_83:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_J3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J2]], %[[V_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[V_A5]], %[[V_J3]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[V_85:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_64]]#0, %[[V_I3]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
