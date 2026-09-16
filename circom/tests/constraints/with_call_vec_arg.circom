// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function feeShiftTable(a, i) {
    return a[i];
}

template ComputeFee() {
    signal output feeOut[2];
    var temp[2][2] = [[3,9],[6,7]];

    for (var i = 0; i < 2; i++) {
        feeOut[i] <== feeShiftTable(temp[i], i);
    }
}

component main = ComputeFee();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ComputeFee::@ComputeFee<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<2,2 x !felt.type<"bn128">> = [ 3 : <"bn128">,  9 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @feeShiftTable {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @feeShiftTable(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "i"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> index
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_2]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!poly.tvar<@"$e">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_5]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ComputeFee {
// CHECK-NEXT:      struct.def @ComputeFee {
// CHECK-NEXT:        struct.member @feeOut : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ComputeFee::@ComputeFee<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.new : <@ComputeFee::@ComputeFee<[]>>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_19]]{{\[}}%[[VAL_28]]] : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = function.call @feeShiftTable::@feeShiftTable<[?, ?, ?, ?]>(%[[VAL_29]], %[[VAL_27]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_7]]{{\[}}%[[VAL_31]]] = %[[VAL_30]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_6]][@feeOut] = %[[VAL_7]] : <@ComputeFee::@ComputeFee<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_6]] : !struct.type<@ComputeFee::@ComputeFee<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@ComputeFee::@ComputeFee<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@feeOut] : <@ComputeFee::@ComputeFee<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_50]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_52]], %[[VAL_53]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_54]]) %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_55:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_47]]{{\[}}%[[VAL_56]]] : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = function.call @feeShiftTable::@feeShiftTable<[?, ?, ?, ?]>(%[[VAL_57]], %[[VAL_55]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_59]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_60]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_55]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
