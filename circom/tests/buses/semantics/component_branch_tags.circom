// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Every constructor for a component path needs hidden tag arguments, including
// both parameter-controlled branches and copies of each branch in fixed loops.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Branch(CHOOSE) {
    Tagged() a;
    a.x.size = 2;
    a.x <== 5;
    component child;
    if (CHOOSE != 0) { child = Expand(); }
    else { child = Expand(); }
    child.in <== a;
    signal output out;
    out <== child.out.x[1];
}

template LoopBranch(CHOOSE) {
    Tagged() a;
    Tagged() b;
    a.x.size = 2;
    b.x.size = 3;
    a.x <== 5;
    b.x <== 7;
    component children[2];
    for (var i = 0; i < 2; i++) {
        if (CHOOSE != 0) { children[i] = parallel Expand(); }
        else { children[i] = parallel (parallel Expand()); }
    }
    children[0].in <== a;
    children[1].in <== b;
    signal output out;
    out <== children[0].out.x[1] + children[1].out.x[2];
}

template Main() {
    component fromThen = Branch(1);
    component fromElse = Branch(0);
    component loopThen = LoopBranch(1);
    component loopElse = LoopBranch(0);
    signal output out;
    out <== fromThen.out + fromElse.out + loopThen.out + loopElse.out;
}

component main = Main();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_6::@Main_6<[]>>} {
// CONCRETE-NEXT:    poly.template @Branch_1 {
// CONCRETE-NEXT:      struct.def @Branch_1 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @a : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @child : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:        struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Branch_1::@Branch_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_0:[0-9a-zA-Z_.-]+]] = struct.new : <@Branch_1::@Branch_1<[]>>
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_3]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_1]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_1]][@x] = %[[VAL_6]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_5]][@in] = %[[VAL_1]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_9]], %[[VAL_10]] : index
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_11]], %[[VAL_12]], %[[VAL_10]] : index
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_13]], %[[VAL_14]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_15]] {
// CONCRETE-NEXT:            %[[VAL_16:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_17:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_18:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_16]], %[[VAL_17]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_4]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_20:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_20]] {
// CONCRETE-NEXT:              %[[VAL_21:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@params] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_22:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_5]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_23:[0-9a-zA-Z_.-]+]] = function.call @Expand_0::@Expand_0::@compute(%[[VAL_22]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_4]][@comp] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_24]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_25]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_28]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_29]] : <@Branch_1::@Branch_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@child$inputs] = %[[VAL_5]] : <@Branch_1::@Branch_1<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@child] = %[[VAL_30]] : <@Branch_1::@Branch_1<[]>>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_0]][@a] = %[[VAL_1]] : <@Branch_1::@Branch_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_0]] : !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_31:[0-9a-zA-Z_.-]+]]: !struct.type<@Branch_1::@Branch_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_31]][@out] : <@Branch_1::@Branch_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_31]][@a] : <@Branch_1::@Branch_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_31]][@child] : <@Branch_1::@Branch_1<[]>>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_31]][@child$inputs] : <@Branch_1::@Branch_1<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_33]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_35]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_38]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_33]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_34]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_41]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_42]]{{\[}}%[[VAL_44]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_32]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_35]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_0::@Expand_0::@constrain(%[[VAL_34]], %[[VAL_46]]) : (!struct.type<@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Branch_2 {
// CONCRETE-NEXT:      struct.def @Branch_2 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @a : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @child : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:        struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Branch_2::@Branch_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = struct.new : <@Branch_2::@Branch_2<[]>>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_50]], @params = %[[VAL_49]] }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_48]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_48]][@x] = %[[VAL_53]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_52]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_52]][@in] = %[[VAL_48]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_51]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_58]], %[[VAL_59]], %[[VAL_57]] : index
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_60]], %[[VAL_61]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_62]] {
// CONCRETE-NEXT:            %[[VAL_63:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_51]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_64:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_65:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_63]], %[[VAL_64]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_51]][@count] = %[[VAL_65]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_66:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_67:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_65]], %[[VAL_66]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_67]] {
// CONCRETE-NEXT:              %[[VAL_68:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_51]][@params] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_69:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_52]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_70:[0-9a-zA-Z_.-]+]] = function.call @Expand_0::@Expand_0::@compute(%[[VAL_69]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_51]][@comp] = %[[VAL_70]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_51]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_71]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_72]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_75]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_47]][@out] = %[[VAL_76]] : <@Branch_2::@Branch_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_47]][@child$inputs] = %[[VAL_52]] : <@Branch_2::@Branch_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_51]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_47]][@child] = %[[VAL_77]] : <@Branch_2::@Branch_2<[]>>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_47]][@a] = %[[VAL_48]] : <@Branch_2::@Branch_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_47]] : !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_78:[0-9a-zA-Z_.-]+]]: !struct.type<@Branch_2::@Branch_2<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_78]][@out] : <@Branch_2::@Branch_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_78]][@a] : <@Branch_2::@Branch_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_78]][@child] : <@Branch_2::@Branch_2<[]>>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_78]][@child$inputs] : <@Branch_2::@Branch_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_80]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_84]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_82]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_85]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_80]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_86]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_81]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_88]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_91]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_79]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_82]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_0::@Expand_0::@constrain(%[[VAL_81]], %[[VAL_93]]) : (!struct.type<@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Expand_0 {
// CONCRETE-NEXT:      struct.def @Expand_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_94:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Expand_0::@Expand_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_99:[0-9a-zA-Z_.-]+]] = %[[VAL_97]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_100:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_101:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_99]], %[[VAL_100]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_101]]) %[[VAL_99]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_102:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_94]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_96]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_105:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_106:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_105]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_104]]{{\[}}%[[VAL_105]]] = %[[VAL_103]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_96]][@x] = %[[VAL_104]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_107:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_108:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_102]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_108]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_95]][@out] = %[[VAL_96]] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_95]] : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_109:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand_0::@Expand_0<[]>>, %[[VAL_110:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_109]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_114:[0-9a-zA-Z_.-]+]] = %[[VAL_112]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_115:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_116:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_114]], %[[VAL_115]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_116]]) %[[VAL_114]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_117:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_118:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_110]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_119:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_120:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_121:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_120]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_121]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_122:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_123:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_117]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_123]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Expand_3 {
// CONCRETE-NEXT:      struct.def @Expand_3 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_124:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Expand_3::@Expand_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_129:[0-9a-zA-Z_.-]+]] = %[[VAL_127]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_130:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_131:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_129]], %[[VAL_130]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_131]]) %[[VAL_129]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_132:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_133:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_124]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_134:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_126]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_135:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_132]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_136:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_134]]{{\[}}%[[VAL_135]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_134]]{{\[}}%[[VAL_135]]] = %[[VAL_133]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_126]][@x] = %[[VAL_134]] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_137:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_138:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_132]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_138]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_125]][@out] = %[[VAL_126]] : <@Expand_3::@Expand_3<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_125]] : !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_139:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand_3::@Expand_3<[]>>, %[[VAL_140:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_139]][@out] : <@Expand_3::@Expand_3<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_144:[0-9a-zA-Z_.-]+]] = %[[VAL_142]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_145:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_146:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_144]], %[[VAL_145]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_146]]) %[[VAL_144]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_147:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_148:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_140]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_149:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_141]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_150:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_147]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_151:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_149]]{{\[}}%[[VAL_150]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_151]], %[[VAL_148]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_152:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_153:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_147]], %[[VAL_152]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_153]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @LoopBranch_4 {
// CONCRETE-NEXT:      struct.def @LoopBranch_4 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @a : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @b : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @children : !pod.type<[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE-NEXT:        struct.member @children$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@LoopBranch_4::@LoopBranch_4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_154:[0-9a-zA-Z_.-]+]] = struct.new : <@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_158:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_158]], @params = %[[VAL_157]] }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_160]], @params = %[[VAL_157]] }  : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = pod.new { @idx_0 = %[[VAL_159]], @idx_1 = %[[VAL_161]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = pod.new : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_155]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_155]][@x] = %[[VAL_164]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_167:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_156]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_156]][@x] = %[[VAL_166]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_170:[0-9a-zA-Z_.-]+]] = %[[VAL_168]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_171:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_172:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_170]], %[[VAL_171]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_172]]) %[[VAL_170]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_173:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_174:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_175:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_173]], %[[VAL_174]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_175]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_176:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_177:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_178:[0-9a-zA-Z_.-]+]] = arith.constant true
// CONCRETE-NEXT:          %[[VAL_179:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_180:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_177]], %[[VAL_179]] : index
// CONCRETE-NEXT:          %[[VAL_181:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_178]], %[[VAL_180]] : i1, i1
// CONCRETE-NEXT:          %[[VAL_182:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_183:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_177]], %[[VAL_182]] : index
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_178]], %[[VAL_183]] : i1, i1
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_.-]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:            %[[VAL_186:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_184]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:              %[[VAL_187:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_162]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              %[[VAL_188:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_189:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_188]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_188]][@in] = %[[VAL_155]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_163]][@idx_1] = %[[VAL_188]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_190:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_187]][@count] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_191:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_192:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_190]], %[[VAL_191]] : index
// CONCRETE-NEXT:              pod.write %[[VAL_187]][@count] = %[[VAL_192]] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_193:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_194:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_192]], %[[VAL_193]] : index
// CONCRETE-NEXT:              scf.if %[[VAL_194]] {
// CONCRETE-NEXT:                %[[VAL_195:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_187]][@params] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                %[[VAL_196:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_188]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_197:[0-9a-zA-Z_.-]+]] = function.call @Expand_3::@Expand_3::@compute(%[[VAL_196]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:                pod.write %[[VAL_187]][@comp] = %[[VAL_197]] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              pod.write %[[VAL_162]][@idx_1] = %[[VAL_187]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              scf.yield %[[VAL_162]], %[[VAL_163]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_198:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_181]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_199:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_162]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_200:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_201:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_200]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                pod.write %[[VAL_200]][@in] = %[[VAL_155]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                pod.write %[[VAL_163]][@idx_0] = %[[VAL_200]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_202:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_199]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_203:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_204:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_202]], %[[VAL_203]] : index
// CONCRETE-NEXT:                pod.write %[[VAL_199]][@count] = %[[VAL_204]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_205:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_206:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_204]], %[[VAL_205]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_206]] {
// CONCRETE-NEXT:                  %[[VAL_207:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_199]][@params] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                  %[[VAL_208:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_200]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_209:[0-9a-zA-Z_.-]+]] = function.call @Expand_0::@Expand_0::@compute(%[[VAL_208]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_199]][@comp] = %[[VAL_209]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                pod.write %[[VAL_162]][@idx_0] = %[[VAL_199]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_162]], %[[VAL_163]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_210:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                %[[VAL_211:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_210]], %[[VAL_211]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_198]]#0, %[[VAL_198]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            scf.yield %[[VAL_186]]#0, %[[VAL_186]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_212:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_213:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_212]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_214:[0-9a-zA-Z_.-]+]] = arith.constant true
// CONCRETE-NEXT:          %[[VAL_215:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_216:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_213]], %[[VAL_215]] : index
// CONCRETE-NEXT:          %[[VAL_217:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_214]], %[[VAL_216]] : i1, i1
// CONCRETE-NEXT:          %[[VAL_218:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_219:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_213]], %[[VAL_218]] : index
// CONCRETE-NEXT:          %[[VAL_220:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_214]], %[[VAL_219]] : i1, i1
// CONCRETE-NEXT:          %[[VAL_221:[0-9a-zA-Z_.-]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:            %[[VAL_222:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_220]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:              %[[VAL_223:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_185]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              %[[VAL_224:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_185]]#1[@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_225:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_224]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_224]][@in] = %[[VAL_156]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_185]]#1[@idx_1] = %[[VAL_224]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_226:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_223]][@count] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_227:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_228:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_226]], %[[VAL_227]] : index
// CONCRETE-NEXT:              pod.write %[[VAL_223]][@count] = %[[VAL_228]] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_229:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_230:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_228]], %[[VAL_229]] : index
// CONCRETE-NEXT:              scf.if %[[VAL_230]] {
// CONCRETE-NEXT:                %[[VAL_231:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_223]][@params] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                %[[VAL_232:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_224]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_233:[0-9a-zA-Z_.-]+]] = function.call @Expand_3::@Expand_3::@compute(%[[VAL_232]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:                pod.write %[[VAL_223]][@comp] = %[[VAL_233]] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              pod.write %[[VAL_185]]#0[@idx_1] = %[[VAL_223]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              scf.yield %[[VAL_185]]#0, %[[VAL_185]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_234:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_217]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_235:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_185]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_236:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_185]]#1[@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_237:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_236]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                pod.write %[[VAL_236]][@in] = %[[VAL_156]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                pod.write %[[VAL_185]]#1[@idx_0] = %[[VAL_236]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_238:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_235]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_239:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_240:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_238]], %[[VAL_239]] : index
// CONCRETE-NEXT:                pod.write %[[VAL_235]][@count] = %[[VAL_240]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_241:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_242:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_240]], %[[VAL_241]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_242]] {
// CONCRETE-NEXT:                  %[[VAL_243:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_235]][@params] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                  %[[VAL_244:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_236]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_245:[0-9a-zA-Z_.-]+]] = function.call @Expand_0::@Expand_0::@compute(%[[VAL_244]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_235]][@comp] = %[[VAL_245]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                pod.write %[[VAL_185]]#0[@idx_0] = %[[VAL_235]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_185]]#0, %[[VAL_185]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_246:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                %[[VAL_247:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_246]], %[[VAL_247]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_234]]#0, %[[VAL_234]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            scf.yield %[[VAL_222]]#0, %[[VAL_222]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_248:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_221]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_249:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_248]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_250:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_249]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_251:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_250]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_252:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_253:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_252]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_254:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_251]]{{\[}}%[[VAL_253]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_255:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_221]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_256:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_255]][@comp] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_257:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_256]][@out] : <@Expand_3::@Expand_3<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_258:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_257]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_259:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_260:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_259]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_261:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_258]]{{\[}}%[[VAL_260]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_262:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_254]], %[[VAL_261]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_154]][@out] = %[[VAL_262]] : <@LoopBranch_4::@LoopBranch_4<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_154]][@children$inputs] = %[[VAL_221]]#1 : <@LoopBranch_4::@LoopBranch_4<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_263:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_221]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_264:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_263]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_265:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_221]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_266:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_265]][@comp] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_267:[0-9a-zA-Z_.-]+]] = pod.new { @idx_0 = %[[VAL_264]], @idx_1 = %[[VAL_266]] }  : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_154]][@children] = %[[VAL_267]] : <@LoopBranch_4::@LoopBranch_4<[]>>, !pod.type<[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_154]][@a] = %[[VAL_155]] : <@LoopBranch_4::@LoopBranch_4<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_154]][@b] = %[[VAL_156]] : <@LoopBranch_4::@LoopBranch_4<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_154]] : !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_268:[0-9a-zA-Z_.-]+]]: !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_269:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_268]][@out] : <@LoopBranch_4::@LoopBranch_4<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_270:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_268]][@a] : <@LoopBranch_4::@LoopBranch_4<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_271:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_268]][@b] : <@LoopBranch_4::@LoopBranch_4<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_272:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_268]][@children] : <@LoopBranch_4::@LoopBranch_4<[]>>, !pod.type<[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE-NEXT:          %[[VAL_273:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_268]][@children$inputs] : <@LoopBranch_4::@LoopBranch_4<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_274:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_275:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_270]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_275]], %[[VAL_274]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_276:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_277:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_271]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_277]], %[[VAL_276]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_278:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_279:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_280:[0-9a-zA-Z_.-]+]] = %[[VAL_278]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_281:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_282:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_280]], %[[VAL_281]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_282]]) %[[VAL_280]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_283:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_284:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_285:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_283]], %[[VAL_284]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_285]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_286:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_273]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_287:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_286]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_288:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_287]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_289:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_270]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_288]], %[[VAL_289]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_290:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_273]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_291:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_290]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_292:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_291]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_293:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_271]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_292]], %[[VAL_293]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_294:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_272]][@idx_0] : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_295:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_296:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_295]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_297:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_298:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_297]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_299:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_296]]{{\[}}%[[VAL_298]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_300:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_272]][@idx_1] : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_301:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_300]][@out] : <@Expand_3::@Expand_3<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_302:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_301]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_303:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_304:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_303]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_305:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_302]]{{\[}}%[[VAL_304]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_306:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_299]], %[[VAL_305]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_269]], %[[VAL_306]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_307:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_272]][@idx_0] : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_308:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_273]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_309:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_308]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_0::@Expand_0::@constrain(%[[VAL_307]], %[[VAL_309]]) : (!struct.type<@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_310:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_272]][@idx_1] : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_311:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_273]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_312:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_311]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_3::@Expand_3::@constrain(%[[VAL_310]], %[[VAL_312]]) : (!struct.type<@Expand_3::@Expand_3<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @LoopBranch_5 {
// CONCRETE-NEXT:      struct.def @LoopBranch_5 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @a : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @b : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @children : !pod.type<[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE-NEXT:        struct.member @children$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@LoopBranch_5::@LoopBranch_5<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_313:[0-9a-zA-Z_.-]+]] = struct.new : <@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE-NEXT:          %[[VAL_314:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_315:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_316:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_317:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_318:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_317]], @params = %[[VAL_316]] }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_319:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_320:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_319]], @params = %[[VAL_316]] }  : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_321:[0-9a-zA-Z_.-]+]] = pod.new { @idx_0 = %[[VAL_318]], @idx_1 = %[[VAL_320]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:          %[[VAL_322:[0-9a-zA-Z_.-]+]] = pod.new : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_323:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_324:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_314]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_314]][@x] = %[[VAL_323]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_325:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_326:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_315]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_315]][@x] = %[[VAL_325]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_327:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_328:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_329:[0-9a-zA-Z_.-]+]] = %[[VAL_327]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_330:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_331:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_329]], %[[VAL_330]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_331]]) %[[VAL_329]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_332:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_333:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_334:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_332]], %[[VAL_333]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_334]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_335:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_336:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_335]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_337:[0-9a-zA-Z_.-]+]] = arith.constant true
// CONCRETE-NEXT:          %[[VAL_338:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_339:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_336]], %[[VAL_338]] : index
// CONCRETE-NEXT:          %[[VAL_340:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_337]], %[[VAL_339]] : i1, i1
// CONCRETE-NEXT:          %[[VAL_341:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_342:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_336]], %[[VAL_341]] : index
// CONCRETE-NEXT:          %[[VAL_343:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_337]], %[[VAL_342]] : i1, i1
// CONCRETE-NEXT:          %[[VAL_344:[0-9a-zA-Z_.-]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:            %[[VAL_345:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_343]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:              %[[VAL_346:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_321]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              %[[VAL_347:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_322]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_348:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_347]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_347]][@in] = %[[VAL_314]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_322]][@idx_1] = %[[VAL_347]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_349:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_346]][@count] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_350:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_351:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_349]], %[[VAL_350]] : index
// CONCRETE-NEXT:              pod.write %[[VAL_346]][@count] = %[[VAL_351]] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_352:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_353:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_351]], %[[VAL_352]] : index
// CONCRETE-NEXT:              scf.if %[[VAL_353]] {
// CONCRETE-NEXT:                %[[VAL_354:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_346]][@params] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                %[[VAL_355:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_347]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_356:[0-9a-zA-Z_.-]+]] = function.call @Expand_3::@Expand_3::@compute(%[[VAL_355]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:                pod.write %[[VAL_346]][@comp] = %[[VAL_356]] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              pod.write %[[VAL_321]][@idx_1] = %[[VAL_346]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              scf.yield %[[VAL_321]], %[[VAL_322]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_357:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_340]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_358:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_321]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_359:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_322]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_360:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_359]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                pod.write %[[VAL_359]][@in] = %[[VAL_314]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                pod.write %[[VAL_322]][@idx_0] = %[[VAL_359]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_361:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_358]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_362:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_363:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_361]], %[[VAL_362]] : index
// CONCRETE-NEXT:                pod.write %[[VAL_358]][@count] = %[[VAL_363]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_364:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_365:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_363]], %[[VAL_364]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_365]] {
// CONCRETE-NEXT:                  %[[VAL_366:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_358]][@params] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                  %[[VAL_367:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_359]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_368:[0-9a-zA-Z_.-]+]] = function.call @Expand_0::@Expand_0::@compute(%[[VAL_367]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_358]][@comp] = %[[VAL_368]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                pod.write %[[VAL_321]][@idx_0] = %[[VAL_358]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_321]], %[[VAL_322]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_369:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                %[[VAL_370:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_369]], %[[VAL_370]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_357]]#0, %[[VAL_357]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            scf.yield %[[VAL_345]]#0, %[[VAL_345]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_371:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_372:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_371]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_373:[0-9a-zA-Z_.-]+]] = arith.constant true
// CONCRETE-NEXT:          %[[VAL_374:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_375:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_372]], %[[VAL_374]] : index
// CONCRETE-NEXT:          %[[VAL_376:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_373]], %[[VAL_375]] : i1, i1
// CONCRETE-NEXT:          %[[VAL_377:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_378:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_372]], %[[VAL_377]] : index
// CONCRETE-NEXT:          %[[VAL_379:[0-9a-zA-Z_.-]+]] = bool.and %[[VAL_373]], %[[VAL_378]] : i1, i1
// CONCRETE-NEXT:          %[[VAL_380:[0-9a-zA-Z_.-]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:            %[[VAL_381:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_379]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:              %[[VAL_382:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_344]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              %[[VAL_383:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_344]]#1[@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_384:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_383]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_383]][@in] = %[[VAL_315]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              pod.write %[[VAL_344]]#1[@idx_1] = %[[VAL_383]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_385:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_382]][@count] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_386:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_387:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_385]], %[[VAL_386]] : index
// CONCRETE-NEXT:              pod.write %[[VAL_382]][@count] = %[[VAL_387]] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:              %[[VAL_388:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_389:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_387]], %[[VAL_388]] : index
// CONCRETE-NEXT:              scf.if %[[VAL_389]] {
// CONCRETE-NEXT:                %[[VAL_390:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_382]][@params] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                %[[VAL_391:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_383]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                %[[VAL_392:[0-9a-zA-Z_.-]+]] = function.call @Expand_3::@Expand_3::@compute(%[[VAL_391]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:                pod.write %[[VAL_382]][@comp] = %[[VAL_392]] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              pod.write %[[VAL_344]]#0[@idx_1] = %[[VAL_382]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:              scf.yield %[[VAL_344]]#0, %[[VAL_344]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            } else {
// CONCRETE-NEXT:              %[[VAL_393:[0-9a-zA-Z_.-]+]]:2 = scf.if %[[VAL_376]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_394:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_344]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                %[[VAL_395:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_344]]#1[@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_396:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_395]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                pod.write %[[VAL_395]][@in] = %[[VAL_315]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                pod.write %[[VAL_344]]#1[@idx_0] = %[[VAL_395]] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:                %[[VAL_397:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_394]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_398:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                %[[VAL_399:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_397]], %[[VAL_398]] : index
// CONCRETE-NEXT:                pod.write %[[VAL_394]][@count] = %[[VAL_399]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                %[[VAL_400:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                %[[VAL_401:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_399]], %[[VAL_400]] : index
// CONCRETE-NEXT:                scf.if %[[VAL_401]] {
// CONCRETE-NEXT:                  %[[VAL_402:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_394]][@params] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                  %[[VAL_403:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_395]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_404:[0-9a-zA-Z_.-]+]] = function.call @Expand_0::@Expand_0::@compute(%[[VAL_403]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_394]][@comp] = %[[VAL_404]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                pod.write %[[VAL_344]]#0[@idx_0] = %[[VAL_394]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_344]]#0, %[[VAL_344]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              } else {
// CONCRETE-NEXT:                %[[VAL_405:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                %[[VAL_406:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:                scf.yield %[[VAL_405]], %[[VAL_406]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              scf.yield %[[VAL_393]]#0, %[[VAL_393]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            scf.yield %[[VAL_381]]#0, %[[VAL_381]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_407:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_380]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_408:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_407]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_409:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_408]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_410:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_409]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_411:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_412:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_411]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_413:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_410]]{{\[}}%[[VAL_412]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_414:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_380]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_415:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_414]][@comp] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_416:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_415]][@out] : <@Expand_3::@Expand_3<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_417:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_416]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_418:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_419:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_418]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_420:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_417]]{{\[}}%[[VAL_419]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_421:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_413]], %[[VAL_420]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_313]][@out] = %[[VAL_421]] : <@LoopBranch_5::@LoopBranch_5<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_313]][@children$inputs] = %[[VAL_380]]#1 : <@LoopBranch_5::@LoopBranch_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_422:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_380]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_423:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_422]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_424:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_380]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_425:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_424]][@comp] : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_426:[0-9a-zA-Z_.-]+]] = pod.new { @idx_0 = %[[VAL_423]], @idx_1 = %[[VAL_425]] }  : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_313]][@children] = %[[VAL_426]] : <@LoopBranch_5::@LoopBranch_5<[]>>, !pod.type<[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_313]][@a] = %[[VAL_314]] : <@LoopBranch_5::@LoopBranch_5<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_313]][@b] = %[[VAL_315]] : <@LoopBranch_5::@LoopBranch_5<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.return %[[VAL_313]] : !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_427:[0-9a-zA-Z_.-]+]]: !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_428:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_427]][@out] : <@LoopBranch_5::@LoopBranch_5<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_429:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_427]][@a] : <@LoopBranch_5::@LoopBranch_5<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_430:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_427]][@b] : <@LoopBranch_5::@LoopBranch_5<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_431:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_427]][@children] : <@LoopBranch_5::@LoopBranch_5<[]>>, !pod.type<[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE-NEXT:          %[[VAL_432:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_427]][@children$inputs] : <@LoopBranch_5::@LoopBranch_5<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_433:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_434:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_429]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_434]], %[[VAL_433]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_435:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_436:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_430]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_436]], %[[VAL_435]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_437:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_438:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_439:[0-9a-zA-Z_.-]+]] = %[[VAL_437]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_440:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_441:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_439]], %[[VAL_440]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_441]]) %[[VAL_439]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_442:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_443:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_444:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_442]], %[[VAL_443]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_444]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_445:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_432]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_446:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_445]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_447:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_446]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_448:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_429]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_447]], %[[VAL_448]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_449:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_432]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_450:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_449]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_451:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_450]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_452:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_430]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_451]], %[[VAL_452]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_453:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_431]][@idx_0] : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_454:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_453]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_455:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_454]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_456:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_457:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_456]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_458:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_455]]{{\[}}%[[VAL_457]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_459:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_431]][@idx_1] : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_460:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_459]][@out] : <@Expand_3::@Expand_3<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_461:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_460]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_462:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_463:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_462]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_464:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_461]]{{\[}}%[[VAL_463]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_465:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_458]], %[[VAL_464]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_428]], %[[VAL_465]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_466:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_431]][@idx_0] : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_467:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_432]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_468:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_467]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_0::@Expand_0::@constrain(%[[VAL_466]], %[[VAL_468]]) : (!struct.type<@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_469:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_431]][@idx_1] : <[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>, !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE-NEXT:          %[[VAL_470:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_432]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, @idx_1: !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>]>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_471:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_470]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_3::@Expand_3::@constrain(%[[VAL_469]], %[[VAL_471]]) : (!struct.type<@Expand_3::@Expand_3<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Main_6 {
// CONCRETE-NEXT:      struct.def @Main_6 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @fromElse : !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE-NEXT:        struct.member @fromElse$inputs : !pod.type<[]>
// CONCRETE-NEXT:        struct.member @fromThen : !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE-NEXT:        struct.member @fromThen$inputs : !pod.type<[]>
// CONCRETE-NEXT:        struct.member @loopElse : !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE-NEXT:        struct.member @loopElse$inputs : !pod.type<[]>
// CONCRETE-NEXT:        struct.member @loopThen : !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE-NEXT:        struct.member @loopThen$inputs : !pod.type<[]>
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Main_6::@Main_6<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_472:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_6::@Main_6<[]>>
// CONCRETE-NEXT:          %[[VAL_473:[0-9a-zA-Z_.-]+]] = function.call @Branch_2::@Branch_2::@compute() : () -> !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE-NEXT:          %[[VAL_474:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %[[VAL_473]] }  : <[@count: index, @comp: !struct.type<@Branch_2::@Branch_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_475:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_476:[0-9a-zA-Z_.-]+]] = function.call @Branch_1::@Branch_1::@compute() : () -> !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE-NEXT:          %[[VAL_477:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %[[VAL_476]] }  : <[@count: index, @comp: !struct.type<@Branch_1::@Branch_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_478:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_479:[0-9a-zA-Z_.-]+]] = function.call @LoopBranch_5::@LoopBranch_5::@compute() : () -> !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE-NEXT:          %[[VAL_480:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %[[VAL_479]] }  : <[@count: index, @comp: !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_481:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_482:[0-9a-zA-Z_.-]+]] = function.call @LoopBranch_4::@LoopBranch_4::@compute() : () -> !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE-NEXT:          %[[VAL_483:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %[[VAL_482]] }  : <[@count: index, @comp: !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_484:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_485:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_477]][@comp] : <[@count: index, @comp: !struct.type<@Branch_1::@Branch_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE-NEXT:          %[[VAL_486:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_485]][@out] : <@Branch_1::@Branch_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_487:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_474]][@comp] : <[@count: index, @comp: !struct.type<@Branch_2::@Branch_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE-NEXT:          %[[VAL_488:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_487]][@out] : <@Branch_2::@Branch_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_489:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_486]], %[[VAL_488]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_490:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_483]][@comp] : <[@count: index, @comp: !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>, @params: !pod.type<[]>]>, !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE-NEXT:          %[[VAL_491:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_490]][@out] : <@LoopBranch_4::@LoopBranch_4<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_492:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_489]], %[[VAL_491]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_493:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_480]][@comp] : <[@count: index, @comp: !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>, @params: !pod.type<[]>]>, !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE-NEXT:          %[[VAL_494:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_493]][@out] : <@LoopBranch_5::@LoopBranch_5<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_495:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_492]], %[[VAL_494]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@out] = %[[VAL_495]] : <@Main_6::@Main_6<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@fromElse$inputs] = %[[VAL_475]] : <@Main_6::@Main_6<[]>>, !pod.type<[]>
// CONCRETE-NEXT:          %[[VAL_496:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_474]][@comp] : <[@count: index, @comp: !struct.type<@Branch_2::@Branch_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@fromElse] = %[[VAL_496]] : <@Main_6::@Main_6<[]>>, !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@fromThen$inputs] = %[[VAL_478]] : <@Main_6::@Main_6<[]>>, !pod.type<[]>
// CONCRETE-NEXT:          %[[VAL_497:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_477]][@comp] : <[@count: index, @comp: !struct.type<@Branch_1::@Branch_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@fromThen] = %[[VAL_497]] : <@Main_6::@Main_6<[]>>, !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@loopElse$inputs] = %[[VAL_481]] : <@Main_6::@Main_6<[]>>, !pod.type<[]>
// CONCRETE-NEXT:          %[[VAL_498:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_480]][@comp] : <[@count: index, @comp: !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>, @params: !pod.type<[]>]>, !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@loopElse] = %[[VAL_498]] : <@Main_6::@Main_6<[]>>, !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@loopThen$inputs] = %[[VAL_484]] : <@Main_6::@Main_6<[]>>, !pod.type<[]>
// CONCRETE-NEXT:          %[[VAL_499:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_483]][@comp] : <[@count: index, @comp: !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>, @params: !pod.type<[]>]>, !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_472]][@loopThen] = %[[VAL_499]] : <@Main_6::@Main_6<[]>>, !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_472]] : !struct.type<@Main_6::@Main_6<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_500:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_6::@Main_6<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_501:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@out] : <@Main_6::@Main_6<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_502:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@fromElse] : <@Main_6::@Main_6<[]>>, !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE-NEXT:          %[[VAL_503:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@fromElse$inputs] : <@Main_6::@Main_6<[]>>, !pod.type<[]>
// CONCRETE-NEXT:          %[[VAL_504:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@fromThen] : <@Main_6::@Main_6<[]>>, !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE-NEXT:          %[[VAL_505:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@fromThen$inputs] : <@Main_6::@Main_6<[]>>, !pod.type<[]>
// CONCRETE-NEXT:          %[[VAL_506:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@loopElse] : <@Main_6::@Main_6<[]>>, !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE-NEXT:          %[[VAL_507:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@loopElse$inputs] : <@Main_6::@Main_6<[]>>, !pod.type<[]>
// CONCRETE-NEXT:          %[[VAL_508:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@loopThen] : <@Main_6::@Main_6<[]>>, !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE-NEXT:          %[[VAL_509:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_500]][@loopThen$inputs] : <@Main_6::@Main_6<[]>>, !pod.type<[]>
// CONCRETE-NEXT:          %[[VAL_510:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_504]][@out] : <@Branch_1::@Branch_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_511:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_502]][@out] : <@Branch_2::@Branch_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_512:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_510]], %[[VAL_511]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_513:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_508]][@out] : <@LoopBranch_4::@LoopBranch_4<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_514:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_512]], %[[VAL_513]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_515:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_506]][@out] : <@LoopBranch_5::@LoopBranch_5<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_516:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_514]], %[[VAL_515]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_501]], %[[VAL_516]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.call @Branch_2::@Branch_2::@constrain(%[[VAL_502]]) : (!struct.type<@Branch_2::@Branch_2<[]>>) -> ()
// CONCRETE-NEXT:          function.call @Branch_1::@Branch_1::@constrain(%[[VAL_504]]) : (!struct.type<@Branch_1::@Branch_1<[]>>) -> ()
// CONCRETE-NEXT:          function.call @LoopBranch_5::@LoopBranch_5::@constrain(%[[VAL_506]]) : (!struct.type<@LoopBranch_5::@LoopBranch_5<[]>>) -> ()
// CONCRETE-NEXT:          function.call @LoopBranch_4::@LoopBranch_4::@constrain(%[[VAL_508]]) : (!struct.type<@LoopBranch_4::@LoopBranch_4<[]>>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// TEMPLATED-NEXT:    poly.template @Branch {
// TEMPLATED-NEXT:      poly.param @CHOOSE
// TEMPLATED-NEXT:      struct.def @Branch {
// TEMPLATED-NEXT:        struct.member @a : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @child : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:        struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Branch::@Branch<[@CHOOSE]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_0:[0-9a-zA-Z_.-]+]] = struct.new : <@Branch::@Branch<[@CHOOSE]>>
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = poly.read_const @CHOOSE : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_2]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@x] = %[[VAL_4]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_1]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_7]] -> (!pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>) {
// TEMPLATED-NEXT:            %[[VAL_9:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_10:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_9]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_11:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_11]], @params = %[[VAL_10]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_12]] : !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_13:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_14:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_13]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_15:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_16:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_15]], @params = %[[VAL_14]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_16]] : !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_8]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_20]], %[[VAL_21]], %[[VAL_19]] : index
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_22]], %[[VAL_23]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_24]] {
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_8]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_25]], %[[VAL_26]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_8]][@count] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_29]] {
// TEMPLATED-NEXT:              %[[VAL_30:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_8]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_31:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_3]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_32:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_31]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_8]][@comp] = %[[VAL_32]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_33]][@out] : <@Expand::@Expand<[2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_34]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_37]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_38]] : <@Branch::@Branch<[@CHOOSE]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@child$inputs] = %[[VAL_3]] : <@Branch::@Branch<[@CHOOSE]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@child] = %[[VAL_39]] : <@Branch::@Branch<[@CHOOSE]>>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_0]][@a] = %[[VAL_2]] : <@Branch::@Branch<[@CHOOSE]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_0]] : !struct.type<@Branch::@Branch<[@CHOOSE]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_40:[0-9a-zA-Z_.-]+]]: !struct.type<@Branch::@Branch<[@CHOOSE]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = poly.read_const @CHOOSE : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_40]][@a] : <@Branch::@Branch<[@CHOOSE]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_40]][@out] : <@Branch::@Branch<[@CHOOSE]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_40]][@child] : <@Branch::@Branch<[@CHOOSE]>>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_40]][@child$inputs] : <@Branch::@Branch<[@CHOOSE]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_42]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_41]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_49]] {
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_50]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_42]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_51]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_44]][@out] : <@Expand::@Expand<[2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_53]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_56]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @Expand::@Expand::@constrain(%[[VAL_44]], %[[VAL_58]]) : (!struct.type<@Expand::@Expand<[2]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Expand {
// TEMPLATED-NEXT:      poly.param @"$tag$in$x$size" : index
// TEMPLATED-NEXT:      struct.def @Expand {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_59:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand::@Expand<[@"$tag$in$x$size"]>>
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : index
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_61]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_66:[0-9a-zA-Z_.-]+]] = %[[VAL_64]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_67:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_66]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_67]]) %[[VAL_66]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_68:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_69:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_59]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_70:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_63]][@x] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_71:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_72:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_71]]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_70]]{{\[}}%[[VAL_71]]] = %[[VAL_69]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_63]][@x] = %[[VAL_70]] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_73:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_74:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_68]], %[[VAL_73]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_74]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_60]][@out] = %[[VAL_63]] : <@Expand::@Expand<[@"$tag$in$x$size"]>>, !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_60]] : !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_75:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>>, %[[VAL_76:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : index
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_77]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_75]][@out] : <@Expand::@Expand<[@"$tag$in$x$size"]>>, !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_82:[0-9a-zA-Z_.-]+]] = %[[VAL_80]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_83:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_78]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_83]]) %[[VAL_82]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_84:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_85:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_76]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_86:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_79]][@x] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_87]]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_88]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_89:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_90:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_84]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_90]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @LoopBranch {
// TEMPLATED-NEXT:      poly.param @CHOOSE
// TEMPLATED-NEXT:      struct.def @LoopBranch {
// TEMPLATED-NEXT:        struct.member @a : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @b : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @children : !array.type<2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:        struct.member @children$inputs : !array.type<2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@LoopBranch::@LoopBranch<[@CHOOSE]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_.-]+]] = struct.new : <@LoopBranch::@LoopBranch<[@CHOOSE]>>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_.-]+]] = poly.read_const @CHOOSE : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = array.new  : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_93]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_93]][@x] = %[[VAL_97]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_94]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_94]][@x] = %[[VAL_99]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_92]], %[[VAL_101]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_102]] {
// TEMPLATED-NEXT:            %[[VAL_103:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_104:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_103]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_105:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_106:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_105]], @params = %[[VAL_104]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_107:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_108:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_109:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_106]] : (!pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_95]]{{\[}}%[[VAL_108]]] = %[[VAL_109]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_110:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_111:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_110]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_112]], @params = %[[VAL_111]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_114:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_115:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_113]] : (!pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_95]]{{\[}}%[[VAL_115]]] = %[[VAL_116]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_117:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_117]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_92]], %[[VAL_120]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_121]] {
// TEMPLATED-NEXT:            %[[VAL_122:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_123:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_122]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_124:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_125:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_124]], @params = %[[VAL_123]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_126:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_127:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_128:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_125]] : (!pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_95]]{{\[}}%[[VAL_127]]] = %[[VAL_128]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            %[[VAL_129:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_130:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_129]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_131:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_132:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_131]], @params = %[[VAL_130]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_133:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_134:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_135:[0-9a-zA-Z_.-]+]] = poly.unifiable_cast %[[VAL_132]] : (!pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            array.write %[[VAL_95]]{{\[}}%[[VAL_134]]] = %[[VAL_135]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_136]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_139]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_140]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_140]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_141]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_141]][@in] = %[[VAL_93]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_144:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_142]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_145:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_144]], %[[VAL_145]] : index
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_146]], %[[VAL_147]], %[[VAL_145]] : index
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_148]], %[[VAL_149]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_150]] {
// TEMPLATED-NEXT:            %[[VAL_151:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_142]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_152:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_153:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_151]], %[[VAL_152]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_142]][@count] = %[[VAL_153]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_154:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_155:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_153]], %[[VAL_154]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_155]] {
// TEMPLATED-NEXT:              %[[VAL_156:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_142]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_157:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_141]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_158:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_156]][@"$tag$in$x$size"] : <[@"$tag$in$x$size": !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_159:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_160:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_157]]) {(%[[VAL_159]])} : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_142]][@comp] = %[[VAL_160]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_96]]{{\[}}%[[VAL_140]]] = %[[VAL_141]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_95]]{{\[}}%[[VAL_140]]] = %[[VAL_142]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_162]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_162]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_163]][@in] = %[[VAL_94]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_168:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_166]], %[[VAL_167]] : index
// TEMPLATED-NEXT:          %[[VAL_169:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_168]], %[[VAL_169]], %[[VAL_167]] : index
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_171]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_172]] {
// TEMPLATED-NEXT:            %[[VAL_173:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_174:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_175:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_173]], %[[VAL_174]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_164]][@count] = %[[VAL_175]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_176:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_177:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_175]], %[[VAL_176]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_177]] {
// TEMPLATED-NEXT:              %[[VAL_178:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_164]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_179:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_180:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_178]][@"$tag$in$x$size"] : <[@"$tag$in$x$size": !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_181:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_180]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_182:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_179]]) {(%[[VAL_181]])} : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_164]][@comp] = %[[VAL_182]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          array.write %[[VAL_96]]{{\[}}%[[VAL_162]]] = %[[VAL_163]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_95]]{{\[}}%[[VAL_162]]] = %[[VAL_164]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_183]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_184]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_186:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_185]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_187:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_186]][@out] : <@Expand::@Expand<[#[[$ATTR_0]]]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_188:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_187]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_189:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_189]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_188]]{{\[}}%[[VAL_190]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_192]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_193]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_194]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_195]][@out] : <@Expand::@Expand<[#[[$ATTR_0]]]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_196]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_198]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_197]]{{\[}}%[[VAL_199]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_191]], %[[VAL_200]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_91]][@out] = %[[VAL_201]] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_91]][@children$inputs] = %[[VAL_96]] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_.-]+]] = array.new  : <2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_204:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_206:[0-9a-zA-Z_.-]+]] = %[[VAL_204]] to %[[VAL_203]] step %[[VAL_205]] {
// TEMPLATED-NEXT:            %[[VAL_207:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_206]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_208:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_207]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_202]]{{\[}}%[[VAL_206]]] = %[[VAL_208]] : <2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_91]][@children] = %[[VAL_202]] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !array.type<2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_91]][@a] = %[[VAL_93]] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_91]][@b] = %[[VAL_94]] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.return %[[VAL_91]] : !struct.type<@LoopBranch::@LoopBranch<[@CHOOSE]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_209:[0-9a-zA-Z_.-]+]]: !struct.type<@LoopBranch::@LoopBranch<[@CHOOSE]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_.-]+]] = poly.read_const @CHOOSE : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_209]][@a] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_209]][@b] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_209]][@out] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_209]][@children] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !array.type<2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_215:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_209]][@children$inputs] : <@LoopBranch::@LoopBranch<[@CHOOSE]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_211]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_217]], %[[VAL_216]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_218:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_219:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_212]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_219]], %[[VAL_218]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_220:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_221:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_210]], %[[VAL_220]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_221]] {
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_222:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_223:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_224:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_222]], %[[VAL_223]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_225:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_226:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_210]], %[[VAL_225]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_226]] {
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_227:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_228:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_227]], %[[VAL_228]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_230]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_215]]{{\[}}%[[VAL_231]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_232]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_233]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_211]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_234]], %[[VAL_235]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_236:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_237:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_236]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_238:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_215]]{{\[}}%[[VAL_237]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_239:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_238]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_240:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_239]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_241:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_212]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_240]], %[[VAL_241]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_242:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_243:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_242]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_244:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_214]]{{\[}}%[[VAL_243]]] : <2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_245:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_244]][@out] : <@Expand::@Expand<[#[[$ATTR_0]]]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_246:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_245]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_247:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_248:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_247]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_249:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_246]]{{\[}}%[[VAL_248]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_250:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_251:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_250]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_252:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_214]]{{\[}}%[[VAL_251]]] : <2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_253:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_252]][@out] : <@Expand::@Expand<[#[[$ATTR_0]]]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_254:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_253]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_255:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_256:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_257:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_254]]{{\[}}%[[VAL_256]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_258:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_249]], %[[VAL_257]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_213]], %[[VAL_258]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_259:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_260:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_261:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_262:[0-9a-zA-Z_.-]+]] = %[[VAL_260]] to %[[VAL_259]] step %[[VAL_261]] {
// TEMPLATED-NEXT:            %[[VAL_263:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_214]]{{\[}}%[[VAL_262]]] : <2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>, !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_264:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_215]]{{\[}}%[[VAL_262]]] : <2 x !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_265:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_264]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            function.call @Expand::@Expand::@constrain(%[[VAL_263]], %[[VAL_265]]) : (!struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @fromElse : !struct.type<@Branch::@Branch<[0]>>
// TEMPLATED-NEXT:        struct.member @fromElse$inputs : !pod.type<[]>
// TEMPLATED-NEXT:        struct.member @fromThen : !struct.type<@Branch::@Branch<[1]>>
// TEMPLATED-NEXT:        struct.member @fromThen$inputs : !pod.type<[]>
// TEMPLATED-NEXT:        struct.member @loopElse : !struct.type<@LoopBranch::@LoopBranch<[0]>>
// TEMPLATED-NEXT:        struct.member @loopElse$inputs : !pod.type<[]>
// TEMPLATED-NEXT:        struct.member @loopThen : !struct.type<@LoopBranch::@LoopBranch<[1]>>
// TEMPLATED-NEXT:        struct.member @loopThen$inputs : !pod.type<[]>
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_266:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[]>>
// TEMPLATED-NEXT:          %[[VAL_267:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// TEMPLATED-NEXT:          %[[VAL_268:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// TEMPLATED-NEXT:          %[[VAL_269:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// TEMPLATED-NEXT:          %[[VAL_270:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// TEMPLATED-NEXT:          %[[VAL_271:[0-9a-zA-Z_.-]+]] = function.call @Branch::@Branch::@compute() : () -> !struct.type<@Branch::@Branch<[1]>>
// TEMPLATED-NEXT:          %[[VAL_272:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %[[VAL_271]] }  : <[@count: index, @comp: !struct.type<@Branch::@Branch<[1]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_273:[0-9a-zA-Z_.-]+]] = function.call @Branch::@Branch::@compute() : () -> !struct.type<@Branch::@Branch<[0]>>
// TEMPLATED-NEXT:          %[[VAL_274:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %[[VAL_273]] }  : <[@count: index, @comp: !struct.type<@Branch::@Branch<[0]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_275:[0-9a-zA-Z_.-]+]] = function.call @LoopBranch::@LoopBranch::@compute() : () -> !struct.type<@LoopBranch::@LoopBranch<[1]>>
// TEMPLATED-NEXT:          %[[VAL_276:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %[[VAL_275]] }  : <[@count: index, @comp: !struct.type<@LoopBranch::@LoopBranch<[1]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_277:[0-9a-zA-Z_.-]+]] = function.call @LoopBranch::@LoopBranch::@compute() : () -> !struct.type<@LoopBranch::@LoopBranch<[0]>>
// TEMPLATED-NEXT:          %[[VAL_278:[0-9a-zA-Z_.-]+]] = pod.new { @comp = %[[VAL_277]] }  : <[@count: index, @comp: !struct.type<@LoopBranch::@LoopBranch<[0]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_279:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_272]][@comp] : <[@count: index, @comp: !struct.type<@Branch::@Branch<[1]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>, !struct.type<@Branch::@Branch<[1]>>
// TEMPLATED-NEXT:          %[[VAL_280:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_279]][@out] : <@Branch::@Branch<[1]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_281:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_274]][@comp] : <[@count: index, @comp: !struct.type<@Branch::@Branch<[0]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>, !struct.type<@Branch::@Branch<[0]>>
// TEMPLATED-NEXT:          %[[VAL_282:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_281]][@out] : <@Branch::@Branch<[0]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_283:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_280]], %[[VAL_282]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_284:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_276]][@comp] : <[@count: index, @comp: !struct.type<@LoopBranch::@LoopBranch<[1]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>, !struct.type<@LoopBranch::@LoopBranch<[1]>>
// TEMPLATED-NEXT:          %[[VAL_285:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_284]][@out] : <@LoopBranch::@LoopBranch<[1]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_286:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_283]], %[[VAL_285]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_287:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_278]][@comp] : <[@count: index, @comp: !struct.type<@LoopBranch::@LoopBranch<[0]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>, !struct.type<@LoopBranch::@LoopBranch<[0]>>
// TEMPLATED-NEXT:          %[[VAL_288:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_287]][@out] : <@LoopBranch::@LoopBranch<[0]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_289:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_286]], %[[VAL_288]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@out] = %[[VAL_289]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@fromElse$inputs] = %[[VAL_267]] : <@Main::@Main<[]>>, !pod.type<[]>
// TEMPLATED-NEXT:          %[[VAL_290:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_274]][@comp] : <[@count: index, @comp: !struct.type<@Branch::@Branch<[0]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>, !struct.type<@Branch::@Branch<[0]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@fromElse] = %[[VAL_290]] : <@Main::@Main<[]>>, !struct.type<@Branch::@Branch<[0]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@fromThen$inputs] = %[[VAL_268]] : <@Main::@Main<[]>>, !pod.type<[]>
// TEMPLATED-NEXT:          %[[VAL_291:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_272]][@comp] : <[@count: index, @comp: !struct.type<@Branch::@Branch<[1]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>, !struct.type<@Branch::@Branch<[1]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@fromThen] = %[[VAL_291]] : <@Main::@Main<[]>>, !struct.type<@Branch::@Branch<[1]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@loopElse$inputs] = %[[VAL_269]] : <@Main::@Main<[]>>, !pod.type<[]>
// TEMPLATED-NEXT:          %[[VAL_292:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_278]][@comp] : <[@count: index, @comp: !struct.type<@LoopBranch::@LoopBranch<[0]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>, !struct.type<@LoopBranch::@LoopBranch<[0]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@loopElse] = %[[VAL_292]] : <@Main::@Main<[]>>, !struct.type<@LoopBranch::@LoopBranch<[0]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@loopThen$inputs] = %[[VAL_270]] : <@Main::@Main<[]>>, !pod.type<[]>
// TEMPLATED-NEXT:          %[[VAL_293:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_276]][@comp] : <[@count: index, @comp: !struct.type<@LoopBranch::@LoopBranch<[1]>>, @params: !pod.type<[@CHOOSE: !felt.type<"bn128">]>]>, !struct.type<@LoopBranch::@LoopBranch<[1]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_266]][@loopThen] = %[[VAL_293]] : <@Main::@Main<[]>>, !struct.type<@LoopBranch::@LoopBranch<[1]>>
// TEMPLATED-NEXT:          function.return %[[VAL_266]] : !struct.type<@Main::@Main<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_294:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_295:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@out] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_296:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@fromElse] : <@Main::@Main<[]>>, !struct.type<@Branch::@Branch<[0]>>
// TEMPLATED-NEXT:          %[[VAL_297:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@fromElse$inputs] : <@Main::@Main<[]>>, !pod.type<[]>
// TEMPLATED-NEXT:          %[[VAL_298:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@fromThen] : <@Main::@Main<[]>>, !struct.type<@Branch::@Branch<[1]>>
// TEMPLATED-NEXT:          %[[VAL_299:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@fromThen$inputs] : <@Main::@Main<[]>>, !pod.type<[]>
// TEMPLATED-NEXT:          %[[VAL_300:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@loopElse] : <@Main::@Main<[]>>, !struct.type<@LoopBranch::@LoopBranch<[0]>>
// TEMPLATED-NEXT:          %[[VAL_301:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@loopElse$inputs] : <@Main::@Main<[]>>, !pod.type<[]>
// TEMPLATED-NEXT:          %[[VAL_302:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@loopThen] : <@Main::@Main<[]>>, !struct.type<@LoopBranch::@LoopBranch<[1]>>
// TEMPLATED-NEXT:          %[[VAL_303:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_294]][@loopThen$inputs] : <@Main::@Main<[]>>, !pod.type<[]>
// TEMPLATED-NEXT:          %[[VAL_304:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_298]][@out] : <@Branch::@Branch<[1]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_305:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_296]][@out] : <@Branch::@Branch<[0]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_306:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_304]], %[[VAL_305]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_307:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_302]][@out] : <@LoopBranch::@LoopBranch<[1]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_308:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_306]], %[[VAL_307]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_309:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_300]][@out] : <@LoopBranch::@LoopBranch<[0]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_310:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_308]], %[[VAL_309]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_295]], %[[VAL_310]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.call @Branch::@Branch::@constrain(%[[VAL_296]]) : (!struct.type<@Branch::@Branch<[0]>>) -> ()
// TEMPLATED-NEXT:          function.call @Branch::@Branch::@constrain(%[[VAL_298]]) : (!struct.type<@Branch::@Branch<[1]>>) -> ()
// TEMPLATED-NEXT:          function.call @LoopBranch::@LoopBranch::@constrain(%[[VAL_300]]) : (!struct.type<@LoopBranch::@LoopBranch<[0]>>) -> ()
// TEMPLATED-NEXT:          function.call @LoopBranch::@LoopBranch::@constrain(%[[VAL_302]]) : (!struct.type<@LoopBranch::@LoopBranch<[1]>>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
