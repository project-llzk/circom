// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithRemainder() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in != 0 ? 1 % in : 0;

    out <== inv;
    in * out === 0;
}

component main = ArithRemainder();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ArithRemainder<[]>>} {
// CHECK-NEXT:    poly.template @ArithRemainder {
// CHECK-NEXT:      struct.def @ArithRemainder {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        struct.member @inv : !felt.type
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@ArithRemainder::@ArithRemainder<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ArithRemainder::@ArithRemainder<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_0]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_3]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_5]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_6]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_7]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@inv] = %[[VAL_4]] : <@ArithRemainder::@ArithRemainder<[]>>, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@ArithRemainder::@ArithRemainder<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ArithRemainder::@ArithRemainder<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@ArithRemainder::@ArithRemainder<[]>>, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:           %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_8]][@out] : <@ArithRemainder::@ArithRemainder<[]>>, !felt.type
// CHECK-DAG:           %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_8]][@inv] : <@ArithRemainder::@ArithRemainder<[]>>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_10]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_9]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          constrain.eq %[[VAL_12]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
