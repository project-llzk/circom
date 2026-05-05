// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function nbits(a) {
    var n = 1;
    var r = 0;
    while (n-1<a) {
        r++;
        n *= 2;
    }
    return r;
}

template Call2() {
    signal input m;
    signal output y;

    y <-- nbits(m);
}

component main = Call2();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Call2::@Call2<[]>>} {
// CHECK-NEXT:    poly.template @nbits {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @nbits(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_4:[0-9a-zA-Z_\.]+]] = %[[VAL_1]], %[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_2]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_4]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_9]]) %[[VAL_4]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_10]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_15]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]]#1 : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_16]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Call2 {
// CHECK-NEXT:      struct.def @Call2 {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Call2::@Call2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.new : <@Call2::@Call2<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @nbits::@nbits(%[[VAL_17]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_18]][@y] = %[[VAL_19]] : <@Call2::@Call2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_18]] : !struct.type<@Call2::@Call2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@Call2::@Call2<[]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@y] : <@Call2::@Call2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
