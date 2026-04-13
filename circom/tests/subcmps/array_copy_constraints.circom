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
// CHECK-NEXT:        struct.member @outp : !felt.type
// CHECK-NEXT:        struct.member @op : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        struct.member @op$inputs : !pod.type<[@inp: !array.type<@n x !felt.type>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Caller::@Caller<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller::@Caller<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@n x !felt.type>]>
// CHECK-NEXT:          pod.write %[[VAL_5]][@inp] = %[[VAL_0]] : <[@inp: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_6]], %[[VAL_7]] : index
// CHECK-NEXT:          pod.write %[[VAL_4]][@count] = %[[VAL_8]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_8]], %[[VAL_9]] : index
// CHECK-NEXT:          scf.if %[[VAL_10]] {
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@inp] : <[@inp: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_11]]) : (!array.type<@n x !felt.type>) -> !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_4]][@comp] = %[[VAL_12]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_14]] : <@Caller::@Caller<[@n]>>, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@op$inputs] = %[[VAL_5]] : <@Caller::@Caller<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type>]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@op] = %[[VAL_15]] : <@Caller::@Caller<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Caller::@Caller<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller::@Caller<[@n]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@outp] : <@Caller::@Caller<[@n]>>, !felt.type
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@op] : <@Caller::@Caller<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@op$inputs] : <@Caller::@Caller<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@inp] : <[@inp: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_17]] : !array.type<@n x !felt.type>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_19]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@inp] : <[@inp: !array.type<@n x !felt.type>]>, !array.type<@n x !felt.type>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_20]], %[[VAL_24]]) : (!struct.type<@Sum::@Sum<[@n]>>, !array.type<@n x !felt.type>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_28]], %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_29]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_32]], %[[VAL_27]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_33]]) %[[VAL_31]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_36]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_37]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_39]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_38]], %[[VAL_40]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_26]][@outp] = %[[VAL_30]]#0 : <@Sum::@Sum<[@n]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_26]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_48:[0-9a-zA-Z_\.]+]] = %[[VAL_45]], %[[VAL_49:[0-9a-zA-Z_\.]+]] = %[[VAL_46]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_49]], %[[VAL_43]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_50]]) %[[VAL_48]], %[[VAL_49]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_51:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_52:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_42]]{{\[}}%[[VAL_53]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_54]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_52]], %[[VAL_56]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_55]], %[[VAL_57]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_44]], %[[VAL_47]]#0 : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
