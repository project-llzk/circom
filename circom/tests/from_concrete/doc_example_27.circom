// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template Bits2Num(n) {
    signal input in[n];
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_1::@A_1<[]>>} {
// CHECK-NEXT:    poly.template @A_1 {
// CHECK-NEXT:      struct.def @A_1 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @b : !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[@in: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_1::@A_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_1::@A_1<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          pod.write %[[VAL_5]][@in] = %[[VAL_0]] : <[@in: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_6]], %[[VAL_7]] : index
// CHECK-NEXT:          pod.write %[[VAL_4]][@count] = %[[VAL_8]] : <[@count: index, @comp: !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_8]], %[[VAL_9]] : index
// CHECK-NEXT:          scf.if %[[VAL_10]] {
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@params] : <[@count: index, @comp: !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = function.call @Bits2Num_0::@Bits2Num_0::@compute(%[[VAL_12]]) : (!array.type<10 x !felt.type<"bn128">>) -> !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_4]][@comp] = %[[VAL_13]] : <[@count: index, @comp: !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@out] : <@Bits2Num_0::@Bits2Num_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_15]] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@b$inputs] = %[[VAL_5]] : <@A_1::@A_1<[]>>, !pod.type<[@in: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_16]] : <@A_1::@A_1<[]>>, !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_1::@A_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@A_1::@A_1<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@A_1::@A_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@b] : <@A_1::@A_1<[]>>, !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@b$inputs] : <@A_1::@A_1<[]>>, !pod.type<[@in: !array.type<10 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@in] : <[@in: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_18]] : !array.type<10 x !felt.type<"bn128">>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@out] : <@Bits2Num_0::@Bits2Num_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_19]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@in] : <[@in: !array.type<10 x !felt.type<"bn128">>]>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Bits2Num_0::@Bits2Num_0::@constrain(%[[VAL_20]], %[[VAL_24]]) : (!struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, !array.type<10 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Bits2Num_0 {
// CHECK-NEXT:      struct.def @Bits2Num_0 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Bits2Num_0::@Bits2Num_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_29]], %[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_30]], %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_28]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_33]], %[[VAL_35]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_36]]) %[[VAL_32]], %[[VAL_33]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_40]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_41]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_37]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_44]], %[[VAL_46]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_26]][@out] = %[[VAL_31]]#2 : <@Bits2Num_0::@Bits2Num_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_26]] : !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !struct.type<@Bits2Num_0::@Bits2Num_0<[]>>, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_47]][@out] : <@Bits2Num_0::@Bits2Num_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_52]], %[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_53]], %[[VAL_57:[0-9a-zA-Z_\.]+]] = %[[VAL_51]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_56]], %[[VAL_58]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_59]]) %[[VAL_55]], %[[VAL_56]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_63]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_64]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_60]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_61]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_67]], %[[VAL_69]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_49]], %[[VAL_54]]#2 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
