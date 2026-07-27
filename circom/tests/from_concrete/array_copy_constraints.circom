// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Caller_1::@Caller_1<[]>>} {
// CHECK-NEXT:    poly.template @Caller_1 {
// CHECK-NEXT:      struct.def @Caller_1 {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {signal}
// CHECK-NEXT:        struct.member @op : !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:        struct.member @op$inputs : !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Caller_1::@Caller_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller_1::@Caller_1<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          pod.write %[[VAL_5]][@inp] = %[[VAL_0]] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_7]], %[[VAL_8]] : index
// CHECK-NEXT:          pod.write %[[VAL_4]][@count] = %[[VAL_9]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_9]], %[[VAL_10]] : index
// CHECK-NEXT:          scf.if %[[VAL_11]] {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@params] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @Sum_0::@Sum_0::@compute(%[[VAL_13]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_4]][@comp] = %[[VAL_14]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_16]] : <@Caller_1::@Caller_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@op$inputs] = %[[VAL_5]] : <@Caller_1::@Caller_1<[]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@op] = %[[VAL_17]] : <@Caller_1::@Caller_1<[]>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Caller_1::@Caller_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller_1::@Caller_1<[]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@outp] : <@Caller_1::@Caller_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@op] : <@Caller_1::@Caller_1<[]>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@op$inputs] : <@Caller_1::@Caller_1<[]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_19]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum_0::@Sum_0::@constrain(%[[VAL_21]], %[[VAL_26]]) : (!struct.type<@Sum_0::@Sum_0<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum_0 {
// CHECK-NEXT:      struct.def @Sum_0 {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum_0::@Sum_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_30]], %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_31]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_34]], %[[VAL_35]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_36]]) %[[VAL_33]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_39]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_37]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_41]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_28]][@outp] = %[[VAL_32]]#0 : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_28]] : !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum_0::@Sum_0<[]>>, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_44]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_51:[0-9a-zA-Z_\.]+]] = %[[VAL_48]], %[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_49]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_52]], %[[VAL_53]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_54]]) %[[VAL_51]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_55:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_57]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_55]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_59]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_46]], %[[VAL_50]]#0 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
