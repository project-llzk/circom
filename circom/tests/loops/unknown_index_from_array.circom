// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Example(n) {
    signal input a[n];
    signal input b[n];
    signal output c[n];

    for(var i = 0; i < n; i++) {
        c[i] <-- a[b[2]];
    }
}

component main = Example(3);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Example::@Example<[3]>>} {
// CHECK-NEXT:    poly.template @Example {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Example {
// CHECK-NEXT:        struct.member @c : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "b"}) -> !struct.type<@Example::@Example<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Example::@Example<[@n]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_4]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_12]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_14]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_5]]{{\[}}%[[VAL_16]]] = %[[VAL_15]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_5]] : <@Example::@Example<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Example::@Example<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@Example::@Example<[@n]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_22]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@c] : <@Example::@Example<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_25]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_27]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_28]]) %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_29]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
