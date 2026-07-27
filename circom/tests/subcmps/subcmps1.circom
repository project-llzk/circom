// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in != 0 ? 1 / in : 0;

    out <== -in * inv + 1;
    in * out === 0;
}

// Simple circuit that returns what signals are equal to 0
template SubCmps1(n) {
    signal input ins[n];
    signal output outs[n];

    component zeros[n];
    var i;
    for (i = 0; i < n; i++) {
        zeros[i] = IsZero();
        zeros[i].in <== ins[i];
        outs[i] <== zeros[i].out;
    }
}

component main = SubCmps1(3);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@SubCmps1::@SubCmps1<[3]>>} {
// CHECK-NEXT:    poly.template @IsZero {
// CHECK-NEXT:      struct.def @IsZero {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @inv : !felt.type<"bn128"> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@IsZero::@IsZero<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@IsZero::@IsZero<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_0]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_3]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_5]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@inv] = %[[VAL_4]] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_11]] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !struct.type<@IsZero::@IsZero<[]>>, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_12]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_12]][@inv] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_16]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_14]], %[[VAL_19]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmps1 {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @SubCmps1 {
// CHECK-NEXT:        struct.member @outs : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @zeros : !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:        struct.member @zeros$inputs : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "ins"}) -> !struct.type<@SubCmps1::@SubCmps1<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps1::@SubCmps1<[@n]>>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_24]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_30]] to %[[VAL_29]] step %[[VAL_31]] {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_33]], @params = %[[VAL_28]] }  : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_32]]] = %[[VAL_34]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_37]], %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_35]]) : (!felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_39]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_41]]) %[[VAL_39]], %[[VAL_40]] : !felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_45]], @params = %[[VAL_44]] }  : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_47]]] = %[[VAL_46]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_48]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_50]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_51]][@in] = %[[VAL_49]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_43]]{{\[}}%[[VAL_52]]] = %[[VAL_51]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_53]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_55]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@count] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_57]], %[[VAL_58]] : index
// CHECK-NEXT:            pod.write %[[VAL_54]][@count] = %[[VAL_59]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_59]], %[[VAL_60]] : index
// CHECK-NEXT:            scf.if %[[VAL_61]] {
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@params] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = function.call @IsZero::@IsZero::@compute(%[[VAL_63]]) : (!felt.type<"bn128">) -> !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:              pod.write %[[VAL_54]][@comp] = %[[VAL_64]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_27]]{{\[}}%[[VAL_65]]] = %[[VAL_54]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_66]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_26]]{{\[}}%[[VAL_70]]] = %[[VAL_69]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_72]], %[[VAL_43]] : !felt.type<"bn128">, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_23]][@zeros$inputs] = %[[VAL_38]]#1 : <@SubCmps1::@SubCmps1<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_75]] to %[[VAL_74]] step %[[VAL_76]] {
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_77]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            array.write %[[VAL_73]]{{\[}}%[[VAL_77]]] = %[[VAL_79]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_23]][@zeros] = %[[VAL_73]] : <@SubCmps1::@SubCmps1<[@n]>>, !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_23]][@outs] = %[[VAL_26]] : <@SubCmps1::@SubCmps1<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_23]] : !struct.type<@SubCmps1::@SubCmps1<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps1::@SubCmps1<[@n]>>, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "ins"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_82]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@outs] : <@SubCmps1::@SubCmps1<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@zeros] : <@SubCmps1::@SubCmps1<[@n]>>, !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@zeros$inputs] : <@SubCmps1::@SubCmps1<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_88]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_90]], %[[VAL_83]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_91]]) %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_92:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_95]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_97]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_99]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_85]]{{\[}}%[[VAL_100]]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_101]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_84]]{{\[}}%[[VAL_103]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_104]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_92]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_110:[0-9a-zA-Z_\.]+]] = %[[VAL_108]] to %[[VAL_107]] step %[[VAL_109]] {
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_85]]{{\[}}%[[VAL_110]]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_110]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @IsZero::@IsZero::@constrain(%[[VAL_111]], %[[VAL_113]]) : (!struct.type<@IsZero::@IsZero<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
