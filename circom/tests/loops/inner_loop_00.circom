// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(n, m) {
    signal input in[m];
    signal output out;
    var b[n];

    for (var i = 0; i < n; i++) {
        for (var j = 0; j < m; j++) {
            b[i] = in[j];
        }
    }
    out <-- b[0];
}

component main = InnerLoops(2, 3);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerLoops::@InnerLoops<[2, 3]>>} {
// CHECK-NEXT:    poly.template @InnerLoops {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.param @m
// CHECK-NEXT:      struct.def @InnerLoops {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[V_IN:[0-9a-zA-Z_\.]+]]: !array.type<@m x !felt.type<"bn128">>) -> !struct.type<@InnerLoops::@InnerLoops<[@n, @m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[V_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops::@InnerLoops<[@n, @m]>>
// CHECK-NEXT:          %[[V_M:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_B:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_7:[0-9a-zA-Z_\.]+]] = array.len %[[V_B]], %[[V_6]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_8:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[V_10:[0-9a-zA-Z_\.]+]] = %[[V_8]] to %[[V_7]] step %[[V_9]] {
// CHECK-NEXT:            array.write %[[V_B]]{{\[}}%[[V_10]]] = %[[V_4]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_12:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B1:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_15]]) %[[V_B1]], %[[V_I1]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_B2:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[V_I3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_19:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_20:[0-9a-zA-Z_\.]+]] = %[[V_B2]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[V_22:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_J1]], %[[V_M]])
// CHECK-NEXT:              scf.condition(%[[V_22]]) %[[V_20]], %[[V_J1]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_23:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[V_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_J2]]
// CHECK-NEXT:              %[[V_26:[0-9a-zA-Z_\.]+]] = array.read %[[V_IN]]{{\[}}%[[V_25]]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I3]]
// CHECK-NEXT:              array.write %[[V_23]]{{\[}}%[[V_27]]] = %[[V_26]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_28:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_29:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J2]], %[[V_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[V_23]], %[[V_29]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[V_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_31:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I3]], %[[V_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_19]]#0, %[[V_31]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_32:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_32]]
// CHECK-NEXT:          %[[V_34:[0-9a-zA-Z_\.]+]] = array.read %[[V_12]]#0{{\[}}%[[V_33]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[V_1]][@out] = %[[V_34]] : <@InnerLoops::@InnerLoops<[@n, @m]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[V_1]] : !struct.type<@InnerLoops::@InnerLoops<[@n, @m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[V_IN:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops::@InnerLoops<[@n, @m]>>, %[[V_36:[0-9a-zA-Z_\.]+]]: !array.type<@m x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[V_M:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[V_IN]][@out] : <@InnerLoops::@InnerLoops<[@n, @m]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[V_39:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_B:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_42:[0-9a-zA-Z_\.]+]] = array.len %[[V_B]], %[[V_41]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_43:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_44:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[V_45:[0-9a-zA-Z_\.]+]] = %[[V_43]] to %[[V_42]] step %[[V_44]] {
// CHECK-NEXT:            array.write %[[V_B]]{{\[}}%[[V_45]]] = %[[V_39]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_46:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_47:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_48:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_49:[0-9a-zA-Z_\.]+]] = %[[V_46]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_50:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_49]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_50]]) %[[V_48]], %[[V_49]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_51:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[V_52:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[V_53:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_54:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_55:[0-9a-zA-Z_\.]+]] = %[[V_51]], %[[V_56:[0-9a-zA-Z_\.]+]] = %[[V_53]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[V_57:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_56]], %[[V_M]])
// CHECK-NEXT:              scf.condition(%[[V_57]]) %[[V_55]], %[[V_56]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_58:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[V_59:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[V_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_59]]
// CHECK-NEXT:              %[[V_61:[0-9a-zA-Z_\.]+]] = array.read %[[V_36]]{{\[}}%[[V_60]]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_52]]
// CHECK-NEXT:              array.write %[[V_58]]{{\[}}%[[V_62]]] = %[[V_61]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_63:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_64:[0-9a-zA-Z_\.]+]] = felt.add %[[V_59]], %[[V_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[V_58]], %[[V_64]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[V_65:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_66:[0-9a-zA-Z_\.]+]] = felt.add %[[V_52]], %[[V_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_54]]#0, %[[V_66]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
