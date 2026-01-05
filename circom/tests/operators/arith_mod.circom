// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @ArithRemainder<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @inv : !felt.type
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@ArithRemainder<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ArithRemainder<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_0]], %[[VAL_2]])
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_3]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.mod %[[VAL_5]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_6]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[VAL_7]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@inv] = %[[VAL_4]] : <@ArithRemainder<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_4]] : <@ArithRemainder<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@ArithRemainder<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@ArithRemainder<[]>>, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_8]][@inv] : <@ArithRemainder<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_8]][@out] : <@ArithRemainder<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_11]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_9]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        constrain.eq %[[VAL_12]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
