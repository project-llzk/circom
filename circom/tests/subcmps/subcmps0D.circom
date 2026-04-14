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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmps0D::@SubCmps0D<[3]>>} {
// CHECK-NEXT:    poly.template @Add {
// CHECK-NEXT:      struct.def @Add {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Add::@Add<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Add::@Add<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@Add::@Add<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Add::@Add<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@Add::@Add<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmps0D {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @SubCmps0D {
// CHECK-NEXT:        struct.member @outs : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @a : !array.type<@n x !struct.type<@Add::@Add<[]>>>
// CHECK-NEXT:        struct.member @a$inputs : !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@SubCmps0D::@SubCmps0D<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps0D::@SubCmps0D<[@n]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_14]] to %[[VAL_13]] step %[[VAL_15]] {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_16]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            pod.write %[[VAL_17]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_16]]] = %[[VAL_17]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_19]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_23]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_22]], %[[VAL_23]] : !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_27]] }  : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_29]]] = %[[VAL_28]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_30]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_32]]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_33]][@in1] = %[[VAL_31]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_25]]{{\[}}%[[VAL_34]]] = %[[VAL_33]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_35]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@count] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:            pod.write %[[VAL_36]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:            scf.if %[[VAL_41]] {
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @Add::@Add::@compute(%[[VAL_42]], %[[VAL_43]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:              pod.write %[[VAL_36]][@comp] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_12]]{{\[}}%[[VAL_45]]] = %[[VAL_36]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_46]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_48]]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_49]][@in2] = %[[VAL_47]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_25]]{{\[}}%[[VAL_50]]] = %[[VAL_49]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_51]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@count] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// CHECK-NEXT:            pod.write %[[VAL_52]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:            scf.if %[[VAL_57]] {
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = function.call @Add::@Add::@compute(%[[VAL_58]], %[[VAL_59]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:              pod.write %[[VAL_52]][@comp] = %[[VAL_60]] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_12]]{{\[}}%[[VAL_61]]] = %[[VAL_52]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_62]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@comp] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@out] : <@Add::@Add<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_66]]] = %[[VAL_65]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_25]], %[[VAL_68]] : !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@a$inputs] = %[[VAL_21]]#0 : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@Add::@Add<[]>>>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_71]] to %[[VAL_70]] step %[[VAL_72]] {
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_73]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@comp] : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:            array.write %[[VAL_69]]{{\[}}%[[VAL_73]]] = %[[VAL_75]] : <@n x !struct.type<@Add::@Add<[]>>>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@a] = %[[VAL_69]] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !struct.type<@Add::@Add<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@outs] = %[[VAL_11]] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@SubCmps0D::@SubCmps0D<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps0D::@SubCmps0D<[@n]>>, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@outs] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@a] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !struct.type<@Add::@Add<[]>>>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@a$inputs] : <@SubCmps0D::@SubCmps0D<[@n]>>, !array.type<@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_82]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_84]], %[[VAL_78]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_85]]) %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_87]] }  : <[@count: index, @comp: !struct.type<@Add::@Add<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_94:[0-9a-zA-Z_\.]+]] = %[[VAL_92]] to %[[VAL_91]] step %[[VAL_93]] {
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_94]]] : <@n x !struct.type<@Add::@Add<[]>>>, !struct.type<@Add::@Add<[]>>
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_94]]] : <@n x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Add::@Add::@constrain(%[[VAL_95]], %[[VAL_97]], %[[VAL_98]]) : (!struct.type<@Add::@Add<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
