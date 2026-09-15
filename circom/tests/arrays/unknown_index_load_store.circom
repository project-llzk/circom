// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template UnknownIndexLoadStore() {
    signal input in;
    signal output out[8];

    var unused1[9] = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    var arr2[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    var unused2[11] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    out[in] <-- arr2[in];
}

component main = UnknownIndexLoadStore();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@UnknownIndexLoadStore::@UnknownIndexLoadStore<[]>>} {
// CHECK-NEXT:    poly.template @UnknownIndexLoadStore {
// CHECK-NEXT:      struct.def @UnknownIndexLoadStore {
// CHECK-NEXT:        struct.member @out : !array.type<8 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@UnknownIndexLoadStore::@UnknownIndexLoadStore<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownIndexLoadStore::@UnknownIndexLoadStore<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]] : <9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = global.read const @array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]] : <11 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = global.read const @array_const_2 : !array.type<11 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_12]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_14]]] = %[[VAL_13]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@UnknownIndexLoadStore::@UnknownIndexLoadStore<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@UnknownIndexLoadStore::@UnknownIndexLoadStore<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownIndexLoadStore::@UnknownIndexLoadStore<[]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@out] : <@UnknownIndexLoadStore::@UnknownIndexLoadStore<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_18]], %[[VAL_18]], %[[VAL_18]], %[[VAL_18]], %[[VAL_18]], %[[VAL_18]], %[[VAL_18]], %[[VAL_18]], %[[VAL_18]] : <9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_21]], %[[VAL_21]], %[[VAL_21]], %[[VAL_21]], %[[VAL_21]], %[[VAL_21]], %[[VAL_21]], %[[VAL_21]], %[[VAL_21]], %[[VAL_21]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = global.read const @array_const_1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_24]], %[[VAL_24]], %[[VAL_24]], %[[VAL_24]], %[[VAL_24]], %[[VAL_24]], %[[VAL_24]], %[[VAL_24]], %[[VAL_24]], %[[VAL_24]], %[[VAL_24]] : <11 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = global.read const @array_const_2 : !array.type<11 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<9 x !felt.type<"bn128">> = [ 0 : <"bn128">,  1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">,  8 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_1 : !array.type<10 x !felt.type<"bn128">> = [ 0 : <"bn128">,  1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">,  8 : <"bn128">,  9 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_2 : !array.type<11 x !felt.type<"bn128">> = [ 0 : <"bn128">,  1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">,  8 : <"bn128">,  9 : <"bn128">,  10 : <"bn128">]
// CHECK-NEXT:  }
