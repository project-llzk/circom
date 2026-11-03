// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Nested loops, nonzero starts, equivalent index expressions, and empty loops
// must retain the identities of each component and its derived output tags.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Child() {
    Tagged() input in;
    signal output {size} out;
    out.size = in.x.size;
    out <== in.x;
}

template Main() {
    Tagged() source;
    source.x.size = 3;
    source.x <== 5;
    component children[2][2];
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            children[i][j] = Child();
        }
    }
    for (var row = 1; row < 3; row++) {
        for (var col = 1; col < 3; col++) {
            children[row - 1][col - 1].in <== source;
        }
    }
    // This unreachable assignment must not change any component's tags.
    for (var empty = 2; empty < 2; empty++) {
        children[0][0].in.x <== 0;
    }
    signal output out[children[1][1].out.size];
    for (var k = 0; k < 3; k++) {
        out[k] <== children[0][0].out + children[0][1].out
            + children[1][0].out + children[1][1].out;
    }
}

component main = Main();

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// TEMPLATED-NEXT:    poly.template @Child {
// TEMPLATED-NEXT:      poly.param @"$tag$in$x$size"
// TEMPLATED-NEXT:      struct.def @Child {
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Child::@Child<[@"$tag$in$x$size"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Child::@Child<[@"$tag$in$x$size"]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_0]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@Child::@Child<[@"$tag$in$x$size"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@Child::@Child<[@"$tag$in$x$size"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_.-]+]]: !struct.type<@Child::@Child<[@"$tag$in$x$size"]>>, %[[VAL_5:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_4]][@out] : <@Child::@Child<[@"$tag$in$x$size"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @source : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @children : !array.type<2,2 x !struct.type<@Child::@Child<[3]>>>
// TEMPLATED-NEXT:        struct.member @children$inputs : !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[]>>
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = array.new  : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = array.new  : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_10]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_10]][@x] = %[[VAL_13]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_15]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_17]], @params = %[[VAL_16]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_20]], %[[VAL_22]]] = %[[VAL_18]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_23]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_26]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_28]], @params = %[[VAL_27]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_31]], %[[VAL_33]]] = %[[VAL_29]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_34]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_37]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_40]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_42]], @params = %[[VAL_41]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_45]], %[[VAL_47]]] = %[[VAL_43]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_48]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_51]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_53]], @params = %[[VAL_52]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_56]], %[[VAL_58]]] = %[[VAL_54]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_59]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_62]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_65]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_69]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_71]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_68]], %[[VAL_72]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_68]], %[[VAL_72]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_73]][@in] = %[[VAL_10]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_74]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_76]], %[[VAL_77]] : index
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_78]], %[[VAL_79]], %[[VAL_77]] : index
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_80]], %[[VAL_81]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_82]] {
// TEMPLATED-NEXT:            %[[VAL_83:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_74]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_84:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_85:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_83]], %[[VAL_84]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_74]][@count] = %[[VAL_85]] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_86:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_85]], %[[VAL_86]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_87]] {
// TEMPLATED-NEXT:              %[[VAL_88:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_74]][@params] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_89:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_90:[0-9a-zA-Z_.-]+]] = function.call @Child::@Child::@compute(%[[VAL_89]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_74]][@comp] = %[[VAL_90]] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_12]]{{\[}}%[[VAL_68]], %[[VAL_72]]] = %[[VAL_73]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_68]], %[[VAL_72]]] = %[[VAL_74]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_91]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_94]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_98]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_97]], %[[VAL_101]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_97]], %[[VAL_101]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_102]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_102]][@in] = %[[VAL_10]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_103]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_105]], %[[VAL_106]] : index
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_107]], %[[VAL_108]], %[[VAL_106]] : index
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_109]], %[[VAL_110]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_111]] {
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_103]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_114:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_112]], %[[VAL_113]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_103]][@count] = %[[VAL_114]] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_115:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_114]], %[[VAL_115]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_116]] {
// TEMPLATED-NEXT:              %[[VAL_117:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_103]][@params] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_118:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_102]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_119:[0-9a-zA-Z_.-]+]] = function.call @Child::@Child::@compute(%[[VAL_118]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_103]][@comp] = %[[VAL_119]] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_12]]{{\[}}%[[VAL_97]], %[[VAL_101]]] = %[[VAL_102]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_97]], %[[VAL_101]]] = %[[VAL_103]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_120]], %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_123]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_126]], %[[VAL_127]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_130]], %[[VAL_131]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_132]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_129]], %[[VAL_133]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_129]], %[[VAL_133]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_134]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_134]][@in] = %[[VAL_10]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_135]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_137]], %[[VAL_138]] : index
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_139]], %[[VAL_140]], %[[VAL_138]] : index
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_141]], %[[VAL_142]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_143]] {
// TEMPLATED-NEXT:            %[[VAL_144:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_135]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_145:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_146:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_144]], %[[VAL_145]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_135]][@count] = %[[VAL_146]] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_147:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_148:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_147]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_148]] {
// TEMPLATED-NEXT:              %[[VAL_149:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_135]][@params] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_150:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_134]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_151:[0-9a-zA-Z_.-]+]] = function.call @Child::@Child::@compute(%[[VAL_150]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_135]][@comp] = %[[VAL_151]] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_12]]{{\[}}%[[VAL_129]], %[[VAL_133]]] = %[[VAL_134]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_129]], %[[VAL_133]]] = %[[VAL_135]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_152]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_155]], %[[VAL_156]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_158:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_159]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_158]], %[[VAL_162]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_158]], %[[VAL_162]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_163]][@in] = %[[VAL_10]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_168:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_166]], %[[VAL_167]] : index
// TEMPLATED-NEXT:          %[[VAL_169:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_168]], %[[VAL_169]], %[[VAL_167]] : index
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_171]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_172]] {
// TEMPLATED-NEXT:            %[[VAL_173:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_174:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_175:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_173]], %[[VAL_174]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_164]][@count] = %[[VAL_175]] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_176:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_177:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_175]], %[[VAL_176]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_177]] {
// TEMPLATED-NEXT:              %[[VAL_178:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_164]][@params] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_179:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_180:[0-9a-zA-Z_.-]+]] = function.call @Child::@Child::@compute(%[[VAL_179]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_164]][@comp] = %[[VAL_180]] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_12]]{{\[}}%[[VAL_158]], %[[VAL_162]]] = %[[VAL_163]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_158]], %[[VAL_162]]] = %[[VAL_164]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_181:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_181]], %[[VAL_182]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_186:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_184]], %[[VAL_185]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_187:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          scf.while : () -> () {
// TEMPLATED-NEXT:            %[[VAL_188:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_189:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_187]], %[[VAL_188]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_189]])
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:            scf.yield
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_191]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_193]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_192]], %[[VAL_194]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_195]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_196]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_198]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_200]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_199]], %[[VAL_201]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_202]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_204:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_203]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_197]], %[[VAL_204]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_206:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_207:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_208:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_209:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_208]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_207]], %[[VAL_209]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_210]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_211]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_205]], %[[VAL_212]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_215:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_216]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_218:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_215]], %[[VAL_217]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_219:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_218]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_220:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_219]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_221:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_213]], %[[VAL_220]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_222:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_223:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_222]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_190]]{{\[}}%[[VAL_223]]] = %[[VAL_221]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_224:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_225:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_226:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_224]], %[[VAL_225]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_227:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_228:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_228]], %[[VAL_230]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_231]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_232]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_236:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_237:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_236]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_238:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_235]], %[[VAL_237]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_239:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_238]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_240:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_239]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_241:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_233]], %[[VAL_240]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_242:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_243:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_242]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_244:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_245:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_244]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_246:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_243]], %[[VAL_245]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_247:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_246]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_248:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_247]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_249:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_241]], %[[VAL_248]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_250:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_251:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_250]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_252:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_253:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_252]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_254:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_251]], %[[VAL_253]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_255:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_254]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_256:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_255]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_257:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_249]], %[[VAL_256]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_258:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_259:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_258]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_190]]{{\[}}%[[VAL_259]]] = %[[VAL_257]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_260:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_261:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_262:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_260]], %[[VAL_261]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_263:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_264:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_263]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_265:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_266:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_265]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_267:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_264]], %[[VAL_266]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_268:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_267]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_269:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_268]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_270:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_271:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_270]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_272:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_273:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_272]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_274:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_271]], %[[VAL_273]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_275:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_274]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_276:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_275]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_277:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_269]], %[[VAL_276]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_278:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_279:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_278]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_280:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_281:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_280]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_282:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_279]], %[[VAL_281]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_283:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_282]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_284:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_283]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_285:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_277]], %[[VAL_284]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_286:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_287:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_288:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_289:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_290:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_287]], %[[VAL_289]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_291:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_290]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_292:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_291]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_293:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_285]], %[[VAL_292]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_294:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_295:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_294]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          array.write %[[VAL_190]]{{\[}}%[[VAL_295]]] = %[[VAL_293]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_296:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_297:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_298:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_296]], %[[VAL_297]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_9]][@children$inputs] = %[[VAL_12]] : <@Main::@Main<[]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_299:[0-9a-zA-Z_.-]+]] = array.new  : <2,2 x !struct.type<@Child::@Child<[3]>>>
// TEMPLATED-NEXT:          %[[VAL_300:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_301:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_302:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_303:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_304:[0-9a-zA-Z_.-]+]] = %[[VAL_302]] to %[[VAL_300]] step %[[VAL_303]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_305:[0-9a-zA-Z_.-]+]] = %[[VAL_302]] to %[[VAL_301]] step %[[VAL_303]] {
// TEMPLATED-NEXT:              %[[VAL_306:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_304]], %[[VAL_305]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_307:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_306]][@comp] : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:              array.write %[[VAL_299]]{{\[}}%[[VAL_304]], %[[VAL_305]]] = %[[VAL_307]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_9]][@children] = %[[VAL_299]] : <@Main::@Main<[]>>, !array.type<2,2 x !struct.type<@Child::@Child<[3]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_9]][@source] = %[[VAL_10]] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_9]][@out] = %[[VAL_190]] : <@Main::@Main<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_9]] : !struct.type<@Main::@Main<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_308:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_309:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_308]][@source] : <@Main::@Main<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_310:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_308]][@out] : <@Main::@Main<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_311:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_308]][@children] : <@Main::@Main<[]>>, !array.type<2,2 x !struct.type<@Child::@Child<[3]>>>
// TEMPLATED-NEXT:          %[[VAL_312:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_308]][@children$inputs] : <@Main::@Main<[]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_313:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_314:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_309]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_314]], %[[VAL_313]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_315:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_316:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_317:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_315]], %[[VAL_316]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_318:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_319:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_320:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_318]], %[[VAL_319]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_321:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_322:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_323:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_321]], %[[VAL_322]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_324:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_325:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_326:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_324]], %[[VAL_325]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_327:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_328:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_329:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_327]], %[[VAL_328]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_330:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_331:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_332:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_330]], %[[VAL_331]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_333:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_334:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_335:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_333]], %[[VAL_334]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_336:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_335]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_337:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_338:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_339:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_337]], %[[VAL_338]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_340:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_339]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_341:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_312]]{{\[}}%[[VAL_336]], %[[VAL_340]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_342:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_341]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_343:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_342]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_344:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_309]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_343]], %[[VAL_344]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_345:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_346:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_347:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_345]], %[[VAL_346]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_348:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_349:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_350:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_348]], %[[VAL_349]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_351:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_350]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_352:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_353:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_354:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_352]], %[[VAL_353]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_355:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_354]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_356:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_312]]{{\[}}%[[VAL_351]], %[[VAL_355]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_357:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_356]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_358:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_357]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_359:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_309]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_358]], %[[VAL_359]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_360:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_361:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_362:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_360]], %[[VAL_361]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_363:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_364:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_365:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_363]], %[[VAL_364]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_366:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_367:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_368:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_366]], %[[VAL_367]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_369:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_368]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_370:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_371:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_372:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_370]], %[[VAL_371]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_373:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_372]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_374:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_312]]{{\[}}%[[VAL_369]], %[[VAL_373]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_375:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_374]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_376:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_375]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_377:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_309]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_376]], %[[VAL_377]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_378:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_379:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_380:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_378]], %[[VAL_379]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_381:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_382:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_383:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_381]], %[[VAL_382]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_384:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_383]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_385:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_386:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_387:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_385]], %[[VAL_386]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_388:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_387]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_389:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_312]]{{\[}}%[[VAL_384]], %[[VAL_388]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_390:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_389]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_391:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_390]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_392:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_309]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_391]], %[[VAL_392]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_393:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_394:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_395:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_393]], %[[VAL_394]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_396:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_397:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_398:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_396]], %[[VAL_397]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_399:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          scf.while : () -> () {
// TEMPLATED-NEXT:            %[[VAL_400:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_401:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_399]], %[[VAL_400]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_401]])
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:            scf.yield
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_402:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_403:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_402]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_404:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_405:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_404]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_406:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_403]], %[[VAL_405]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_407:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_406]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_408:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_409:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_408]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_410:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_411:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_410]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_412:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_409]], %[[VAL_411]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_413:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_412]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_414:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_407]], %[[VAL_413]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_415:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_416:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_415]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_417:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_418:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_417]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_419:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_416]], %[[VAL_418]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_420:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_419]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_421:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_414]], %[[VAL_420]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_422:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_423:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_422]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_424:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_425:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_426:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_423]], %[[VAL_425]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_427:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_426]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_428:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_421]], %[[VAL_427]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_429:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_430:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_429]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_431:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_310]]{{\[}}%[[VAL_430]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_431]], %[[VAL_428]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_432:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_433:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_434:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_432]], %[[VAL_433]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_435:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_436:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_435]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_437:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_438:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_437]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_439:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_436]], %[[VAL_438]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_440:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_439]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_441:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_442:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_441]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_443:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_444:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_443]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_445:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_442]], %[[VAL_444]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_446:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_445]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_447:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_440]], %[[VAL_446]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_448:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_449:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_448]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_450:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_451:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_450]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_452:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_449]], %[[VAL_451]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_453:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_452]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_454:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_447]], %[[VAL_453]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_455:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_456:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_455]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_457:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_458:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_457]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_459:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_456]], %[[VAL_458]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_460:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_459]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_461:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_454]], %[[VAL_460]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_462:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_463:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_462]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_464:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_310]]{{\[}}%[[VAL_463]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_464]], %[[VAL_461]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_465:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_466:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_467:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_465]], %[[VAL_466]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_468:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_469:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_468]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_470:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_471:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_470]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_472:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_469]], %[[VAL_471]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_473:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_472]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_474:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_475:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_474]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_476:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_477:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_476]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_478:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_475]], %[[VAL_477]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_479:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_478]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_480:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_473]], %[[VAL_479]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_481:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_482:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_481]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_483:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_484:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_483]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_485:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_482]], %[[VAL_484]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_486:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_485]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_487:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_480]], %[[VAL_486]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_488:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_489:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_488]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_490:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_491:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_490]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_492:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_489]], %[[VAL_491]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:          %[[VAL_493:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_492]][@out] : <@Child::@Child<[3]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_494:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_487]], %[[VAL_493]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_495:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_496:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_495]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_497:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_310]]{{\[}}%[[VAL_496]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_497]], %[[VAL_494]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_498:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_499:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_500:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_498]], %[[VAL_499]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_501:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_502:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_503:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_504:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_505:[0-9a-zA-Z_.-]+]] = %[[VAL_503]] to %[[VAL_501]] step %[[VAL_504]] {
// TEMPLATED-NEXT:            scf.for %[[VAL_506:[0-9a-zA-Z_.-]+]] = %[[VAL_503]] to %[[VAL_502]] step %[[VAL_504]] {
// TEMPLATED-NEXT:              %[[VAL_507:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_311]]{{\[}}%[[VAL_505]], %[[VAL_506]]] : <2,2 x !struct.type<@Child::@Child<[3]>>>, !struct.type<@Child::@Child<[3]>>
// TEMPLATED-NEXT:              %[[VAL_508:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_312]]{{\[}}%[[VAL_505]], %[[VAL_506]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_509:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_508]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              function.call @Child::@Child::@constrain(%[[VAL_507]], %[[VAL_509]]) : (!struct.type<@Child::@Child<[3]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_1::@Main_1<[]>>} {
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
// CONCRETE-NEXT:    poly.template @Main_1 {
// CONCRETE-NEXT:      struct.def @Main_1 {
// CONCRETE-NEXT:        struct.member @out : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @source : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @children : !array.type<2,2 x !struct.type<@Child_0::@Child_0<[]>>>
// CONCRETE-NEXT:        struct.member @children$inputs : !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Main_1::@Main_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = array.new  : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_16:[0-9a-zA-Z_.-]+]] = %[[VAL_14]] to %[[VAL_12]] step %[[VAL_15]] {
// CONCRETE-NEXT:            scf.for %[[VAL_17:[0-9a-zA-Z_.-]+]] = %[[VAL_14]] to %[[VAL_13]] step %[[VAL_15]] {
// CONCRETE-NEXT:              %[[VAL_18:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_19:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_18]], @params = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              array.write %[[VAL_10]]{{\[}}%[[VAL_16]], %[[VAL_17]]] = %[[VAL_19]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = array.new  : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_9]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_9]][@x] = %[[VAL_21]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_25:[0-9a-zA-Z_.-]+]] = %[[VAL_23]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_25]], %[[VAL_26]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_27]]) %[[VAL_25]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_28:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_31:[0-9a-zA-Z_.-]+]] = %[[VAL_29]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_32:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_33:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_31]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_33]]) %[[VAL_31]] : !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_34:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_35:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_36:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_34]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_36]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_38:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_28]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_38]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]]:3 = scf.while (%[[VAL_41:[0-9a-zA-Z_.-]+]] = %[[VAL_10]], %[[VAL_42:[0-9a-zA-Z_.-]+]] = %[[VAL_20]], %[[VAL_43:[0-9a-zA-Z_.-]+]] = %[[VAL_39]]) : (!array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !felt.type<"bn128">) -> (!array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_44:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_45:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_43]], %[[VAL_44]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_45]]) %[[VAL_41]], %[[VAL_42]], %[[VAL_43]] : !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_46:[0-9a-zA-Z_.-]+]]: !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_47:[0-9a-zA-Z_.-]+]]: !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, %[[VAL_48:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_49:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_50:[0-9a-zA-Z_.-]+]]:3 = scf.while (%[[VAL_51:[0-9a-zA-Z_.-]+]] = %[[VAL_46]], %[[VAL_52:[0-9a-zA-Z_.-]+]] = %[[VAL_47]], %[[VAL_53:[0-9a-zA-Z_.-]+]] = %[[VAL_49]]) : (!array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !felt.type<"bn128">) -> (!array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !felt.type<"bn128">) {
// CONCRETE-NEXT:              %[[VAL_54:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_55:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_53]], %[[VAL_54]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_55]]) %[[VAL_51]], %[[VAL_52]], %[[VAL_53]] : !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_56:[0-9a-zA-Z_.-]+]]: !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_57:[0-9a-zA-Z_.-]+]]: !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, %[[VAL_58:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_59:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_60:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_48]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_61:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_62:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_63:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_58]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_64:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_65:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_61]], %[[VAL_64]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_66:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_61]], %[[VAL_64]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              %[[VAL_67:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_65]][@in] = %[[VAL_9]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_68:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_66]][@count] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_69:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_70:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_68]], %[[VAL_69]] : index
// CONCRETE-NEXT:              %[[VAL_71:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_72:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_70]], %[[VAL_71]], %[[VAL_69]] : index
// CONCRETE-NEXT:              %[[VAL_73:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_74:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_72]], %[[VAL_73]] : index
// CONCRETE-NEXT:              scf.if %[[VAL_74]] {
// CONCRETE-NEXT:                %[[VAL_75:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_66]][@count] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_76:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_77:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_75]], %[[VAL_76]] : index
// CONCRETE-NEXT:                pod.write %[[VAL_66]][@count] = %[[VAL_77]] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_78:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_79:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_77]], %[[VAL_78]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_79]] {
// CONCRETE-NEXT:                  %[[VAL_80:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_66]][@params] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                  %[[VAL_81:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_82:[0-9a-zA-Z_.-]+]] = function.call @Child_0::@Child_0::@compute(%[[VAL_81]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_66]][@comp] = %[[VAL_82]] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              array.write %[[VAL_57]]{{\[}}%[[VAL_61]], %[[VAL_64]]] = %[[VAL_65]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              array.write %[[VAL_56]]{{\[}}%[[VAL_61]], %[[VAL_64]]] = %[[VAL_66]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              %[[VAL_83:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_84:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_58]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_56]], %[[VAL_57]], %[[VAL_84]] : !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_85:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_86:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_48]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_50]]#0, %[[VAL_50]]#1, %[[VAL_86]] : !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_89:[0-9a-zA-Z_.-]+]] = %[[VAL_87]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_90:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_91:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_89]], %[[VAL_90]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_91]]) %[[VAL_89]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_92:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_93:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_94:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_95:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_96:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_97:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_40]]#0{{\[}}%[[VAL_94]], %[[VAL_96]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_98:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_97]][@comp] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_99:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_98]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_100:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_101:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_40]]#0{{\[}}%[[VAL_101]], %[[VAL_103]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_105:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_104]][@comp] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_106:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_105]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_107:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_99]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_108:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_109:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_110:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_111:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_112:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_40]]#0{{\[}}%[[VAL_109]], %[[VAL_111]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_113:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_112]][@comp] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_114:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_113]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_115:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_107]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_116:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_117:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_116]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_118:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_119:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_118]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_120:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_40]]#0{{\[}}%[[VAL_117]], %[[VAL_119]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:            %[[VAL_121:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_120]][@comp] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_122:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_121]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_123:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_115]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_124:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_8]]{{\[}}%[[VAL_124]]] = %[[VAL_123]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_125:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_126:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_92]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_126]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_7]][@children$inputs] = %[[VAL_40]]#1 : <@Main_1::@Main_1<[]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_.-]+]] = array.new  : <2,2 x !struct.type<@Child_0::@Child_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_132:[0-9a-zA-Z_.-]+]] = %[[VAL_130]] to %[[VAL_128]] step %[[VAL_131]] {
// CONCRETE-NEXT:            scf.for %[[VAL_133:[0-9a-zA-Z_.-]+]] = %[[VAL_130]] to %[[VAL_129]] step %[[VAL_131]] {
// CONCRETE-NEXT:              %[[VAL_134:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_40]]#0{{\[}}%[[VAL_132]], %[[VAL_133]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              %[[VAL_135:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_134]][@comp] : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:              array.write %[[VAL_127]]{{\[}}%[[VAL_132]], %[[VAL_133]]] = %[[VAL_135]] : <2,2 x !struct.type<@Child_0::@Child_0<[]>>>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_7]][@children] = %[[VAL_127]] : <@Main_1::@Main_1<[]>>, !array.type<2,2 x !struct.type<@Child_0::@Child_0<[]>>>
// CONCRETE-NEXT:          struct.writem %[[VAL_7]][@source] = %[[VAL_9]] : <@Main_1::@Main_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_7]][@out] = %[[VAL_8]] : <@Main_1::@Main_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_7]] : !struct.type<@Main_1::@Main_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_136:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_1::@Main_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_136]][@out] : <@Main_1::@Main_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_136]][@source] : <@Main_1::@Main_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_136]][@children] : <@Main_1::@Main_1<[]>>, !array.type<2,2 x !struct.type<@Child_0::@Child_0<[]>>>
// CONCRETE-NEXT:          %[[VAL_140:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_136]][@children$inputs] : <@Main_1::@Main_1<[]>>, !array.type<2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// CONCRETE-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_138]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_142]], %[[VAL_141]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_145:[0-9a-zA-Z_.-]+]] = %[[VAL_143]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_146:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_147:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_145]], %[[VAL_146]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_147]]) %[[VAL_145]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_148:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_149:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_150:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_151:[0-9a-zA-Z_.-]+]] = %[[VAL_149]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_152:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_153:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_151]], %[[VAL_152]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_153]]) %[[VAL_151]] : !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_154:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_155:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_156:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_154]], %[[VAL_155]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_156]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_157:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_158:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_148]], %[[VAL_157]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_158]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_161:[0-9a-zA-Z_.-]+]] = %[[VAL_159]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_162:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_163:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_161]], %[[VAL_162]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_163]]) %[[VAL_161]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_164:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_165:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_166:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_167:[0-9a-zA-Z_.-]+]] = %[[VAL_165]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_168:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_169:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_167]], %[[VAL_168]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_169]]) %[[VAL_167]] : !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_170:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_171:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_172:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_164]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_173:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_174:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_175:[0-9a-zA-Z_.-]+]] = felt.sub %[[VAL_170]], %[[VAL_174]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_176:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_175]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_177:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_173]], %[[VAL_176]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_178:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_177]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_179:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_178]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_180:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_138]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:              constrain.eq %[[VAL_179]], %[[VAL_180]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_181:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_182:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_170]], %[[VAL_181]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_182]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_183:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_184:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_164]], %[[VAL_183]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_184]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_187:[0-9a-zA-Z_.-]+]] = %[[VAL_185]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_188:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_189:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_187]], %[[VAL_188]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_189]]) %[[VAL_187]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_190:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_191:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_192:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_191]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_193:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_194:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_193]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_195:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_192]], %[[VAL_194]]] : <2,2 x !struct.type<@Child_0::@Child_0<[]>>>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_196:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_195]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_197:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_198:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_197]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_199:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_200:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_201:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_198]], %[[VAL_200]]] : <2,2 x !struct.type<@Child_0::@Child_0<[]>>>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_202:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_201]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_203:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_196]], %[[VAL_202]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_204:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_205:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_206:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_207:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_208:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_205]], %[[VAL_207]]] : <2,2 x !struct.type<@Child_0::@Child_0<[]>>>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_209:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_208]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_210:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_203]], %[[VAL_209]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_211:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_212:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_213:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_214:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_213]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_215:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_212]], %[[VAL_214]]] : <2,2 x !struct.type<@Child_0::@Child_0<[]>>>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:            %[[VAL_216:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_215]][@out] : <@Child_0::@Child_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_217:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_210]], %[[VAL_216]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_218:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_219:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_218]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_219]], %[[VAL_217]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_220:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_221:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_190]], %[[VAL_220]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_221]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_222:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_223:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_224:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_225:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_226:[0-9a-zA-Z_.-]+]] = %[[VAL_224]] to %[[VAL_222]] step %[[VAL_225]] {
// CONCRETE-NEXT:            scf.for %[[VAL_227:[0-9a-zA-Z_.-]+]] = %[[VAL_224]] to %[[VAL_223]] step %[[VAL_225]] {
// CONCRETE-NEXT:              %[[VAL_228:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_226]], %[[VAL_227]]] : <2,2 x !struct.type<@Child_0::@Child_0<[]>>>, !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE-NEXT:              %[[VAL_229:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_226]], %[[VAL_227]]] : <2,2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_230:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_229]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              function.call @Child_0::@Child_0::@constrain(%[[VAL_228]], %[[VAL_230]]) : (!struct.type<@Child_0::@Child_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }
