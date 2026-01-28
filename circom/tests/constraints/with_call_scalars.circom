// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
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
// CHECK-NEXT:      struct.field @feeOut : !array.type<2 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@ComputeFee<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@ComputeFee<[]>>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
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
// CHECK-NEXT:        struct.writef %[[VAL_8]][@feeOut] = %[[VAL_9]] : <@ComputeFee<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_8]] : !struct.type<@ComputeFee<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@ComputeFee<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_21]], %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!array.type<2 x !felt.type>, !felt.type) -> (!array.type<2 x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_25]], %[[VAL_26]])
// CHECK-NEXT:          scf.condition(%[[VAL_27]]) %[[VAL_24]], %[[VAL_25]] : !array.type<2 x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>, %[[VAL_29:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = function.call @feeShiftTable(%[[VAL_29]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_20]][@feeOut] : <@ComputeFee<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]]
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_32]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_33]], %[[VAL_30]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_29]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_31]], %[[VAL_35]] : !array.type<2 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
