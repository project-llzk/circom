// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Like SubCmps1 but simpler (no constraints and fewer operations)
template IsZero() {
    signal input in;
    signal output out;
    out <-- -in;
}

template SubCmps0A(n) {
    signal input ins[n];
    signal output outs[n];

    component zeros[n];
    for (var i = 0; i < n; i++) {
        zeros[i] = IsZero();
        zeros[i].in <-- ins[i];
        outs[i] <-- zeros[i].out;
    }
}

component main = SubCmps0A(2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@SubCmps0A::@SubCmps0A<[2]>>} {
// CHECK-NEXT:    poly.template @IsZero {
// CHECK-NEXT:      struct.def @IsZero {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@IsZero::@IsZero<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@IsZero::@IsZero<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@IsZero::@IsZero<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmps0A {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @SubCmps0A {
// CHECK-NEXT:        struct.member @outs : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @zeros : !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:        struct.member @zeros$inputs : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "ins"}) -> !struct.type<@SubCmps0A::@SubCmps0A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps0A::@SubCmps0A<[@n]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_8]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_14]] to %[[VAL_13]] step %[[VAL_15]] {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_17]], @params = %[[VAL_12]] }  : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_16]]] = %[[VAL_18]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_11_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_11]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!felt.type<"bn128">, !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_9]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_22]], %[[VAL_11_IN]], %[[VAL_23]] : !felt.type<"bn128">, !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_11_LCV:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_28]], @params = %[[VAL_27]] }  : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_11_LCV]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_6]]{{\[}}%[[VAL_31]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_33]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_34]][@in] = %[[VAL_32]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_26]]{{\[}}%[[VAL_35]]] = %[[VAL_34]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11_LCV]]{{\[}}%[[VAL_36]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_38]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_37]][@count] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_40]], %[[VAL_41]] : index
// CHECK-NEXT:            pod.write %[[VAL_37]][@count] = %[[VAL_42]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:            scf.if %[[VAL_44]] {
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_37]][@params] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = function.call @IsZero::@IsZero::@compute(%[[VAL_46]]) : (!felt.type<"bn128">) -> !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:              pod.write %[[VAL_37]][@comp] = %[[VAL_47]] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_11_LCV]]{{\[}}%[[VAL_48]]] = %[[VAL_37]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11_LCV]]{{\[}}%[[VAL_49]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_51]][@out] : <@IsZero::@IsZero<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_10]]{{\[}}%[[VAL_53]]] = %[[VAL_52]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_54]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_55]], %[[VAL_11_LCV]], %[[VAL_26]] : !felt.type<"bn128">, !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_7]][@zeros$inputs] = %[[VAL_21]]#2 : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_57]] step %[[VAL_59]] {
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]#1{{\[}}%[[VAL_60]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@comp] : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            array.write %[[VAL_56]]{{\[}}%[[VAL_60]]] = %[[VAL_62]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_7]][@zeros] = %[[VAL_56]] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_7]][@outs] = %[[VAL_10]] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@SubCmps0A::@SubCmps0A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps0A::@SubCmps0A<[@n]>>, %[[VAL_64:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "ins"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_65]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@outs] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@zeros] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !struct.type<@IsZero::@IsZero<[]>>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@zeros$inputs] : <@SubCmps0A::@SubCmps0A<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_70]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_72]], %[[VAL_66]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_73]]) %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_74:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@IsZero::@IsZero<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_74]], %[[VAL_77]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_80]] to %[[VAL_79]] step %[[VAL_81]] {
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_68]]{{\[}}%[[VAL_82]]] : <@n x !struct.type<@IsZero::@IsZero<[]>>>, !struct.type<@IsZero::@IsZero<[]>>
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_82]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @IsZero::@IsZero::@constrain(%[[VAL_83]], %[[VAL_85]]) : (!struct.type<@IsZero::@IsZero<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
