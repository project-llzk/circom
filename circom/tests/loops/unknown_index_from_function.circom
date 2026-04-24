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
// CHECK-NEXT:    poly.template @identity {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @identity(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_1]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Example {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Example {
// CHECK-NEXT:        struct.member @c : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Example::@Example<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.new : <@Example::@Example<[@n]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_5]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_10]]) %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @identity::@identity(%[[VAL_3]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_13]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_6]]{{\[}}%[[VAL_15]]] = %[[VAL_14]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_4]][@c] = %[[VAL_6]] : <@Example::@Example<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_4]] : !struct.type<@Example::@Example<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@Example::@Example<[@n]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@c] : <@Example::@Example<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_23]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_25]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
