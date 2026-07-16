// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function identity(n) {
   return n;
}

function short_div(n) {
    var ret;
    if (n != 0) {
	    ret = identity(n);
    }
    return ret;
}

function long_div(n) {
    var out[1];
    out[0] = short_div(n);
    return out;
}

template BigModOld(n) {
    var r[1] = long_div(n);
}

component main = BigModOld(2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@BigModOld::@BigModOld<[2]>>} {
// CHECK-NEXT:    poly.template @identity {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @identity(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "n"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_1]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @long_div {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @long_div(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "n"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = function.call @short_div::@short_div(%[[VAL_2]]) : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_4]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!array.type<1 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_8]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @short_div {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @short_div(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "n"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_9]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_12]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_13]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @identity::@identity(%[[VAL_9]]) : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_14]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_16]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @BigModOld {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @BigModOld {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@BigModOld::@BigModOld<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.new : <@BigModOld::@BigModOld<[@n]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_19]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = function.call @long_div::@long_div(%[[VAL_18]]) : (!felt.type<"bn128">) -> !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_17]] : !struct.type<@BigModOld::@BigModOld<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !struct.type<@BigModOld::@BigModOld<[@n]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_24]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @long_div::@long_div(%[[VAL_23]]) : (!felt.type<"bn128">) -> !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
