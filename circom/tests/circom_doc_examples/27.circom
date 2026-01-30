// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template Bits2Num(n) {
    signal input {binary} in[n];
    signal output out;
    var lc1=0;

    var e2 = 1;
    for (var i = 0; i<n; i++) {
        lc1 += in[i] * e2;
        e2 = e2 + e2;
    }

    lc1 ==> out;
}

template A(){
    signal input a[10];
    signal output out;
    component b = Bits2Num(10);
    b.in <== a;
    out <== b.out;
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @b : !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>) -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @Bits2Num::@compute(%[[VAL_0]]) : (!array.type<10 x !felt.type>) -> !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_2]][@out] : <@Bits2Num<[10]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_3]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@b] = %[[VAL_2]] : <@A<[]>>, !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@b] : <@A<[]>>, !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:        function.call @Bits2Num::@constrain(%[[VAL_6]], %[[VAL_5]]) : (!struct.type<@Bits2Num<[10]>>, !array.type<10 x !felt.type>) -> ()
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_6]][@out] : <@Bits2Num<[10]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_8]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Bits2Num<[@n]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Bits2Num<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@Bits2Num<[@n]>>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_13]], %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_12]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_11]])
// CHECK-NEXT:          scf.condition(%[[VAL_19]]) %[[VAL_16]], %[[VAL_17]], %[[VAL_18]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_23]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_24]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_20]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_28]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_27]], %[[VAL_29]], %[[VAL_26]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_10]][@out] = %[[VAL_15]]#2 : <@Bits2Num<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_10]] : !struct.type<@Bits2Num<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@Bits2Num<[@n]>>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_30]][@out] : <@Bits2Num<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_34]], %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_35]], %[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_38]], %[[VAL_32]])
// CHECK-NEXT:          scf.condition(%[[VAL_40]]) %[[VAL_37]], %[[VAL_38]], %[[VAL_39]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]]
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_44]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_45]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_46]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_41]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_49]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_48]], %[[VAL_50]], %[[VAL_47]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_51]], %[[VAL_36]]#2 : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
