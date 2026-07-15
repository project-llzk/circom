// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @b : !struct.type<@Bits2Num::@Bits2Num<[10]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[@in: !array.type<10 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_3]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@Bits2Num::@Bits2Num<[10]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          pod.write %[[VAL_2]][@in] = %[[VAL_0]] : <[@in: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@Bits2Num::@Bits2Num<[10]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_7]], %[[VAL_8]] : index
// CHECK-NEXT:          pod.write %[[VAL_6]][@count] = %[[VAL_9]] : <[@count: index, @comp: !struct.type<@Bits2Num::@Bits2Num<[10]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_9]], %[[VAL_10]] : index
// CHECK-NEXT:          scf.if %[[VAL_11]] {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@Bits2Num::@Bits2Num<[10]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @Bits2Num::@Bits2Num::@compute(%[[VAL_13]]) : (!array.type<10 x !felt.type<"bn128">>) -> !struct.type<@Bits2Num::@Bits2Num<[10]>>
// CHECK-NEXT:            pod.write %[[VAL_6]][@comp] = %[[VAL_14]] : <[@count: index, @comp: !struct.type<@Bits2Num::@Bits2Num<[10]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Bits2Num::@Bits2Num<[10]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@Bits2Num::@Bits2Num<[10]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Bits2Num::@Bits2Num<[10]>>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@out] : <@Bits2Num::@Bits2Num<[10]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_16]] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@b$inputs] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@in: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@Bits2Num::@Bits2Num<[10]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Bits2Num::@Bits2Num<[10]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_17]] : <@A::@A<[]>>, !struct.type<@Bits2Num::@Bits2Num<[10]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@out] : <@A::@A<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@b] : <@A::@A<[]>>, !struct.type<@Bits2Num::@Bits2Num<[10]>>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@b$inputs] : <@A::@A<[]>>, !pod.type<[@in: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_23]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Bits2Num::@Bits2Num<[10]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@in] : <[@in: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_26]], %[[VAL_19]] : !array.type<10 x !felt.type<"bn128">>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@Bits2Num::@Bits2Num<[10]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@in] : <[@in: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Bits2Num::@Bits2Num::@constrain(%[[VAL_21]], %[[VAL_28]]) : (!struct.type<@Bits2Num::@Bits2Num<[10]>>, !array.type<10 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Bits2Num {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Bits2Num {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Bits2Num::@Bits2Num<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.new : <@Bits2Num::@Bits2Num<[@n]>>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_31]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_34]], %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_35]], %[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_38]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_40]]) %[[VAL_37]], %[[VAL_38]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_44]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_45]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_48]], %[[VAL_50]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_30]][@out] = %[[VAL_36]]#2 : <@Bits2Num::@Bits2Num<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_30]] : !struct.type<@Bits2Num::@Bits2Num<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_51:[0-9a-zA-Z_\.]+]]: !struct.type<@Bits2Num::@Bits2Num<[@n]>>, %[[VAL_52:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_53]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_51]][@out] : <@Bits2Num::@Bits2Num<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_58]], %[[VAL_62:[0-9a-zA-Z_\.]+]] = %[[VAL_56]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_61]], %[[VAL_54]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_63]]) %[[VAL_60]], %[[VAL_61]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_66:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_67]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_68]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_66]], %[[VAL_69]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_64]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_65]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_71]], %[[VAL_73]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_55]], %[[VAL_59]]#2 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
