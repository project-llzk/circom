// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Array00() {
    signal input a[1];
    signal output b[1];

    b[0] <== a[0];
}

component main = Array00();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Array00<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Array00<[]> {
// CHECK-NEXT:      struct.field @b : !array.type<1 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<1 x !felt.type>) -> !struct.type<@Array00<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Array00<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<1 x !felt.type>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]]
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_4]]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]]
// CHECK-NEXT:        array.write %[[VAL_2]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@b] = %[[VAL_2]] : <@Array00<[]>>, !array.type<1 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Array00<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@Array00<[]>>, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !array.type<1 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_8]][@b] : <@Array00<[]>>, !array.type<1 x !felt.type>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]]
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_11]]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]]
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_15]]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_16]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
