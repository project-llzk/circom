// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Caller_1::@Caller_1<[]>>} {
// CHECK-NEXT:    poly.template @Caller_1 {
// CHECK-NEXT:      struct.def @Caller_1 {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @op : !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:        struct.member @op$inputs : !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">>) -> !struct.type<@Caller_1::@Caller_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller_1::@Caller_1<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          pod.write %[[VAL_3]][@inp] = %[[VAL_0]] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@count] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_5]], %[[VAL_6]] : index
// CHECK-NEXT:          pod.write %[[VAL_2]][@count] = %[[VAL_7]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_7]], %[[VAL_8]] : index
// CHECK-NEXT:          scf.if %[[VAL_9]] {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@params] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @Sum_0::@Sum_0::@compute(%[[VAL_11]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_2]][@comp] = %[[VAL_12]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_14]] : <@Caller_1::@Caller_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@op$inputs] = %[[VAL_3]] : <@Caller_1::@Caller_1<[]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@op] = %[[VAL_15]] : <@Caller_1::@Caller_1<[]>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Caller_1::@Caller_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller_1::@Caller_1<[]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@outp] : <@Caller_1::@Caller_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@op] : <@Caller_1::@Caller_1<[]>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@op$inputs] : <@Caller_1::@Caller_1<[]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_17]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_18]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum_0::@Sum_0::@constrain(%[[VAL_19]], %[[VAL_24]]) : (!struct.type<@Sum_0::@Sum_0<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum_0 {
// CHECK-NEXT:      struct.def @Sum_0 {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">>) -> !struct.type<@Sum_0::@Sum_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_28]], %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_29]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_32]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_34]]) %[[VAL_31]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_37]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_39]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_26]][@outp] = %[[VAL_30]]#0 : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_26]] : !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_42:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum_0::@Sum_0<[]>>, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_42]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_49:[0-9a-zA-Z_\.]+]] = %[[VAL_46]], %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_47]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_50]], %[[VAL_51]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_52]]) %[[VAL_49]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_54:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_55]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_53]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_54]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_57]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_44]], %[[VAL_48]]#0 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
