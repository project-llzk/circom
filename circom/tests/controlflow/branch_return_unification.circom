// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.8;

// Regression test: when both branches of an if/else return arrays of different concrete sizes
// and the function's return type is a type variable (!poly.tvar<@T_return>), code generation
// must not error with "expected array return type when both branches return arrays".
function f(n) {
    if (n == 1) {
        return [1, 2];
    } else {
        return [1, 2, 3];
    }
}

template T() {
    signal output out;
    var x[2] = f(1);
    out <== 0;
}

component main = T();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@T::@T<[]>>} {
// CHECK-NEXT:    poly.template @f {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "n"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_2]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_3]] -> (!poly.tvar<@T_return>) {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_5]], %[[VAL_6]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_7]] : (!array.type<2 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:          scf.yield %[[VAL_8]] : !poly.tvar<@T_return>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_9]], %[[VAL_10]], %[[VAL_11]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_12]] : (!array.type<3 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !poly.tvar<@T_return>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_4]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @T {
// CHECK-NEXT:      struct.def @T {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@T::@T<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.new : <@T::@T<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_15]], %[[VAL_15]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = function.call @f::@f(%[[VAL_17]]) : (!felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_14]][@out] = %[[VAL_19]] : <@T::@T<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_14]] : !struct.type<@T::@T<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@T::@T<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@out] : <@T::@T<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_22]], %[[VAL_22]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = function.call @f::@f(%[[VAL_24]]) : (!felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_21]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
