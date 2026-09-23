// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ForUnknownIndex() {
    signal input in;
    signal output out;

    var arr1[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    var arr2[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    var arr3[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    var acc = 0;
    for (var i = 1; i <= in; i++) {
        acc += i;
    }

    // non-quadractic constraint
    // out <== arr[acc];
    out <-- arr2[acc % 10];
}

component main = ForUnknownIndex();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ForUnknownIndex::@ForUnknownIndex<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<10 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<10 x !felt.type<"bn128">> = [ 0 : <"bn128">,  1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">,  8 : <"bn128">,  9 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ForUnknownIndex {
// CHECK-NEXT:      struct.def @ForUnknownIndex {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@ForUnknownIndex::@ForUnknownIndex<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ForUnknownIndex::@ForUnknownIndex<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_41]], %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_42]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_45]], %[[VAL_0]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_46]]) %[[VAL_44]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_47]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_48]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_49]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_43]]#0, %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_54]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_55]] : <@ForUnknownIndex::@ForUnknownIndex<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ForUnknownIndex::@ForUnknownIndex<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !struct.type<@ForUnknownIndex::@ForUnknownIndex<[]>>, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out] : <@ForUnknownIndex::@ForUnknownIndex<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_98]], %[[VAL_102:[0-9a-zA-Z_\.]+]] = %[[VAL_99]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_102]], %[[VAL_57]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_103]]) %[[VAL_101]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_104:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_105:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_104]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_105]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_106]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
