// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The unused x tag has no value. It must not hide a derived output tag that
// depends only on xy, even while xy is a symbolic input tag in the caller.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Derive() {
    signal input {x, xy} in;
    signal output {size} out;
    out.size = in.xy > 0 ? in.xy + 1 : 1;
    out <== in;
}

template Expand() {
    signal input {size} in;
    Vec(in.size) output out;
    for (var i = 0; i < in.size; i++) { out.x[i] <== in; }
}

template Forward() {
    signal input {xy} in;
    signal {x, xy} tagged;
    tagged.xy = in.xy;
    tagged <== in;

    component derived = Derive();
    derived.in <== tagged;
    component expanded = Expand();
    expanded.in <== derived.out;

    Vec(derived.out.size) output out;
    for (var i = 0; i < derived.out.size; i++) {
        out.x[i] <== expanded.out.x[i];
    }
}

template Main() {
    signal {xy} source;
    source.xy = 2;
    source <== 5;
    component forwarded = Forward();
    forwarded.in <== source;
    signal output out;
    out <== forwarded.out.x[2];
}

component main = Main();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_3::@Main_3<[]>>} {
// CONCRETE-NEXT:    poly.template @Derive_0 {
// CONCRETE-NEXT:      struct.def @Derive_0 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Derive_0::@Derive_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@Derive_0::@Derive_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_.-]+]]: !struct.type<@Derive_0::@Derive_0<[]>>, %[[VAL_3:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_2]][@out] : <@Derive_0::@Derive_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Expand_1 {
// CONCRETE-NEXT:      struct.def @Expand_1 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_5:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Expand_1::@Expand_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_10:[0-9a-zA-Z_.-]+]] = %[[VAL_8]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_11:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_12:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_10]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_12]]) %[[VAL_10]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_13:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_14:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_7]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_15:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_16:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_15]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_14]]{{\[}}%[[VAL_15]]] = %[[VAL_5]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_7]][@x] = %[[VAL_14]] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_17:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_18:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_13]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_18]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_6]][@out] = %[[VAL_7]] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_6]] : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand_1::@Expand_1<[]>>, %[[VAL_20:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_19]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_.-]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_24]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_28:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_21]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_29]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_30]], %[[VAL_20]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_31:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_32:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_27]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Forward_2 {
// CONCRETE-NEXT:      struct.def @Forward_2 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @tagged : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @derived : !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:        struct.member @derived$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @expanded : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:        struct.member @expanded$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_33:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Forward_2::@Forward_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = struct.new : <@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_37]], @params = %[[VAL_36]] }  : <[@count: index, @comp: !struct.type<@Derive_0::@Derive_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_41]], @params = %[[VAL_40]] }  : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_34]][@tagged] = %[[VAL_33]] : <@Forward_2::@Forward_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_39]][@in] = %[[VAL_33]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_38]][@count] : <[@count: index, @comp: !struct.type<@Derive_0::@Derive_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_44]], %[[VAL_45]] : index
// CONCRETE-NEXT:          pod.write %[[VAL_38]][@count] = %[[VAL_46]] : <[@count: index, @comp: !struct.type<@Derive_0::@Derive_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_46]], %[[VAL_47]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_48]] {
// CONCRETE-NEXT:            %[[VAL_49:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_38]][@params] : <[@count: index, @comp: !struct.type<@Derive_0::@Derive_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:            %[[VAL_50:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_39]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_51:[0-9a-zA-Z_.-]+]] = function.call @Derive_0::@Derive_0::@compute(%[[VAL_50]]) : (!felt.type<"bn128">) -> !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:            pod.write %[[VAL_38]][@comp] = %[[VAL_51]] : <[@count: index, @comp: !struct.type<@Derive_0::@Derive_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_38]][@comp] : <[@count: index, @comp: !struct.type<@Derive_0::@Derive_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_52]][@out] : <@Derive_0::@Derive_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_43]][@in] = %[[VAL_53]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_42]][@count] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_54]], %[[VAL_55]] : index
// CONCRETE-NEXT:          pod.write %[[VAL_42]][@count] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_58]] {
// CONCRETE-NEXT:            %[[VAL_59:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_42]][@params] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:            %[[VAL_60:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_43]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_61:[0-9a-zA-Z_.-]+]] = function.call @Expand_1::@Expand_1::@compute(%[[VAL_60]]) : (!felt.type<"bn128">) -> !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:            pod.write %[[VAL_42]][@comp] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_64:[0-9a-zA-Z_.-]+]] = %[[VAL_62]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_65:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_66:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_64]], %[[VAL_65]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_66]]) %[[VAL_64]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_67:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_68:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_42]][@comp] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:            %[[VAL_69:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_68]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_70:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_71:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_72:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_71]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_73:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_35]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_74:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_75:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_74]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_73]]{{\[}}%[[VAL_74]]] = %[[VAL_72]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_35]][@x] = %[[VAL_73]] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_76:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_77:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_67]], %[[VAL_76]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_77]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_34]][@derived$inputs] = %[[VAL_39]] : <@Forward_2::@Forward_2<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_38]][@comp] : <[@count: index, @comp: !struct.type<@Derive_0::@Derive_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_34]][@derived] = %[[VAL_78]] : <@Forward_2::@Forward_2<[]>>, !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_34]][@expanded$inputs] = %[[VAL_43]] : <@Forward_2::@Forward_2<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_42]][@comp] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_34]][@expanded] = %[[VAL_79]] : <@Forward_2::@Forward_2<[]>>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_34]][@out] = %[[VAL_35]] : <@Forward_2::@Forward_2<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_34]] : !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_80:[0-9a-zA-Z_.-]+]]: !struct.type<@Forward_2::@Forward_2<[]>>, %[[VAL_81:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_80]][@out] : <@Forward_2::@Forward_2<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_80]][@tagged] : <@Forward_2::@Forward_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_80]][@derived] : <@Forward_2::@Forward_2<[]>>, !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_80]][@derived$inputs] : <@Forward_2::@Forward_2<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_80]][@expanded] : <@Forward_2::@Forward_2<[]>>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_80]][@expanded$inputs] : <@Forward_2::@Forward_2<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          constrain.eq %[[VAL_83]], %[[VAL_81]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_85]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_88]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_84]][@out] : <@Derive_0::@Derive_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_87]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_90]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_93:[0-9a-zA-Z_.-]+]] = %[[VAL_91]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_94:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_95:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_93]], %[[VAL_94]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_95]]) %[[VAL_93]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_96:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_97:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_86]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_98:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_97]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_99:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_100:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_98]]{{\[}}%[[VAL_99]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_101:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_82]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_101]]{{\[}}%[[VAL_102]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_103]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_105:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_96]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_105]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_85]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.call @Derive_0::@Derive_0::@constrain(%[[VAL_84]], %[[VAL_106]]) : (!struct.type<@Derive_0::@Derive_0<[]>>, !felt.type<"bn128">) -> ()
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_87]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.call @Expand_1::@Expand_1::@constrain(%[[VAL_86]], %[[VAL_107]]) : (!struct.type<@Expand_1::@Expand_1<[]>>, !felt.type<"bn128">) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Main_3 {
// CONCRETE-NEXT:      struct.def @Main_3 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @source : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @forwarded : !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:        struct.member @forwarded$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Main_3::@Main_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_3::@Main_3<[]>>
// CONCRETE-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_110]], @params = %[[VAL_109]] }  : <[@count: index, @comp: !struct.type<@Forward_2::@Forward_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_108]][@source] = %[[VAL_113]] : <@Main_3::@Main_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_112]][@in] = %[[VAL_113]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@count] : <[@count: index, @comp: !struct.type<@Forward_2::@Forward_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_115:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_116:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_114]], %[[VAL_115]] : index
// CONCRETE-NEXT:          pod.write %[[VAL_111]][@count] = %[[VAL_116]] : <[@count: index, @comp: !struct.type<@Forward_2::@Forward_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_118:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_116]], %[[VAL_117]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_118]] {
// CONCRETE-NEXT:            %[[VAL_119:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@params] : <[@count: index, @comp: !struct.type<@Forward_2::@Forward_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:            %[[VAL_120:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_112]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_121:[0-9a-zA-Z_.-]+]] = function.call @Forward_2::@Forward_2::@compute(%[[VAL_120]]) : (!felt.type<"bn128">) -> !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:            pod.write %[[VAL_111]][@comp] = %[[VAL_121]] : <[@count: index, @comp: !struct.type<@Forward_2::@Forward_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_122:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@comp] : <[@count: index, @comp: !struct.type<@Forward_2::@Forward_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:          %[[VAL_123:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_122]][@out] : <@Forward_2::@Forward_2<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_124:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_123]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_126]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_108]][@out] = %[[VAL_127]] : <@Main_3::@Main_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_108]][@forwarded$inputs] = %[[VAL_112]] : <@Main_3::@Main_3<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_111]][@comp] : <[@count: index, @comp: !struct.type<@Forward_2::@Forward_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_108]][@forwarded] = %[[VAL_128]] : <@Main_3::@Main_3<[]>>, !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_108]] : !struct.type<@Main_3::@Main_3<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_129:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_3::@Main_3<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_129]][@out] : <@Main_3::@Main_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_129]][@source] : <@Main_3::@Main_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_129]][@forwarded] : <@Main_3::@Main_3<[]>>, !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_129]][@forwarded$inputs] : <@Main_3::@Main_3<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_134:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_131]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_133]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_135]], %[[VAL_131]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_136:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_132]][@out] : <@Forward_2::@Forward_2<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_136]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_140:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_139]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_130]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_133]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.call @Forward_2::@Forward_2::@constrain(%[[VAL_132]], %[[VAL_141]]) : (!struct.type<@Forward_2::@Forward_2<[]>>, !felt.type<"bn128">) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// TEMPLATED-NEXT:    poly.template @Derive {
// TEMPLATED-NEXT:      poly.param @"$tag$in$x"
// TEMPLATED-NEXT:      poly.param @"$tag$in$xy"
// TEMPLATED-NEXT:      struct.def @Derive {
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Derive::@Derive<[@"$tag$in$x", @"$tag$in$xy"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Derive::@Derive<[@"$tag$in$x", @"$tag$in$xy"]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy" : !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@Derive::@Derive<[@"$tag$in$x", @"$tag$in$xy"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@Derive::@Derive<[@"$tag$in$x", @"$tag$in$xy"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_.-]+]]: !struct.type<@Derive::@Derive<[@"$tag$in$x", @"$tag$in$xy"]>>, %[[VAL_5:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_4]][@out] : <@Derive::@Derive<[@"$tag$in$x", @"$tag$in$xy"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_8]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Expand {
// TEMPLATED-NEXT:      poly.param @"$tag$in$size" : index
// TEMPLATED-NEXT:      struct.def @Expand {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Expand::@Expand<[@"$tag$in$size"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand::@Expand<[@"$tag$in$size"]>>
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$size" : index
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_11]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_16:[0-9a-zA-Z_.-]+]] = %[[VAL_14]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_17:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_17]]) %[[VAL_16]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_18:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_19:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_13]][@x] : <[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_20:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_21:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_20]]] : <@"$tag$in$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_20]]] = %[[VAL_9]] : <@"$tag$in$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_13]][@x] = %[[VAL_19]] : <[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_18]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_23]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_10]][@out] = %[[VAL_13]] : <@Expand::@Expand<[@"$tag$in$size"]>>, !pod.type<[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_10]] : !struct.type<@Expand::@Expand<[@"$tag$in$size"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_24:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand::@Expand<[@"$tag$in$size"]>>, %[[VAL_25:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$size" : index
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_26]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_24]][@out] : <@Expand::@Expand<[@"$tag$in$size"]>>, !pod.type<[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_31:[0-9a-zA-Z_.-]+]] = %[[VAL_29]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_32:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_31]], %[[VAL_27]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_32]]) %[[VAL_31]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_33:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_34:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_28]][@x] : <[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_35:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_36:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_35]]] : <@"$tag$in$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_36]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_37:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_38:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_33]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_38]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Forward {
// TEMPLATED-NEXT:      poly.param @"$tag$in$xy"
// TEMPLATED-NEXT:      poly.param @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" : index
// TEMPLATED-NEXT:      poly.expr @"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET:[0-9]+]]" {
// TEMPLATED-NEXT:        %[[VAL_39:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:        %[[VAL_40:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:        %[[VAL_41:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" : index
// TEMPLATED-NEXT:        %[[VAL_42:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_41]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_43:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy" : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_44:[0-9a-zA-Z_.-]+]] = bool.cmp gt(%[[VAL_43]], %[[VAL_39]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_45:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_44]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_43]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.yield %[[VAL_46]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        } else {
// TEMPLATED-NEXT:          scf.yield %[[VAL_40]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        poly.yield %[[VAL_45]] : !felt.type<"bn128">
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @Forward {
// TEMPLATED-NEXT:        struct.member @tagged : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@x: !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @derived : !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED-NEXT:        struct.member @derived$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @expanded : !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED-NEXT:        struct.member @expanded$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_47:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = struct.new : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" : index
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_49]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_48]][@tagged] = %[[VAL_47]] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x" = %[[VAL_56]], @"$tag$in$xy" = %[[VAL_57]] }  : <[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_59]], @params = %[[VAL_58]] }  : <[@count: index, @comp: !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>, @params: !pod.type<[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_54]][@in] = %[[VAL_47]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@count] : <[@count: index, @comp: !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>, @params: !pod.type<[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_61]], %[[VAL_62]] : index
// TEMPLATED-NEXT:          pod.write %[[VAL_60]][@count] = %[[VAL_63]] : <[@count: index, @comp: !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>, @params: !pod.type<[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_63]], %[[VAL_64]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_65]] {
// TEMPLATED-NEXT:            %[[VAL_66:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@params] : <[@count: index, @comp: !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>, @params: !pod.type<[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_67:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_54]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_68:[0-9a-zA-Z_.-]+]] = function.call @Derive::@Derive::@compute(%[[VAL_67]]) : (!felt.type<"bn128">) -> !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED-NEXT:            pod.write %[[VAL_60]][@comp] = %[[VAL_68]] : <[@count: index, @comp: !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>, @params: !pod.type<[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>]>, !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$size" = %[[VAL_69]] }  : <[@"$tag$in$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_71]], @params = %[[VAL_70]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, @params: !pod.type<[@"$tag$in$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@comp] : <[@count: index, @comp: !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>, @params: !pod.type<[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>]>, !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_73]][@out] : <@Derive::@Derive<[0, @"$tag$in$xy"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_55]][@in] = %[[VAL_74]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_72]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, @params: !pod.type<[@"$tag$in$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_75]], %[[VAL_76]] : index
// TEMPLATED-NEXT:          pod.write %[[VAL_72]][@count] = %[[VAL_77]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, @params: !pod.type<[@"$tag$in$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_77]], %[[VAL_78]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_79]] {
// TEMPLATED-NEXT:            %[[VAL_80:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_72]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, @params: !pod.type<[@"$tag$in$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_81:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_55]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_82:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_81]]) : (!felt.type<"bn128">) -> !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED-NEXT:            pod.write %[[VAL_72]][@comp] = %[[VAL_82]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, @params: !pod.type<[@"$tag$in$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_85:[0-9a-zA-Z_.-]+]] = %[[VAL_83]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_86:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_.-]+]] = bool.cmp gt(%[[VAL_51]], %[[VAL_86]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_87]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:              %[[VAL_89:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_90:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_51]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_90]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_91:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_91]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_92:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_85]], %[[VAL_88]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_92]]) %[[VAL_85]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_93:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_94:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_72]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, @params: !pod.type<[@"$tag$in$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED-NEXT:            %[[VAL_95:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_94]][@out] : <@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_96:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_95]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_97:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_98:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_97]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_99:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_53]][@x] : <[@x: !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>]>, !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_100:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_101:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_100]]] : <@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_99]]{{\[}}%[[VAL_100]]] = %[[VAL_98]] : <@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_53]][@x] = %[[VAL_99]] : <[@x: !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>]>, !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_102:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_103:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_93]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_48]][@derived$inputs] = %[[VAL_54]] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_60]][@comp] : <[@count: index, @comp: !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>, @params: !pod.type<[@"$tag$in$x": !felt.type<"bn128">, @"$tag$in$xy": !felt.type<"bn128">]>]>, !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_48]][@derived] = %[[VAL_104]] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_48]][@expanded$inputs] = %[[VAL_55]] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_72]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, @params: !pod.type<[@"$tag$in$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_48]][@expanded] = %[[VAL_105]] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_48]][@out] = %[[VAL_53]] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !pod.type<[@x: !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_48]] : !struct.type<@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_106:[0-9a-zA-Z_.-]+]]: !struct.type<@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, %[[VAL_107:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" : index
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_108]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_106]][@tagged] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_106]][@out] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !pod.type<[@x: !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_106]][@derived] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_106]][@derived$inputs] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_106]][@expanded] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED-NEXT:          %[[VAL_117:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_106]][@expanded$inputs] : <@Forward::@Forward<[@"$tag$in$xy", @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)"]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_112]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_115]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_119]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_114]][@out] : <@Derive::@Derive<[0, @"$tag$in$xy"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_117]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_122]], %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_125:[0-9a-zA-Z_.-]+]] = %[[VAL_123]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_126:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_127:[0-9a-zA-Z_.-]+]] = bool.cmp gt(%[[VAL_110]], %[[VAL_126]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_128:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_127]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:              %[[VAL_129:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_130:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_110]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_130]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_131:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_131]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_132:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_125]], %[[VAL_128]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_132]]) %[[VAL_125]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_133:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_134:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_116]][@out] : <@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_135:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_134]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_136:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_137:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_135]]{{\[}}%[[VAL_136]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_138:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_113]][@x] : <[@x: !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>]>, !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_139:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_140:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_139]]] : <@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_140]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_141:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_142:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_133]], %[[VAL_141]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_142]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_115]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.call @Derive::@Derive::@constrain(%[[VAL_114]], %[[VAL_143]]) : (!struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>, !felt.type<"bn128">) -> ()
// TEMPLATED-NEXT:          %[[VAL_144:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_117]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.call @Expand::@Expand::@constrain(%[[VAL_116]], %[[VAL_144]]) : (!struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>, !felt.type<"bn128">) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @source : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @forwarded : !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED-NEXT:        struct.member @forwarded$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_145:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[]>>
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_145]][@source] = %[[VAL_147]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$xy" = %[[VAL_148]], @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" = %[[VAL_149]] }  : <[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_151]], @params = %[[VAL_150]] }  : <[@count: index, @comp: !struct.type<@Forward::@Forward<[2, 3]>>, @params: !pod.type<[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_146]][@in] = %[[VAL_147]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_152]][@count] : <[@count: index, @comp: !struct.type<@Forward::@Forward<[2, 3]>>, @params: !pod.type<[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_153]], %[[VAL_154]] : index
// TEMPLATED-NEXT:          pod.write %[[VAL_152]][@count] = %[[VAL_155]] : <[@count: index, @comp: !struct.type<@Forward::@Forward<[2, 3]>>, @params: !pod.type<[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_155]], %[[VAL_156]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_157]] {
// TEMPLATED-NEXT:            %[[VAL_158:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_152]][@params] : <[@count: index, @comp: !struct.type<@Forward::@Forward<[2, 3]>>, @params: !pod.type<[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_159:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_146]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_160:[0-9a-zA-Z_.-]+]] = function.call @Forward::@Forward::@compute(%[[VAL_159]]) : (!felt.type<"bn128">) -> !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED-NEXT:            pod.write %[[VAL_152]][@comp] = %[[VAL_160]] : <[@count: index, @comp: !struct.type<@Forward::@Forward<[2, 3]>>, @params: !pod.type<[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>]>, !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_152]][@comp] : <[@count: index, @comp: !struct.type<@Forward::@Forward<[2, 3]>>, @params: !pod.type<[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>]>, !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_161]][@out] : <@Forward::@Forward<[2, 3]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_162]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_163]]{{\[}}%[[VAL_165]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_145]][@out] = %[[VAL_166]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_145]][@forwarded$inputs] = %[[VAL_146]] : <@Main::@Main<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_152]][@comp] : <[@count: index, @comp: !struct.type<@Forward::@Forward<[2, 3]>>, @params: !pod.type<[@"$tag$in$xy": !felt.type<"bn128">, @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)": !felt.type<"bn128">]>]>, !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_145]][@forwarded] = %[[VAL_167]] : <@Main::@Main<[]>>, !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED-NEXT:          function.return %[[VAL_145]] : !struct.type<@Main::@Main<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_168:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_169:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_168]][@source] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_168]][@out] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_168]][@forwarded] : <@Main::@Main<[]>>, !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_168]][@forwarded$inputs] : <@Main::@Main<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_173:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_169]], %[[VAL_173]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_174:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_172]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_174]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_175:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_171]][@out] : <@Forward::@Forward<[2, 3]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_176:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_175]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_177:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_178:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_177]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_179:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_176]]{{\[}}%[[VAL_178]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_170]], %[[VAL_179]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_180:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_172]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.call @Forward::@Forward::@constrain(%[[VAL_171]], %[[VAL_180]]) : (!struct.type<@Forward::@Forward<[2, 3]>>, !felt.type<"bn128">) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
