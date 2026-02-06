// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function lookup() {
    var arr[2][2];
    arr[0] = [0, 1];
    arr[1] = [2, 3];
    return arr[1][1];
}

template Caller() {
    signal input in;
    signal output out <== lookup();
}

component main = Caller();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Caller<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @lookup() -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_0]], %[[VAL_0]] : <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:      array.insert %[[VAL_2]]{{\[}}%[[VAL_3]]] = %[[VAL_1]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:      array.insert %[[VAL_2]]{{\[}}%[[VAL_4]]] = %[[VAL_1]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_5]], %[[VAL_6]] : <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:      array.insert %[[VAL_2]]{{\[}}%[[VAL_9]]] = %[[VAL_7]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:      %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:      %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_10]], %[[VAL_11]] : <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:      array.insert %[[VAL_2]]{{\[}}%[[VAL_14]]] = %[[VAL_12]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:      %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:      %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_16]], %[[VAL_18]]] : <2,2 x !felt.type>, !felt.type
// CHECK-NEXT:      function.return %[[VAL_19]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Caller<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller<[]>>
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = function.call @lookup() : () -> !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_21]][@out] = %[[VAL_22]] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_21]] : !struct.type<@Caller<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller<[]>>, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:         %[[VAL_25:[0-9a-zA-Z_\.]+]] = function.call @lookup() : () -> !felt.type
// CHECK-DAG:         %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@out] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_26]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
