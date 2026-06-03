// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// The circom compiler only gives a warning for this:
// warning[T3001]: Typing warning: Mismatched dimensions, assigning to an array an expression of smaller length, the remaining positions are assigned to 0.

function smaller() {
    return [99, 98, 97, 96, 95];
}

template ImplicitExtension() {
    signal output out[10];
    var temp[10] = smaller();
    out[0] <-- temp[0];
    out[4] <-- temp[4];
    out[5] <-- temp[5];
    out[9] <-- temp[9];
}

component main = ImplicitExtension();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ImplicitExtension::@ImplicitExtension<[]>>} {
// CHECK-NEXT:    poly.template @smaller {
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @smaller() -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  98 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  97 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  96 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  95 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_0]], %[[VAL_1]], %[[VAL_2]], %[[VAL_3]], %[[VAL_4]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]] : (!array.type<5 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_6]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ImplicitExtension {
// CHECK-NEXT:      struct.def @ImplicitExtension {
// CHECK-NEXT:        struct.member @out : !array.type<10 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ImplicitExtension::@ImplicitExtension<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@ImplicitExtension::@ImplicitExtension<[]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @smaller::@smaller() : () -> !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_13]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_8]]{{\[}}%[[VAL_16]]] = %[[VAL_14]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_18]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_8]]{{\[}}%[[VAL_21]]] = %[[VAL_19]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_23]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_8]]{{\[}}%[[VAL_26]]] = %[[VAL_24]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_28]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_8]]{{\[}}%[[VAL_31]]] = %[[VAL_29]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_7]][@out] = %[[VAL_8]] : <@ImplicitExtension::@ImplicitExtension<[]>>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@ImplicitExtension::@ImplicitExtension<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@ImplicitExtension::@ImplicitExtension<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@out] : <@ImplicitExtension::@ImplicitExtension<[]>>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]], %[[VAL_34]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = function.call @smaller::@smaller() : () -> !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
