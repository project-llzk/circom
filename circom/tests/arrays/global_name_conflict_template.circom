// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s
// END.

pragma circom 2.0.0;

function literal() {
    var values[2] = [1, 2];
    return values[0];
}

template global() {
    signal output out <== literal();
}

template Main() {
    component child = global();
    signal output out <== child.out;
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// CHECK-NEXT:    module @global_ {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<2 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @literal {
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @literal() -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = global.read const @global_::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = global.read const @global_::@array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_3]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_5]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @child : !struct.type<@global::@global<[]>>
// CHECK-NEXT:        struct.member @child$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = function.call @global::@global::@compute() : () -> !struct.type<@global::@global<[]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_9]] }  : <[@count: index, @comp: !struct.type<@global::@global<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @global::@global::@compute() : () -> !struct.type<@global::@global<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_14]] }  : <[@count: index, @comp: !struct.type<@global::@global<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@comp] : <[@count: index, @comp: !struct.type<@global::@global<[]>>, @params: !pod.type<[]>]>, !struct.type<@global::@global<[]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@out] : <@global::@global<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_6]][@out] = %[[VAL_17]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_6]][@child$inputs] = %[[VAL_11]] : <@Main::@Main<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@comp] : <[@count: index, @comp: !struct.type<@global::@global<[]>>, @params: !pod.type<[]>]>, !struct.type<@global::@global<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@child] = %[[VAL_18]] : <@Main::@Main<[]>>, !struct.type<@global::@global<[]>>
// CHECK-NEXT:          function.return %[[VAL_6]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@out] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@child] : <@Main::@Main<[]>>, !struct.type<@global::@global<[]>>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@child$inputs] : <@Main::@Main<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@global::@global<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@global::@global<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.call @global::@global::@constrain(%[[VAL_21]]) : (!struct.type<@global::@global<[]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @global {
// CHECK-NEXT:      struct.def @global {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@global::@global<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@global::@global<[]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = function.call @literal::@literal() : () -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_26]][@out] = %[[VAL_27]] : <@global::@global<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_26]] : !struct.type<@global::@global<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !struct.type<@global::@global<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@out] : <@global::@global<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = function.call @literal::@literal() : () -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_29]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
