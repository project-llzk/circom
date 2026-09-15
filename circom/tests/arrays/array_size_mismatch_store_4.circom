// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// The circom compiler only gives a warning for this:
// warning[T3001]: Typing warning: Mismatched dimensions, assigning to an array an expression of greater length,
//                 the remaining positions of the expression are not assigned to the array.

template LargeToSmall() {
    signal output out[2];
    var temp[2] = [99, 98, 97, 96, 95];
    assert(temp[0] == 99);
    assert(temp[1] == 98);
    out <== temp;
}

component main = LargeToSmall();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@LargeToSmall::@LargeToSmall<[]>>} {
// CHECK-NEXT:    poly.template @LargeToSmall {
// CHECK-NEXT:      struct.def @LargeToSmall {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@LargeToSmall::@LargeToSmall<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@LargeToSmall::@LargeToSmall<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]] to %[[VAL_4]] step %[[VAL_6]] {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_7]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_7]]] = %[[VAL_8]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_10]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_11]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_13]], "assertion failed"
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_15]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  98 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_16]], %[[VAL_17]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_18]], "assertion failed"
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_2]] : <@LargeToSmall::@LargeToSmall<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@LargeToSmall::@LargeToSmall<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@LargeToSmall::@LargeToSmall<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@out] : <@LargeToSmall::@LargeToSmall<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_21]], %[[VAL_21]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_25]] to %[[VAL_24]] step %[[VAL_26]] {
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_23]]{{\[}}%[[VAL_27]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_22]]{{\[}}%[[VAL_27]]] = %[[VAL_28]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_30]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_31]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_33]], "assertion failed"
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_35]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  98 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_36]], %[[VAL_37]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_38]], "assertion failed"
// CHECK-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_22]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<5 x !felt.type<"bn128">> = [ 99 : <"bn128">,  98 : <"bn128">,  97 : <"bn128">,  96 : <"bn128">,  95 : <"bn128">]
// CHECK-NEXT:  }
