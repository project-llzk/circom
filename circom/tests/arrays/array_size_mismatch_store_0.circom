// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// The circom compiler only gives a warning for this:
// warning[T3001]: Typing warning: Mismatched dimensions, assigning to an array an expression of smaller length,
//                 the remaining positions are not modified. Initially all variables are initialized to 0.

template ImplicitExtension() {
    signal output out[10];
    var temp[10] = [99, 98, 97, 96, 95];
    out[0] <-- temp[0];
    out[4] <-- temp[4];
    out[5] <-- temp[5];
    out[9] <-- temp[9];
}

component main = ImplicitExtension();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ImplicitExtension::@ImplicitExtension<[]>>} {
// CHECK-NEXT:    poly.template @ImplicitExtension {
// CHECK-NEXT:      struct.def @ImplicitExtension {
// CHECK-NEXT:        struct.member @out : !array.type<10 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ImplicitExtension::@ImplicitExtension<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ImplicitExtension::@ImplicitExtension<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_5]] step %[[VAL_7]] {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_8]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_8]]] = %[[VAL_9]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_11]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_14]]] = %[[VAL_12]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_16]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_21]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_24]]] = %[[VAL_22]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_26]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_29]]] = %[[VAL_27]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_1]] : <@ImplicitExtension::@ImplicitExtension<[]>>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@ImplicitExtension::@ImplicitExtension<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@ImplicitExtension::@ImplicitExtension<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@out] : <@ImplicitExtension::@ImplicitExtension<[]>>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_32]], %[[VAL_32]], %[[VAL_32]], %[[VAL_32]], %[[VAL_32]], %[[VAL_32]], %[[VAL_32]], %[[VAL_32]], %[[VAL_32]], %[[VAL_32]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_36]] to %[[VAL_35]] step %[[VAL_37]] {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_38]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_33]]{{\[}}%[[VAL_38]]] = %[[VAL_39]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<5 x !felt.type<"bn128">> = [ 99 : <"bn128">,  98 : <"bn128">,  97 : <"bn128">,  96 : <"bn128">,  95 : <"bn128">]
// CHECK-NEXT:  }
