// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function identity(n) {
    return n;
}

template Example(n) {
    signal input a[n];
    signal input b;
    signal output c[n];

    for(var i = 0; i < n; i++) {
        c[i] <-- a[identity(b)];
    }
}

component main = Example(3);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Example::@Example<[3]>>} {
// CHECK-NEXT:    function.def @identity(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !felt.type<"bn128"> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Example {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Example {
// CHECK-NEXT:        struct.member @c : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Example::@Example<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@Example::@Example<[@n]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_4]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @identity(%[[VAL_2]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_12]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_5]]{{\[}}%[[VAL_14]]] = %[[VAL_13]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_3]][@c] = %[[VAL_5]] : <@Example::@Example<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@Example::@Example<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@Example::@Example<[@n]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@c] : <@Example::@Example<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_20]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
