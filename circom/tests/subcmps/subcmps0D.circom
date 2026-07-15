// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Add() {
    signal input in1;
    signal input in2;
    signal output out;
    out <-- in1 + in2;
}

template SubCmps0D(n) {
    signal input ins[n];
    signal output outs[n];

    component a[n];
    for (var i = 0; i < n; i++) {
        a[i] = Add();
        a[i].in1 <-- ins[i];
        a[i].in2 <-- ins[i];
        outs[i] <-- a[i].out;
    }
}

component main = SubCmps0D(3);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@SubCmps0D::@SubCmps0D<[3]>>} {
// CHECK-NEXT:    poly.template @Add {
// CHECK-NEXT:      struct.def @Add {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in2"}) -> !struct.type<@Add::@Add<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Add::@Add<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@Add::@Add<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Add::@Add<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1"}, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in2"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@Add::@Add<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmps0D {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @SubCmps0D {
// CHECK-NEXT:        struct.member @outs : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a : !array.type<@n x !struct.type<@Add::@Add<[]>>>
// CHECK-NEXT:        struct.member @a$inputs : !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "ins"}) -> !struct.type<@SubCmps0D::@SubCmps0D<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps0D::@SubCmps0D<[@n]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_10]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_16]] to %[[VAL_15]] step %[[VAL_17]] {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_19]], @params = %[[VAL_14]] }  : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_13]]{{\[}}%[[VAL_18]]] = %[[VAL_20]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_21]], %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_25]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_24]], %[[VAL_25]] : !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_30]], @params = %[[VAL_29]] }  : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_13]]{{\[}}%[[VAL_32]]] = %[[VAL_31]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_33]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_35]]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_36]][@in1] = %[[VAL_34]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_37]]] = %[[VAL_36]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_38]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_40]]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:            pod.write %[[VAL_39]][@count] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:            scf.if %[[VAL_46]] {
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@params] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = function.call @Add::@Add::@compute(%[[VAL_48]], %[[VAL_49]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:              pod.write %[[VAL_39]][@comp] = %[[VAL_50]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_13]]{{\[}}%[[VAL_51]]] = %[[VAL_39]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_52]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_54]]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_55]][@in2] = %[[VAL_53]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_56]]] = %[[VAL_55]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_57]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_59]]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@count] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_61]], %[[VAL_62]] : index
// CHECK-NEXT:            pod.write %[[VAL_58]][@count] = %[[VAL_63]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_63]], %[[VAL_64]] : index
// CHECK-NEXT:            scf.if %[[VAL_65]] {
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@params] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = function.call @Add::@Add::@compute(%[[VAL_67]], %[[VAL_68]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:              pod.write %[[VAL_58]][@comp] = %[[VAL_69]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_13]]{{\[}}%[[VAL_70]]] = %[[VAL_58]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_71]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@comp] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@out] : <@Add::@Add<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_75]]] = %[[VAL_74]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_76]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_27]], %[[VAL_77]] : !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@a$inputs] = %[[VAL_23]]#0 : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@Add::@Add<[]>>>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_80]] to %[[VAL_79]] step %[[VAL_81]] {
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_82]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@comp] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:            array.write %[[VAL_78]]{{\[}}%[[VAL_82]]] = %[[VAL_84]] : <@n x !struct.type<@Add::@Add<[]>>>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@a] = %[[VAL_78]] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !struct.type<@Add::@Add<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@outs] = %[[VAL_12]] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@SubCmps0D::@SubCmps0D<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_85:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps0D::@SubCmps0D<[@n]>>, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "ins"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_87]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@outs] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@a] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !struct.type<@Add::@Add<[]>>>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@a$inputs] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_94:[0-9a-zA-Z_\.]+]] = %[[VAL_92]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_94]], %[[VAL_88]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_95]]) %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_96:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_96]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]] to %[[VAL_101]] step %[[VAL_103]] {
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_104]]] : <@n x !struct.type<@Add::@Add<[]>>>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_104]]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Add::@Add::@constrain(%[[VAL_105]], %[[VAL_107]], %[[VAL_108]]) : (!struct.type<@Add::@Add<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
