// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @b : !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:      struct.field @b$inputs : !pod.type<[@in: !array.type<10 x !felt.type>]>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>) -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@Bits2Num<[10]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<10 x !felt.type>]>
// CHECK-NEXT:        pod.write %[[VAL_4]][@in] = %[[VAL_0]] : <[@in: !array.type<10 x !felt.type>]>, !array.type<10 x !felt.type>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@count] : <[@count: index, @comp: !struct.type<@Bits2Num<[10]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_5]], %[[VAL_6]] : index
// CHECK-NEXT:        pod.write %[[VAL_3]][@count] = %[[VAL_7]] : <[@count: index, @comp: !struct.type<@Bits2Num<[10]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_7]], %[[VAL_8]] : index
// CHECK-NEXT:        scf.if %[[VAL_9]] {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<10 x !felt.type>]>, !array.type<10 x !felt.type>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @Bits2Num::@compute(%[[VAL_10]]) : (!array.type<10 x !felt.type>) -> !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:          pod.write %[[VAL_3]][@comp] = %[[VAL_11]] : <[@count: index, @comp: !struct.type<@Bits2Num<[10]>>, @params: !pod.type<[]>]>, !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@Bits2Num<[10]>>, @params: !pod.type<[]>]>, !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_12]][@out] : <@Bits2Num<[10]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_13]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@b$inputs] = %[[VAL_4]] : <@A<[]>>, !pod.type<[@in: !array.type<10 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@Bits2Num<[10]>>, @params: !pod.type<[]>]>, !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:        struct.writef %[[VAL_1]][@b] = %[[VAL_14]] : <@A<[]>>, !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_15]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_15]][@b] : <@A<[]>>, !struct.type<@Bits2Num<[10]>>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_15]][@b$inputs] : <@A<[]>>, !pod.type<[@in: !array.type<10 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@in] : <[@in: !array.type<10 x !felt.type>]>, !array.type<10 x !felt.type>
// CHECK-NEXT:        constrain.eq %[[VAL_20]], %[[VAL_16]] : !array.type<10 x !felt.type>, !array.type<10 x !felt.type>
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_18]][@out] : <@Bits2Num<[10]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_17]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@in] : <[@in: !array.type<10 x !felt.type>]>, !array.type<10 x !felt.type>
// CHECK-NEXT:        function.call @Bits2Num::@constrain(%[[VAL_18]], %[[VAL_22]]) : (!struct.type<@Bits2Num<[10]>>, !array.type<10 x !felt.type>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Bits2Num<[@n]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Bits2Num<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.new : <@Bits2Num<[@n]>>
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_27]], %[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_28]], %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_26]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_31]], %[[VAL_25]])
// CHECK-NEXT:          scf.condition(%[[VAL_33]]) %[[VAL_30]], %[[VAL_31]], %[[VAL_32]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]]
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_23]]{{\[}}%[[VAL_37]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_38]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_39]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_41]], %[[VAL_43]], %[[VAL_40]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_24]][@out] = %[[VAL_29]]#2 : <@Bits2Num<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_24]] : !struct.type<@Bits2Num<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !struct.type<@Bits2Num<[@n]>>, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_44]][@out] : <@Bits2Num<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_49]], %[[VAL_53:[0-9a-zA-Z_\.]+]] = %[[VAL_50]], %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_48]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_53]], %[[VAL_46]])
// CHECK-NEXT:          scf.condition(%[[VAL_55]]) %[[VAL_52]], %[[VAL_53]], %[[VAL_54]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_58:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]]
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_59]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_60]], %[[VAL_49]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_58]], %[[VAL_61]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_56]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_57]], %[[VAL_64]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_63]], %[[VAL_65]], %[[VAL_62]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_47]], %[[VAL_51]]#2 : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
