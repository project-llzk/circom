// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function ignore(x) {
    return 0;
}

template Producer() {
    signal output out[4][4];
    out[0][0] <== 1;
}

template T() {
    component p = Producer();
    signal output y;

    // The rank of the input to `ignore` is only from internal knowledge of `Producer`.
    y <== ignore(p.out);
}

component main = T();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@T::@T<[]>>} {
// CHECK-NEXT:    poly.template @ignore {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @ignore(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "x"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_2]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Producer {
// CHECK-NEXT:      struct.def @Producer {
// CHECK-NEXT:        struct.member @out : !array.type<4,4 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Producer::@Producer<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@Producer::@Producer<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<4,4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_7]], %[[VAL_9]]] = %[[VAL_5]] : <4,4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@out] = %[[VAL_4]] : <@Producer::@Producer<[]>>, !array.type<4,4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@Producer::@Producer<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@Producer::@Producer<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_10]][@out] : <@Producer::@Producer<[]>>, !array.type<4,4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_14]], %[[VAL_16]]] : <4,4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_17]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @T {
// CHECK-NEXT:      struct.def @T {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @p : !struct.type<@Producer::@Producer<[]>>
// CHECK-NEXT:        struct.member @p$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@T::@T<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.new : <@T::@T<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = function.call @Producer::@Producer::@compute() : () -> !struct.type<@Producer::@Producer<[]>>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@Producer::@Producer<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @Producer::@Producer::@compute() : () -> !struct.type<@Producer::@Producer<[]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_26]] }  : <[@count: index, @comp: !struct.type<@Producer::@Producer<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@comp] : <[@count: index, @comp: !struct.type<@Producer::@Producer<[]>>, @params: !pod.type<[]>]>, !struct.type<@Producer::@Producer<[]>>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@out] : <@Producer::@Producer<[]>>, !array.type<4,4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = function.call @ignore::@ignore(%[[VAL_29]]) : (!array.type<4,4 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_18]][@y] = %[[VAL_30]] : <@T::@T<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_18]][@p$inputs] = %[[VAL_23]] : <@T::@T<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@comp] : <[@count: index, @comp: !struct.type<@Producer::@Producer<[]>>, @params: !pod.type<[]>]>, !struct.type<@Producer::@Producer<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_18]][@p] = %[[VAL_31]] : <@T::@T<[]>>, !struct.type<@Producer::@Producer<[]>>
// CHECK-NEXT:          function.return %[[VAL_18]] : !struct.type<@T::@T<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@T::@T<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@y] : <@T::@T<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@p] : <@T::@T<[]>>, !struct.type<@Producer::@Producer<[]>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@p$inputs] : <@T::@T<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Producer::@Producer<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@out] : <@Producer::@Producer<[]>>, !array.type<4,4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @ignore::@ignore(%[[VAL_38]]) : (!array.type<4,4 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_33]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Producer::@Producer::@constrain(%[[VAL_34]]) : (!struct.type<@Producer::@Producer<[]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
