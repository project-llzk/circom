// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function feeShiftTable(i) {
    var out[2] = [3,9];
    return out[i];
}

template ComputeFee() {
    signal output feeOut[2];

    for (var i = 0; i < 2; i++) {
        feeOut[i] <== feeShiftTable(i);
    }
}

component main = ComputeFee();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ComputeFee<[]>>} {
// CHECK-NEXT:    function.def @feeShiftTable(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]] : <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_4]] : <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]]
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_6]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      function.return %[[VAL_7]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @ComputeFee<[]> {
// CHECK-NEXT:      struct.member @feeOut : !array.type<2 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@ComputeFee<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@ComputeFee<[]>>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_13]])
// CHECK-NEXT:          scf.condition(%[[VAL_14]]) %[[VAL_12]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = function.call @feeShiftTable(%[[VAL_15]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:          array.write %[[VAL_9]]{{\[}}%[[VAL_17]]] = %[[VAL_16]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_19]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_8]][@feeOut] = %[[VAL_9]] : <@ComputeFee<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_8]] : !struct.type<@ComputeFee<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@ComputeFee<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@feeOut] : <@ComputeFee<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_23]], %[[VAL_24]])
// CHECK-NEXT:          scf.condition(%[[VAL_25]]) %[[VAL_23]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = function.call @feeShiftTable(%[[VAL_26]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]]
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_29]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_30]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_32]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
