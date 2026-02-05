// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Array1() {
    signal output out[5][1];

    for (var i = 0; i < 5; i++) {
      out[i][0] <== i;
    }
}

component main = Array1();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Array1<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Array1<[]> {
// CHECK-NEXT:      struct.field @out : !array.type<5,1 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Array1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Array1<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<5,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_4:[0-9a-zA-Z_\.]+]] = %[[VAL_2]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_4]], %[[VAL_5]])
// CHECK-NEXT:          scf.condition(%[[VAL_6]]) %[[VAL_4]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]]
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_8]], %[[VAL_10]]] = %[[VAL_7]] : <5,1 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_7]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_12]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_0]][@out] = %[[VAL_1]] : <@Array1<[]>>, !array.type<5,1 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@Array1<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !struct.type<@Array1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_13]][@out] : <@Array1<[]>>, !array.type<5,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_14]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_17]])
// CHECK-NEXT:          scf.condition(%[[VAL_18]]) %[[VAL_16]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_21]], %[[VAL_23]]] : <5,1 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_26]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
