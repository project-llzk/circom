// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Separate loops must address the same component instances regardless of the
// induction variable's name. Each instance keeps its own constructor arguments
// and tags, even when the constructors share a source location.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Child(OFFSET) {
    Tagged() input in;
    signal output {size} out;
    out.size = in.x.size + OFFSET;
    out <== in.x;
}

template Main() {
    Tagged() a;
    Tagged() b;
    a.x.size = 2;
    b.x.size = 3;
    a.x <== 5;
    b.x <== 7;
    component children[2];
    for (var i = 0; i < 2; i++) {
        children[i] = parallel (parallel Child(i));
    }
    for (var j = 0; j < 2; j++) {
        if (j == 0) { children[j].in <== a; }
        else { children[j].in <== b; }
    }
    signal output left[children[0].out.size];
    signal output right[children[1].out.size];
    for (var k = 0; k < 2; k++) {
        left[k] <== children[0].out;
    }
    for (var l = 0; l < 4; l++) {
        right[l] <== children[1].out;
    }
}

component main = Main();

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// TEMPLATED-NEXT:    poly.template @Child {
// TEMPLATED-NEXT:      poly.param @OFFSET
// TEMPLATED-NEXT:      poly.param @"$tag$in$x$size"
// TEMPLATED-NEXT:      struct.def @Child {
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Child::@Child<[@OFFSET, @"$tag$in$x$size"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Child::@Child<[@OFFSET, @"$tag$in$x$size"]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = poly.read_const @OFFSET : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_0]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@Child::@Child<[@OFFSET, @"$tag$in$x$size"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@Child::@Child<[@OFFSET, @"$tag$in$x$size"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_5:[0-9a-zA-Z_.-]+]]: !struct.type<@Child::@Child<[@OFFSET, @"$tag$in$x$size"]>>, %[[VAL_6:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = poly.read_const @OFFSET : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_5]][@out] : <@Child::@Child<[@OFFSET, @"$tag$in$x$size"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_6]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @a : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @b : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @left : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @right : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @children : !array.type<2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:        struct.member @children$inputs : !array.type<2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[]>>
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = array.new  : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_12]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_12]][@x] = %[[VAL_16]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_13]][@x] = %[[VAL_18]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = pod.new { @OFFSET = %[[VAL_20]], @"$tag$in$x$size" = %[[VAL_21]] }  : <[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[0, 2]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_24]] : (!pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[0, 2]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_14]]{{\[}}%[[VAL_26]]] = %[[VAL_27]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = pod.new { @OFFSET = %[[VAL_31]], @"$tag$in$x$size" = %[[VAL_32]] }  : <[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_34]], @params = %[[VAL_33]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[1, 3]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_35]] : (!pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[1, 3]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_14]]{{\[}}%[[VAL_37]]] = %[[VAL_38]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_39]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_43]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_43]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_44]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_44]][@in] = %[[VAL_12]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_47]], %[[VAL_48]] : index
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_49]], %[[VAL_50]], %[[VAL_48]] : index
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_51]], %[[VAL_52]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_53]] {
// TEMPLATED-NEXT:            %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_55:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_56:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_54]], %[[VAL_55]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_45]][@count] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_57:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_58:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_58]] {
// TEMPLATED-NEXT:              %[[VAL_59:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@params] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_60:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_44]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_61:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_59]][@OFFSET] : <[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_62:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_63:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_59]][@"$tag$in$x$size"] : <[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_64:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_65:[0-9a-zA-Z_.-]+]] = function.call @Child::@Child::@compute(%[[VAL_60]]) {(%[[VAL_62]]), (%[[VAL_64]])} : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_45]][@comp] = %[[VAL_65]] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_15]]{{\[}}%[[VAL_43]]] = %[[VAL_44]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_14]]{{\[}}%[[VAL_43]]] = %[[VAL_45]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_66]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_70]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_70]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_71]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_71]][@in] = %[[VAL_13]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_72]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_74]], %[[VAL_75]] : index
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_76]], %[[VAL_77]], %[[VAL_75]] : index
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_78]], %[[VAL_79]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_80]] {
// TEMPLATED-NEXT:            %[[VAL_81:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_72]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_82:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_83:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_81]], %[[VAL_82]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_72]][@count] = %[[VAL_83]] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_84:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_85:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_83]], %[[VAL_84]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_85]] {
// TEMPLATED-NEXT:              %[[VAL_86:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_72]][@params] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_87:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_71]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_88:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_86]][@OFFSET] : <[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_89:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_88]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_90:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_86]][@"$tag$in$x$size"] : <[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_91:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_92:[0-9a-zA-Z_.-]+]] = function.call @Child::@Child::@compute(%[[VAL_87]]) {(%[[VAL_89]]), (%[[VAL_91]])} : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_72]][@comp] = %[[VAL_92]] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_15]]{{\[}}%[[VAL_70]]] = %[[VAL_71]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_14]]{{\[}}%[[VAL_70]]] = %[[VAL_72]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_93]], %[[VAL_94]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_98]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_99]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_100]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_101]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_96]]{{\[}}%[[VAL_104]]] = %[[VAL_102]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_105]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_109]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_110]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_111]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_96]]{{\[}}%[[VAL_114]]] = %[[VAL_112]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_117:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_115]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_118]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_119]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_120]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_121]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_97]]{{\[}}%[[VAL_124]]] = %[[VAL_122]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_125]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_129]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_130]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_131]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_97]]{{\[}}%[[VAL_134]]] = %[[VAL_132]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_135]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_139]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_140]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_141]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_144:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_143]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_97]]{{\[}}%[[VAL_144]]] = %[[VAL_142]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_145:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_145]], %[[VAL_146]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_149]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_150]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_151]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_97]]{{\[}}%[[VAL_154]]] = %[[VAL_152]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_155]], %[[VAL_156]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@children$inputs] = %[[VAL_15]] : <@Main::@Main<[]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_158:[0-9a-zA-Z_.-]+]] = array.new  : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_162:[0-9a-zA-Z_.-]+]] = %[[VAL_160]] to %[[VAL_159]] step %[[VAL_161]] {
// TEMPLATED-NEXT:            %[[VAL_163:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_162]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_164:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_158]]{{\[}}%[[VAL_162]]] = %[[VAL_164]] : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@children] = %[[VAL_158]] : <@Main::@Main<[]>>, !array.type<2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@a] = %[[VAL_12]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@b] = %[[VAL_13]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@left] = %[[VAL_96]] : <@Main::@Main<[]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_11]][@right] = %[[VAL_97]] : <@Main::@Main<[]>>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_11]] : !struct.type<@Main::@Main<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_165:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_165]][@a] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_165]][@b] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_168:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_165]][@left] : <@Main::@Main<[]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_169:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_165]][@right] : <@Main::@Main<[]>>, !array.type<4 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_165]][@children] : <@Main::@Main<[]>>, !array.type<2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_165]][@children$inputs] : <@Main::@Main<[]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_173:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_166]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_173]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_174:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_175:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_167]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_175]], %[[VAL_174]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_176:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_177:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_178:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_176]], %[[VAL_177]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_179:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_180:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_181:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_179]], %[[VAL_180]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_182]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_171]]{{\[}}%[[VAL_183]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_184]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_186:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_185]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_187:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_166]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_186]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_188:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_189:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_188]], %[[VAL_189]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_191]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_171]]{{\[}}%[[VAL_192]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_193]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_194]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_167]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_195]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_197]], %[[VAL_198]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_200]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_170]]{{\[}}%[[VAL_201]]] : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_202]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_204:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_206:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_168]]{{\[}}%[[VAL_205]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_206]], %[[VAL_203]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_207:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_208:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_209:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_207]], %[[VAL_208]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_210]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_170]]{{\[}}%[[VAL_211]]] : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_212]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_215:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_168]]{{\[}}%[[VAL_215]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_216]], %[[VAL_213]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_218:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_219:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_217]], %[[VAL_218]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_220:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_221:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_222:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_170]]{{\[}}%[[VAL_221]]] : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_223:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_222]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_224:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_225:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_224]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_226:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_225]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_226]], %[[VAL_223]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_227:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_228:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_227]], %[[VAL_228]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_230]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_170]]{{\[}}%[[VAL_231]]] : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_232]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_236:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_235]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_236]], %[[VAL_233]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_237:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_238:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_239:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_237]], %[[VAL_238]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_240:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_241:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_240]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_242:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_170]]{{\[}}%[[VAL_241]]] : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_243:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_242]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_244:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_245:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_244]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_246:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_245]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_246]], %[[VAL_243]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_247:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_248:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_249:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_247]], %[[VAL_248]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_250:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_251:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_250]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_252:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_170]]{{\[}}%[[VAL_251]]] : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_253:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_252]][@out] : <@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_254:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_255:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_254]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_256:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_255]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_256]], %[[VAL_253]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_257:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_258:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_259:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_257]], %[[VAL_258]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_260:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_261:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_262:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_263:[0-9a-zA-Z_.-]+]] = %[[VAL_261]] to %[[VAL_260]] step %[[VAL_262]] {
// TEMPLATED-NEXT:            %[[VAL_264:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_170]]{{\[}}%[[VAL_263]]] : <2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_265:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_171]]{{\[}}%[[VAL_263]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_266:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_265]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            function.call @Child::@Child::@constrain(%[[VAL_264]], %[[VAL_266]]) : (!struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_2::@Main_2<[]>>} {
// CONCRETE-NEXT:    poly.template @Child_0 {
// CONCRETE-NEXT:      struct.def @Child_0 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Child_0::@Child_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_0]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_.-]+]]: !struct.type<@Child_0::@Child_0<[]>>, %[[VAL_4:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_3]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Child_1 {
// CONCRETE-NEXT:      struct.def @Child_1 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_7:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Child_1::@Child_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = struct.new : <@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_7]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_8]][@out] = %[[VAL_9]] : <@Child_1::@Child_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_8]] : !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_.-]+]]: !struct.type<@Child_1::@Child_1<[]>>, %[[VAL_11:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_10]][@out] : <@Child_1::@Child_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_11]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_12]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Main_2 {
// CONCRETE-NEXT:      struct.def @Main_2 {
// CONCRETE-NEXT:        struct.member @left : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @right : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @a : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @b : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @children : !pod.type<[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>
// CONCRETE-NEXT:        struct.member @children$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Main_2::@Main_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_20]], @params = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_22]], @params = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_.-]+]] = pod.new { @idx_0 = %[[VAL_21]], @idx_1 = %[[VAL_23]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_.-]+]] = pod.new : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_15]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_15]][@x] = %[[VAL_26]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_16]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_16]][@x] = %[[VAL_28]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_32:[0-9a-zA-Z_.-]+]] = %[[VAL_30]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_33:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_34:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_32]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_34]]) %[[VAL_32]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_35:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_35]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_37]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]]:3 = scf.while (%[[VAL_40:[0-9a-zA-Z_.-]+]] = %[[VAL_24]], %[[VAL_41:[0-9a-zA-Z_.-]+]] = %[[VAL_25]], %[[VAL_42:[0-9a-zA-Z_.-]+]] = %[[VAL_38]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_43:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_44:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_42]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_44]]) %[[VAL_40]], %[[VAL_41]], %[[VAL_42]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_45:[0-9a-zA-Z_.-]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_46:[0-9a-zA-Z_.-]+]]: !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, %[[VAL_47:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_48:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_49:[0-9a-zA-Z_.-]+]] = bool.cmp eq(%[[VAL_47]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_50:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_49]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:              %[[VAL_51:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_52:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_53:[0-9a-zA-Z_.-]+]] = arith.constant true
// CONCRETE-NEXT:              %[[VAL_54:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_55:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_52]], %[[VAL_54]] : index
// CONCRETE-NEXT:              %[[VAL_56:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_53]], %[[VAL_55]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_57:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_58:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_52]], %[[VAL_57]] : index
// CONCRETE-NEXT:              %[[VAL_59:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_53]], %[[VAL_58]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_60:[0-9a-zA-Z_.-]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_61:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_59]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_62:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_63:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_46]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  %[[VAL_64:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_63]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  pod.write %[[VAL_63]][@in] = %[[VAL_15]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  pod.write %[[VAL_46]][@idx_1] = %[[VAL_63]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  %[[VAL_65:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_62]][@count] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_66:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_67:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_65]], %[[VAL_66]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_62]][@count] = %[[VAL_67]] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_68:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_69:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_67]], %[[VAL_68]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_69]] {
// CONCRETE-NEXT:                    %[[VAL_70:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_62]][@params] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_71:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_63]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_72:[0-9a-zA-Z_.-]+]] = function.call @Child_1::@Child_1::@compute(%[[VAL_71]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_62]][@comp] = %[[VAL_72]] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  pod.write %[[VAL_45]][@idx_1] = %[[VAL_62]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_73:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_56]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_74:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_75:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_46]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    %[[VAL_76:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_75]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    pod.write %[[VAL_75]][@in] = %[[VAL_15]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    pod.write %[[VAL_46]][@idx_0] = %[[VAL_75]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    %[[VAL_77:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_74]][@count] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_78:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_79:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_77]], %[[VAL_78]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_74]][@count] = %[[VAL_79]] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_80:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_81:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_79]], %[[VAL_80]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_81]] {
// CONCRETE-NEXT:                      %[[VAL_82:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_74]][@params] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_83:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_75]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                      %[[VAL_84:[0-9a-zA-Z_.-]+]] = function.call @Child_0::@Child_0::@compute(%[[VAL_83]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_74]][@comp] = %[[VAL_84]] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_45]][@idx_0] = %[[VAL_74]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_85:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_86:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_85]], %[[VAL_86]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_73]]#0, %[[VAL_73]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_61]]#0, %[[VAL_61]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_60]]#0, %[[VAL_60]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_87:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_88:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_89:[0-9a-zA-Z_.-]+]] = arith.constant true
// CONCRETE-NEXT:              %[[VAL_90:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_91:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_88]], %[[VAL_90]] : index
// CONCRETE-NEXT:              %[[VAL_92:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_89]], %[[VAL_91]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_93:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_94:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_88]], %[[VAL_93]] : index
// CONCRETE-NEXT:              %[[VAL_95:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_89]], %[[VAL_94]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_96:[0-9a-zA-Z_.-]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_97:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_95]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_98:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_99:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_46]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  %[[VAL_100:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_99]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  pod.write %[[VAL_99]][@in] = %[[VAL_16]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  pod.write %[[VAL_46]][@idx_1] = %[[VAL_99]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                  %[[VAL_101:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_98]][@count] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_102:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_103:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_101]], %[[VAL_102]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_98]][@count] = %[[VAL_103]] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_104:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_105:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_103]], %[[VAL_104]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_105]] {
// CONCRETE-NEXT:                    %[[VAL_106:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_98]][@params] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_107:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_99]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_108:[0-9a-zA-Z_.-]+]] = function.call @Child_1::@Child_1::@compute(%[[VAL_107]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_98]][@comp] = %[[VAL_108]] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  pod.write %[[VAL_45]][@idx_1] = %[[VAL_98]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_109:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_92]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_110:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_111:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_46]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    %[[VAL_112:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    pod.write %[[VAL_111]][@in] = %[[VAL_16]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    pod.write %[[VAL_46]][@idx_0] = %[[VAL_111]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                    %[[VAL_113:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_110]][@count] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_114:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_115:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_113]], %[[VAL_114]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_110]][@count] = %[[VAL_115]] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_116:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_117:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_115]], %[[VAL_116]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_117]] {
// CONCRETE-NEXT:                      %[[VAL_118:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_110]][@params] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_119:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                      %[[VAL_120:[0-9a-zA-Z_.-]+]] = function.call @Child_0::@Child_0::@compute(%[[VAL_119]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_110]][@comp] = %[[VAL_120]] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_45]][@idx_0] = %[[VAL_110]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_45]], %[[VAL_46]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_121:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_122:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_121]], %[[VAL_122]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_109]]#0, %[[VAL_109]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_97]]#0, %[[VAL_97]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_96]]#0, %[[VAL_96]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_123:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_124:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_47]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_50]]#0, %[[VAL_50]]#1, %[[VAL_124]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_127:[0-9a-zA-Z_.-]+]] = %[[VAL_125]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_128:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_129:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_127]], %[[VAL_128]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_129]]) %[[VAL_127]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_130:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_131:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_39]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_132:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_131]][@comp] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_133:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_132]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_134:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_130]] : !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_134]]] = %[[VAL_133]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_135:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_136:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_130]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_136]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_139:[0-9a-zA-Z_.-]+]] = %[[VAL_137]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_140:[0-9a-zA-Z_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_141:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_139]], %[[VAL_140]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_141]]) %[[VAL_139]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_142:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_143:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_39]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_144:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_143]][@comp] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:            %[[VAL_145:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_144]][@out] : <@Child_1::@Child_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_146:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_18]]{{\[}}%[[VAL_146]]] = %[[VAL_145]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_147:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_148:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_142]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_148]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_14]][@children$inputs] = %[[VAL_39]]#1 : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_149:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_39]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_150:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_149]][@comp] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:          %[[VAL_151:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_39]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_152:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_151]][@comp] : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:          %[[VAL_153:[0-9a-zA-Z_.-]+]] = pod.new { @idx_0 = %[[VAL_150]], @idx_1 = %[[VAL_152]] }  : <[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_14]][@children] = %[[VAL_153]] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_14]][@a] = %[[VAL_15]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_14]][@b] = %[[VAL_16]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_14]][@left] = %[[VAL_17]] : <@Main_2::@Main_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_14]][@right] = %[[VAL_18]] : <@Main_2::@Main_2<[]>>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_14]] : !struct.type<@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_154:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_2::@Main_2<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_154]][@left] : <@Main_2::@Main_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_154]][@right] : <@Main_2::@Main_2<[]>>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_154]][@a] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_158:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_154]][@b] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_154]][@children] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_154]][@children$inputs] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_157]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_162]], %[[VAL_161]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_158]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_164]], %[[VAL_163]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_167:[0-9a-zA-Z_.-]+]] = %[[VAL_165]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_168:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_169:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_167]], %[[VAL_168]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_169]]) %[[VAL_167]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_170:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_171:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_172:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_170]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_172]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_173:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_174:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_175:[0-9a-zA-Z_.-]+]] = %[[VAL_173]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_176:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_177:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_175]], %[[VAL_176]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_177]]) %[[VAL_175]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_178:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_179:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_180:[0-9a-zA-Z_.-]+]] = bool.cmp eq(%[[VAL_178]], %[[VAL_179]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.if %[[VAL_180]] {
// CONCRETE-NEXT:              %[[VAL_181:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_160]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_182:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_181]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_183:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_182]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_184:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_157]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              constrain.eq %[[VAL_183]], %[[VAL_184]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_185:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_160]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_186:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_185]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_187:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_186]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_188:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_158]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              constrain.eq %[[VAL_187]], %[[VAL_188]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_189:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_190:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_178]], %[[VAL_189]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_190]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_191:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_192:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_193:[0-9a-zA-Z_.-]+]] = %[[VAL_191]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_194:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_195:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_193]], %[[VAL_194]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_195]]) %[[VAL_193]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_196:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_197:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_159]][@idx_0] : <[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_198:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_197]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_199:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_200:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_155]]{{\[}}%[[VAL_199]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_200]], %[[VAL_198]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_201:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_202:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_196]], %[[VAL_201]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_202]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_203:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_204:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_205:[0-9a-zA-Z_.-]+]] = %[[VAL_203]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_206:[0-9a-zA-Z_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_207:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_205]], %[[VAL_206]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_207]]) %[[VAL_205]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_208:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_209:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_159]][@idx_1] : <[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>, !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:            %[[VAL_210:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_209]][@out] : <@Child_1::@Child_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_211:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_208]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_212:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_156]]{{\[}}%[[VAL_211]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_212]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_213:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_214:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_208]], %[[VAL_213]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_214]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_215:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_159]][@idx_0] : <[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:          %[[VAL_216:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_160]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_217:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_216]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Child_0::@Child_0::@constrain(%[[VAL_215]], %[[VAL_217]]) : (!struct.type<@Child_0::@Child_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_218:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_159]][@idx_1] : <[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>, !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE-NEXT:          %[[VAL_219:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_160]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_220:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_219]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Child_1::@Child_1::@constrain(%[[VAL_218]], %[[VAL_220]]) : (!struct.type<@Child_1::@Child_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }
