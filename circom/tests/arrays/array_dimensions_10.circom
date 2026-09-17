// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayDims() {
    var a[2] = [123, 675];
    signal output outp[a[1]];
}

component main = ArrayDims();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArrayDims::@ArrayDims<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<2 x !felt.type<"bn128">> = [ 123 : <"bn128">,  675 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ArrayDims {
// CHECK-NEXT:      poly.expr @"a[1]@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_3]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_7]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @ArrayDims {
// CHECK-NEXT:        struct.member @outp : !array.type<@"a[1]@[[OFFSET0]]" x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayDims::@ArrayDims<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayDims::@ArrayDims<[]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @"a[1]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_9]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_8]] : !struct.type<@ArrayDims::@ArrayDims<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayDims::@ArrayDims<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @"a[1]@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_17]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@outp] : <@ArrayDims::@ArrayDims<[]>>, !array.type<@"a[1]@[[OFFSET0]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
