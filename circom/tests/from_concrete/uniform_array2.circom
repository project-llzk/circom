// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template C(n) {
    signal output outp;
    outp <== n;
}

template Caller(n) {
    signal outp[2];

    component c[2];
    for (var i = 0; i < 2; i++) {
      c[i] = C(n);
      outp[i] <== c[i].outp;
    }
}

component main = Caller(5);
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Caller_1::@Caller_1<[]>>} {
// CHECK-NEXT:    poly.template @C_0 {
// CHECK-NEXT:      struct.def @C_0 {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@C_0::@C_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@C_0::@C_0<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@outp] = %[[VAL_2]] : <@C_0::@C_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@C_0::@C_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@C_0::@C_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@outp] : <@C_0::@C_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_4]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Caller_1 {
// CHECK-NEXT:      struct.def @Caller_1 {
// CHECK-NEXT:        struct.member @outp : !array.type<2 x !felt.type<"bn128">> {signal}
// CHECK-NEXT:        struct.member @c : !array.type<2 x !struct.type<@C_0::@C_0<[]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<2 x !pod.type<[]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Caller_1::@Caller_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller_1::@Caller_1<[]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_12]] to %[[VAL_11]] step %[[VAL_13]] {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = function.call @C_0::@C_0::@compute() : () -> !struct.type<@C_0::@C_0<[]>>
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_16]] }  : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_9]]{{\[}}%[[VAL_14]]] = %[[VAL_17]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_26]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@comp] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_0::@C_0<[]>>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@outp] : <@C_0::@C_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_8]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_7]][@c$inputs] = %[[VAL_18]] : <@Caller_1::@Caller_1<[]>>, !array.type<2 x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@C_0::@C_0<[]>>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_35]] to %[[VAL_34]] step %[[VAL_36]] {
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_37]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@comp] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_0::@C_0<[]>>
// CHECK-NEXT:            array.write %[[VAL_33]]{{\[}}%[[VAL_37]]] = %[[VAL_39]] : <2 x !struct.type<@C_0::@C_0<[]>>>, !struct.type<@C_0::@C_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_7]][@c] = %[[VAL_33]] : <@Caller_1::@Caller_1<[]>>, !array.type<2 x !struct.type<@C_0::@C_0<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_7]][@outp] = %[[VAL_8]] : <@Caller_1::@Caller_1<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@Caller_1::@Caller_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller_1::@Caller_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_40]][@outp] : <@Caller_1::@Caller_1<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_40]][@c] : <@Caller_1::@Caller_1<[]>>, !array.type<2 x !struct.type<@C_0::@C_0<[]>>>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_40]][@c$inputs] : <@Caller_1::@Caller_1<[]>>, !array.type<2 x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_47:[0-9a-zA-Z_\.]+]] = %[[VAL_45]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_47]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_49]]) %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_50:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_42]]{{\[}}%[[VAL_51]]] : <2 x !struct.type<@C_0::@C_0<[]>>>, !struct.type<@C_0::@C_0<[]>>
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@outp] : <@C_0::@C_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_54]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_55]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_50]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_59]] to %[[VAL_58]] step %[[VAL_60]] {
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_42]]{{\[}}%[[VAL_61]]] : <2 x !struct.type<@C_0::@C_0<[]>>>, !struct.type<@C_0::@C_0<[]>>
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_61]]] : <2 x !pod.type<[]>>, !pod.type<[]>
// CHECK-NEXT:            function.call @C_0::@C_0::@constrain(%[[VAL_62]]) : (!struct.type<@C_0::@C_0<[]>>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
