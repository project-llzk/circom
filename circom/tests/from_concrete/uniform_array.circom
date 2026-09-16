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

template Caller(n, m) {
    signal input inp[m][n];
    signal inter[m];
    signal outp;

    component step1[m];
    for (var i = 0; i < m; i++) {
      step1[i] = Sum(n);
      step1[i].inp <== inp[i];
      inter[i] <== step1[i].outp;
    }

    component step2 = Sum(m);
    step2.inp <== inter;
    outp <== step2.outp;
}

component main = Caller(5, 3);
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Caller_2::@Caller_2<[]>>} {
// CHECK-NEXT:    poly.template @Caller_2 {
// CHECK-NEXT:      struct.def @Caller_2 {
// CHECK-NEXT:        struct.member @inter : !array.type<3 x !felt.type<"bn128">> {signal}
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {signal}
// CHECK-NEXT:        struct.member @step1 : !array.type<3 x !struct.type<@Sum_0::@Sum_0<[]>>>
// CHECK-NEXT:        struct.member @step1$inputs : !array.type<3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        struct.member @step2 : !struct.type<@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:        struct.member @step2$inputs : !pod.type<[@inp: !array.type<3 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<3,5 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Caller_2::@Caller_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller_2::@Caller_2<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_5]] step %[[VAL_7]] {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_8]]] = %[[VAL_10]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_13]], @params = %[[VAL_12]] }  : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!felt.type<"bn128">, !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_20]], %[[VAL_21]], %[[VAL_22]] : !felt.type<"bn128">, !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_0]]{{\[}}%[[VAL_28]]] : <3,5 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_30]]] : <3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_31]][@inp] = %[[VAL_29]] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_32]]] = %[[VAL_31]] : <3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_33]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_35]]] : <3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:            pod.write %[[VAL_34]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:            scf.if %[[VAL_41]] {
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@params] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @Sum_0::@Sum_0::@compute(%[[VAL_43]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:              pod.write %[[VAL_34]][@comp] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_26]]{{\[}}%[[VAL_45]]] = %[[VAL_34]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_46]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_50]]] = %[[VAL_49]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_52]], %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !array.type<3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !array.type<3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_15]][@inp] = %[[VAL_2]] : <[@inp: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@count] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// CHECK-NEXT:          pod.write %[[VAL_14]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:          scf.if %[[VAL_57]] {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@params] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@inp] : <[@inp: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = function.call @Sum_1::@Sum_1::@compute(%[[VAL_59]]) : (!array.type<3 x !felt.type<"bn128">>) -> !struct.type<@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:            pod.write %[[VAL_14]][@comp] = %[[VAL_60]] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@comp] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@outp] : <@Sum_1::@Sum_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_62]] : <@Caller_2::@Caller_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@step1$inputs] = %[[VAL_19]]#2 : <@Caller_2::@Caller_2<[]>>, !array.type<3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.new  : <3 x !struct.type<@Sum_0::@Sum_0<[]>>>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_65]] to %[[VAL_64]] step %[[VAL_66]] {
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]#1{{\[}}%[[VAL_67]]] : <3 x !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            array.write %[[VAL_63]]{{\[}}%[[VAL_67]]] = %[[VAL_69]] : <3 x !struct.type<@Sum_0::@Sum_0<[]>>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@step1] = %[[VAL_63]] : <@Caller_2::@Caller_2<[]>>, !array.type<3 x !struct.type<@Sum_0::@Sum_0<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@step2$inputs] = %[[VAL_15]] : <@Caller_2::@Caller_2<[]>>, !pod.type<[@inp: !array.type<3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@comp] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@step2] = %[[VAL_70]] : <@Caller_2::@Caller_2<[]>>, !struct.type<@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@inter] = %[[VAL_2]] : <@Caller_2::@Caller_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Caller_2::@Caller_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller_2::@Caller_2<[]>>, %[[VAL_72:[0-9a-zA-Z_\.]+]]: !array.type<3,5 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@inter] : <@Caller_2::@Caller_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@outp] : <@Caller_2::@Caller_2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@step1] : <@Caller_2::@Caller_2<[]>>, !array.type<3 x !struct.type<@Sum_0::@Sum_0<[]>>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@step1$inputs] : <@Caller_2::@Caller_2<[]>>, !array.type<3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@step2] : <@Caller_2::@Caller_2<[]>>, !struct.type<@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@step2$inputs] : <@Caller_2::@Caller_2<[]>>, !pod.type<[@inp: !array.type<3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_81]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_83]], %[[VAL_84]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_85]]) %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_72]]{{\[}}%[[VAL_87]]] : <3,5 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_89]]] : <3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_91]], %[[VAL_88]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_92]]] : <3 x !struct.type<@Sum_0::@Sum_0<[]>>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_95]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_96]], %[[VAL_94]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_97]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_98]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]][@inp] : <[@inp: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_99]], %[[VAL_73]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@outp] : <@Sum_1::@Sum_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_74]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]] to %[[VAL_101]] step %[[VAL_103]] {
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_104]]] : <3 x !struct.type<@Sum_0::@Sum_0<[]>>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_104]]] : <3 x !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@inp] : <[@inp: !array.type<5 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Sum_0::@Sum_0::@constrain(%[[VAL_105]], %[[VAL_107]]) : (!struct.type<@Sum_0::@Sum_0<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]][@inp] : <[@inp: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum_1::@Sum_1::@constrain(%[[VAL_77]], %[[VAL_108]]) : (!struct.type<@Sum_1::@Sum_1<[]>>, !array.type<3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum_0 {
// CHECK-NEXT:      struct.def @Sum_0 {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_109:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum_0::@Sum_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_115:[0-9a-zA-Z_\.]+]] = %[[VAL_112]], %[[VAL_116:[0-9a-zA-Z_\.]+]] = %[[VAL_113]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_116]], %[[VAL_117]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_118]]) %[[VAL_115]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_119:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_120:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_109]]{{\[}}%[[VAL_121]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_119]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_120]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_123]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_110]][@outp] = %[[VAL_114]]#0 : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_110]] : !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_126:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum_0::@Sum_0<[]>>, %[[VAL_127:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_126]][@outp] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_130]], %[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_131]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_134]], %[[VAL_135]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_136]]) %[[VAL_133]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_137:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_139]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_137]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_138]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_141]], %[[VAL_143]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_128]], %[[VAL_132]]#0 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum_1 {
// CHECK-NEXT:      struct.def @Sum_1 {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_144:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum_1::@Sum_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_150:[0-9a-zA-Z_\.]+]] = %[[VAL_147]], %[[VAL_151:[0-9a-zA-Z_\.]+]] = %[[VAL_148]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_151]], %[[VAL_152]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_153]]) %[[VAL_150]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_154:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_155:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_144]]{{\[}}%[[VAL_156]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_154]], %[[VAL_157]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_155]], %[[VAL_159]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_158]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_145]][@outp] = %[[VAL_149]]#0 : <@Sum_1::@Sum_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_145]] : !struct.type<@Sum_1::@Sum_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_161:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum_1::@Sum_1<[]>>, %[[VAL_162:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_161]][@outp] : <@Sum_1::@Sum_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_168:[0-9a-zA-Z_\.]+]] = %[[VAL_165]], %[[VAL_169:[0-9a-zA-Z_\.]+]] = %[[VAL_166]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_169]], %[[VAL_170]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_171]]) %[[VAL_168]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_172:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_173:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_173]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_162]]{{\[}}%[[VAL_174]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_172]], %[[VAL_175]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_173]], %[[VAL_177]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_176]], %[[VAL_178]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_163]], %[[VAL_167]]#0 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
