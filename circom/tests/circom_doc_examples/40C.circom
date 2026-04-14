// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in;
}

template check_bits(n){
  signal input in;
  _ <== Num2Bits(n)(in);
}

component main = check_bits(16);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@check_bits::@check_bits<[16]>>} {
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_6]], %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_11]]) %[[VAL_8]], %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_0]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_15]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_18]]] = %[[VAL_17]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_19]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_20]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_23]], %[[VAL_25]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_31]], %[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_32]], %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_30]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_35]], %[[VAL_28]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_37]]) %[[VAL_34]], %[[VAL_35]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_41]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_43]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_44]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_42]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            constrain.eq %[[VAL_47]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_49]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_50]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_54]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_53]], %[[VAL_55]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_33]]#2, %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @check_bits {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @check_bits {
// CHECK-NEXT:        struct.member @Num2Bits_25_562 : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        struct.member @Num2Bits_25_562$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@check_bits::@check_bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.new : <@check_bits::@check_bits<[@n]>>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_59]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_61]][@in] = %[[VAL_56]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_62]], %[[VAL_63]] : index
// CHECK-NEXT:          pod.write %[[VAL_60]][@count] = %[[VAL_64]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_64]], %[[VAL_65]] : index
// CHECK-NEXT:          scf.if %[[VAL_66]] {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_67]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_60]][@comp] = %[[VAL_68]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_57]][@Num2Bits_25_562$inputs] = %[[VAL_61]] : <@check_bits::@check_bits<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_57]][@Num2Bits_25_562] = %[[VAL_71]] : <@check_bits::@check_bits<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_57]] : !struct.type<@check_bits::@check_bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_72:[0-9a-zA-Z_\.]+]]: !struct.type<@check_bits::@check_bits<[@n]>>, %[[VAL_73:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_72]][@Num2Bits_25_562] : <@check_bits::@check_bits<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_72]][@Num2Bits_25_562$inputs] : <@check_bits::@check_bits<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_77]], %[[VAL_73]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_75]], %[[VAL_79]]) : (!struct.type<@Num2Bits::@Num2Bits<[@n]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
