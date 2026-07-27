// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayDims(N, M) {
    var arr[N][M];
}

component main = ArrayDims(7, 2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArrayDims::@ArrayDims<[7, 2]>>} {
// CHECK-NEXT:    poly.template @ArrayDims {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.param @M : index
// CHECK-NEXT:      struct.def @ArrayDims {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayDims::@ArrayDims<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayDims::@ArrayDims<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.new  : <@M x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_6]], %[[VAL_7]] : <@M x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_9]] to %[[VAL_8]] step %[[VAL_10]] {
// CHECK-NEXT:            array.write %[[VAL_6]]{{\[}}%[[VAL_11]]] = %[[VAL_5]] : <@M x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <@N,@M x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_12]], %[[VAL_13]] : <@N,@M x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_15]] to %[[VAL_14]] step %[[VAL_16]] {
// CHECK-NEXT:            array.insert %[[VAL_12]]{{\[}}%[[VAL_17]]] = %[[VAL_6]] : <@N,@M x !felt.type<"bn128">>, <@M x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@ArrayDims::@ArrayDims<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayDims::@ArrayDims<[@N, @M]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_21]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.new  : <@M x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_24]], %[[VAL_25]] : <@M x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_27]] to %[[VAL_26]] step %[[VAL_28]] {
// CHECK-NEXT:            array.write %[[VAL_24]]{{\[}}%[[VAL_29]]] = %[[VAL_23]] : <@M x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.new  : <@N,@M x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_30]], %[[VAL_31]] : <@N,@M x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_33]] to %[[VAL_32]] step %[[VAL_34]] {
// CHECK-NEXT:            array.insert %[[VAL_30]]{{\[}}%[[VAL_35]]] = %[[VAL_24]] : <@N,@M x !felt.type<"bn128">>, <@M x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
