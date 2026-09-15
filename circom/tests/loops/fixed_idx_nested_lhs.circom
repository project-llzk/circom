// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template FixIdxNested() {
    var arr[9] = [8, 7, 6, 5, 4, 3, 2, 1, 0];
    signal out[9];
    for (var i = 0; i < 9; i++) {
        out[arr[i]] <-- arr[i];
    }
}

component main = FixIdxNested();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@FixIdxNested::@FixIdxNested<[]>>} {
// CHECK-NEXT:    poly.template @FixIdxNested {
// CHECK-NEXT:      struct.def @FixIdxNested {
// CHECK-NEXT:        struct.member @out : !array.type<9 x !felt.type<"bn128">> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@FixIdxNested::@FixIdxNested<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@FixIdxNested::@FixIdxNested<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]] : <9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_11]]] : <9 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_13]]] : <9 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_1]]{{\[}}%[[VAL_15]]] = %[[VAL_12]] : <9 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_1]] : <@FixIdxNested::@FixIdxNested<[]>>, !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@FixIdxNested::@FixIdxNested<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@FixIdxNested::@FixIdxNested<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@out] : <@FixIdxNested::@FixIdxNested<[]>>, !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_20]], %[[VAL_20]], %[[VAL_20]], %[[VAL_20]], %[[VAL_20]], %[[VAL_20]], %[[VAL_20]], %[[VAL_20]], %[[VAL_20]] : <9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_23]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_25]], %[[VAL_26]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_27]]) %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<9 x !felt.type<"bn128">> = [ 8 : <"bn128">,  7 : <"bn128">,  6 : <"bn128">,  5 : <"bn128">,  4 : <"bn128">,  3 : <"bn128">,  2 : <"bn128">,  1 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:  }
