// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template MultByInv() {
    signal input in;
    signal output out;

    signal inv;
    var temp;

    // Appears in both @compute and @constrain
    temp = in != 0 ? 1 / in : 0;
    // Appears only in @compute
    inv <-- temp == 0 ? 0 : temp;

    out <== inv;
    in * out === 0;
}

component main = MultByInv();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@MultByInv<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @MultByInv<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.member @inv : !felt.type
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@MultByInv<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@MultByInv<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_0]], %[[VAL_3]])
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_4]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_6]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_7]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[VAL_8]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_5]], %[[VAL_9]])
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_10]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[VAL_12]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_5]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@inv] = %[[VAL_11]] : <@MultByInv<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_1]][@out] = %[[VAL_11]] : <@MultByInv<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@MultByInv<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !struct.type<@MultByInv<[]>>, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@out] : <@MultByInv<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@inv] : <@MultByInv<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_14]], %[[VAL_16]])
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_17]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_19]], %[[VAL_14]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_20]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[VAL_21]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_23]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_14]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        constrain.eq %[[VAL_24]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
