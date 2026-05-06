// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Sum(n) {
    signal input inp[n];
    signal output outp;

    var acc = 0;
    for (var i = 0; i < n; i++) {
        acc += inp[i];
    }

    outp <== acc;
}

template Caller(n) {
    signal input inp[n];
    signal outp;

    component op = Sum(n);
    op.inp <== inp;

    outp <== op.outp;
}

component main = Caller(5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Caller::@Caller<[5]>>} {
// CHECK-NEXT:    poly.template @Caller {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Caller {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @op : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        struct.member @op$inputs : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Caller::@Caller<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller::@Caller<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_4]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_3]][@inp] = %[[VAL_0]] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_8]], %[[VAL_9]] : index
// CHECK-NEXT:          pod.write %[[VAL_7]][@count] = %[[VAL_10]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_10]], %[[VAL_11]] : index
// CHECK-NEXT:          scf.if %[[VAL_12]] {
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_14]]) : (!array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_7]][@comp] = %[[VAL_15]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_17]] : <@Caller::@Caller<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@op$inputs] = %[[VAL_3]] : <@Caller::@Caller<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@op] = %[[VAL_18]] : <@Caller::@Caller<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Caller::@Caller<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller::@Caller<[@n]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@outp] : <@Caller::@Caller<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@op] : <@Caller::@Caller<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@op$inputs] : <@Caller::@Caller<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_25]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_28]], %[[VAL_20]] : !array.type<@n x !felt.type<"bn128">>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_23]], %[[VAL_30]]) : (!struct.type<@Sum::@Sum<[@n]>>, !array.type<@n x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_34]], %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_35]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_38]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_39]]) %[[VAL_37]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_42]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_44]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_32]][@outp] = %[[VAL_36]]#0 : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_32]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_47]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_51]], %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_52]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_55]], %[[VAL_49]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_56]]) %[[VAL_54]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_57:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_58:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_59]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_57]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_58]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_61]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_50]], %[[VAL_53]]#0 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
