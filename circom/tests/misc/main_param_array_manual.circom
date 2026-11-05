// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Manually converted from `main_param_array.circom` to avoid the array parameter to the main function.

template T(n, S) {
    signal output out[n] <== S;
}

template MainWrapper() {
    component a = T(5, [11,22,33,44,55]);
    signal output out[5] <== a.out;
}

component main = MainWrapper();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@MainWrapper::@MainWrapper<[]>>} {
// CHECK-NEXT:    poly.template @MainWrapper {
// CHECK-NEXT:      struct.def @MainWrapper {
// CHECK-NEXT:        struct.member @out : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a : !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@MainWrapper::@MainWrapper<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@MainWrapper::@MainWrapper<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @T$arrays$1_5::@T$arrays$1_5::@compute() : () -> !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @"$array$S$0": !felt.type<"bn128">, @"$array$S$1": !felt.type<"bn128">, @"$array$S$2": !felt.type<"bn128">, @"$array$S$3": !felt.type<"bn128">, @"$array$S$4": !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @"$array$S$0": !felt.type<"bn128">, @"$array$S$1": !felt.type<"bn128">, @"$array$S$2": !felt.type<"bn128">, @"$array$S$3": !felt.type<"bn128">, @"$array$S$4": !felt.type<"bn128">]>]>, !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]] : (!array.type<? x !felt.type<"bn128">>) -> !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_6]] : <@MainWrapper::@MainWrapper<[]>>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@a$inputs] = %[[VAL_1]] : <@MainWrapper::@MainWrapper<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>, @params: !pod.type<[@n: !felt.type<"bn128">, @"$array$S$0": !felt.type<"bn128">, @"$array$S$1": !felt.type<"bn128">, @"$array$S$2": !felt.type<"bn128">, @"$array$S$3": !felt.type<"bn128">, @"$array$S$4": !felt.type<"bn128">]>]>, !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@a] = %[[VAL_7]] : <@MainWrapper::@MainWrapper<[]>>, !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@MainWrapper::@MainWrapper<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@MainWrapper::@MainWrapper<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_8]][@out] : <@MainWrapper::@MainWrapper<[]>>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_8]][@a] : <@MainWrapper::@MainWrapper<[]>>, !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_8]][@a$inputs] : <@MainWrapper::@MainWrapper<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_10]][@out] : <@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_9]], %[[VAL_12]] : !array.type<5 x !felt.type<"bn128">>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @T$arrays$1_5::@T$arrays$1_5::@constrain(%[[VAL_10]]) : (!struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @T$arrays$1_5 {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.param @"$array$S$0"
// CHECK-NEXT:      poly.param @"$array$S$1"
// CHECK-NEXT:      poly.param @"$array$S$2"
// CHECK-NEXT:      poly.param @"$array$S$3"
// CHECK-NEXT:      poly.param @"$array$S$4"
// CHECK-NEXT:      struct.def @T$arrays$1_5 {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.new : <@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$1" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$2" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$3" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$4" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_14]], %[[VAL_15]], %[[VAL_16]], %[[VAL_17]], %[[VAL_18]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_21]] : (!array.type<5 x !felt.type<"bn128">>) -> !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_13]][@out] = %[[VAL_22]] : <@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$1" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$2" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$3" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$4" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_29]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@out] : <@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_24]], %[[VAL_25]], %[[VAL_26]], %[[VAL_27]], %[[VAL_28]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_31]], %[[VAL_32]] : !array.type<@n x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
