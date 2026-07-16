// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayDims(N) {
    var M = N + 1;
    signal output outp[M];
}

component main = ArrayDims(7);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArrayDims::@ArrayDims<[7]>>} {
// CHECK-NEXT:    poly.template @ArrayDims {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.expr @"M@300" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_1]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_3]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @ArrayDims {
// CHECK-NEXT:        struct.member @outp : !array.type<@"M@300" x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayDims::@ArrayDims<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayDims::@ArrayDims<[@N]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @"M@300" : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_5]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_4]] : !struct.type<@ArrayDims::@ArrayDims<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayDims::@ArrayDims<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @"M@300" : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_11]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_10]][@outp] : <@ArrayDims::@ArrayDims<[@N]>>, !array.type<@"M@300" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
