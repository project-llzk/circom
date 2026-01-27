// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function compute(start) {
    var arr[2][1];
    arr[0][0] = start;
    arr[1][0] = arr[0][0] + 1;
    return arr[1][0];
}

template Caller() {
    signal input in;
    signal output out <== compute(in);
}

component main = Caller();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]] : <1 x !felt.type>
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !felt.type>
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:      array.insert %[[VAL_3]]{{\[}}%[[VAL_4]]] = %[[VAL_2]] : <2,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:      array.insert %[[VAL_3]]{{\[}}%[[VAL_5]]] = %[[VAL_2]] : <2,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]]
// CHECK-NEXT:      %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:      array.write %[[VAL_3]]{{\[}}%[[VAL_7]], %[[VAL_9]]] = %[[VAL_0]] : <2,1 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]]
// CHECK-NEXT:      %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]]
// CHECK-NEXT:      %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_11]], %[[VAL_13]]] : <2,1 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_15]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:      %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:      array.write %[[VAL_3]]{{\[}}%[[VAL_18]], %[[VAL_20]]] = %[[VAL_16]] : <2,1 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:      %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]]
// CHECK-NEXT:      %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_22]], %[[VAL_24]]] : <2,1 x !felt.type>, !felt.type
// CHECK-NEXT:      function.return %[[VAL_25]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Caller<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller<[]>>
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @compute(%[[VAL_26]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_27]][@out] = %[[VAL_28]] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_27]] : !struct.type<@Caller<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller<[]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = function.call @compute(%[[VAL_30]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_29]][@out] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_32]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
