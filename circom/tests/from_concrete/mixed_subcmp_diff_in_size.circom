// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Montgomery2Edwards() {
    signal input in[2];
    signal output out[2];
}

template SegmentMulFix(nWindows) {
    signal input e[nWindows*3];
    signal input base[2];
    signal output dbl[2];
}

template EscalarMulFix(n, BASE) {
    signal input emfIn[n];

    var nsegments = (n-1)\246 +1;               // 2
    var nlastsegment = n - (nsegments-1)*249;   // 4

    component segments[nsegments];
    component m2e[nsegments-1];

    for (var s=0; s<nsegments; s++) {
        var nseg = (s < nsegments-1) ? 249 : nlastsegment;
        var nWindows = ((nseg - 1)\3)+1;

        segments[s] = SegmentMulFix(nWindows);

        for (var i=0; i<nseg; i++) {
            segments[s].e[i] <== emfIn[s*249+i];
        }

        for (var i = nseg; i<nWindows*3; i++) {
            segments[s].e[i] <== 0;
        }

        if (s==0) {
            segments[s].base[0] <== BASE[0];
            segments[s].base[1] <== BASE[1];
        } else {
            m2e[s-1] = Montgomery2Edwards();

            segments[s-1].dbl[0] ==> m2e[s-1].in[0];
            segments[s-1].dbl[1] ==> m2e[s-1].in[1];

            m2e[s-1].out[0] ==> segments[s].base[0];
            m2e[s-1].out[1] ==> segments[s].base[1];
        }
    }
}

template BabyPbk() {
    signal input in;

    var BASE8[2] = [
        5299619240641551281634865583518297030282874472190772894086521144482721001553,
        16950150798460657717958625567821834550301663161624707787222815936182638968203
    ];

    component mulFix = EscalarMulFix(253, BASE8);
    for (var i=0; i<253; i++) {
        mulFix.emfIn[i] <== in;
    }
}

component main = BabyPbk();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>} {
// CHECK-NEXT:    poly.template @BabyPbk_4 {
// CHECK-NEXT:      struct.def @BabyPbk_4 {
// CHECK-NEXT:        struct.member @mulFix : !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:        struct.member @mulFix$inputs : !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@BabyPbk_4::@BabyPbk_4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BabyPbk_4::@BabyPbk_4<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 253 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_6]]{{\[}}%[[VAL_9]]] = %[[VAL_7]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_6]]{{\[}}%[[VAL_12]]] = %[[VAL_10]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_6]]{{\[}}%[[VAL_15]]] = %[[VAL_13]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_6]]{{\[}}%[[VAL_18]]] = %[[VAL_16]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_19]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_21]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_21]], %[[VAL_22]], %[[VAL_23]] : !felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_29]]{{\[}}%[[VAL_30]]] = %[[VAL_0]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_28]][@emfIn] = %[[VAL_29]] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@count] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_31]], %[[VAL_32]] : index
// CHECK-NEXT:            pod.write %[[VAL_27]][@count] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:            scf.if %[[VAL_35]] {
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@params] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = function.call @EscalarMulFix_3::@EscalarMulFix_3::@compute(%[[VAL_37]]) : (!array.type<253 x !felt.type<"bn128">>) -> !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:              pod.write %[[VAL_27]][@comp] = %[[VAL_38]] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_40]], %[[VAL_27]], %[[VAL_28]] : !felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@mulFix$inputs] = %[[VAL_20]]#2 : <@BabyPbk_4::@BabyPbk_4<[]>>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]]#1[@comp] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@mulFix] = %[[VAL_41]] : <@BabyPbk_4::@BabyPbk_4<[]>>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_42:[0-9a-zA-Z_\.]+]]: !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_42]][@mulFix] : <@BabyPbk_4::@BabyPbk_4<[]>>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_42]][@mulFix$inputs] : <@BabyPbk_4::@BabyPbk_4<[]>>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_46]]{{\[}}%[[VAL_49]]] = %[[VAL_47]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_46]]{{\[}}%[[VAL_52]]] = %[[VAL_50]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_46]]{{\[}}%[[VAL_55]]] = %[[VAL_53]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_46]]{{\[}}%[[VAL_58]]] = %[[VAL_56]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_59]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_61]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_63]]) %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_65]]{{\[}}%[[VAL_66]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_67]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_64]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @EscalarMulFix_3::@EscalarMulFix_3::@constrain(%[[VAL_44]], %[[VAL_70]]) : (!struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<253 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EscalarMulFix_3 {
// CHECK-NEXT:      struct.def @EscalarMulFix_3 {
// CHECK-NEXT:        struct.member @m2e : !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:        struct.member @m2e$inputs : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        struct.member @segments : !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:        struct.member @segments$inputs : !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !array.type<253 x !felt.type<"bn128">> {function.arg_name = "emfIn"}) -> !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.new : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_76]] to %[[VAL_75]] step %[[VAL_77]] {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_79]], @params = %[[VAL_74]] }  : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_73]]{{\[}}%[[VAL_78]]] = %[[VAL_80]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 251 : index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_83]], @params = %[[VAL_82]] }  : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_85]], @params = %[[VAL_82]] }  : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_84]], @idx_1 = %[[VAL_86]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = global.read @vcp_array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]]:5 = scf.while (%[[VAL_95:[0-9a-zA-Z_\.]+]] = %[[VAL_73]], %[[VAL_96:[0-9a-zA-Z_\.]+]] = %[[VAL_81]], %[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_93]], %[[VAL_98:[0-9a-zA-Z_\.]+]] = %[[VAL_87]], %[[VAL_99:[0-9a-zA-Z_\.]+]] = %[[VAL_88]]) : (!array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_97]], %[[VAL_100]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_101]]) %[[VAL_95]], %[[VAL_96]], %[[VAL_97]], %[[VAL_98]], %[[VAL_99]] : !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_102:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, %[[VAL_103:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_104:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_105:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_106:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_104]], %[[VAL_107]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_108]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_111]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_109]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_113]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_115]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_120:[0-9a-zA-Z_\.]+]] = %[[VAL_118]], %[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_105]], %[[VAL_122:[0-9a-zA-Z_\.]+]] = %[[VAL_106]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_120]], %[[VAL_109]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_123]]) %[[VAL_120]], %[[VAL_121]], %[[VAL_122]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_124:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_125:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_126:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_104]], %[[VAL_127]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_128]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_130]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_132:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_132]], %[[VAL_134]] : index
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_133]], %[[VAL_135]] : i1, i1
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_132]], %[[VAL_137]] : index
// CHECK-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_133]], %[[VAL_138]] : i1, i1
// CHECK-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_141:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_139]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_144]]{{\[}}%[[VAL_145]]] = %[[VAL_131]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  pod.write %[[VAL_143]][@e] = %[[VAL_144]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_126]][@idx_1] = %[[VAL_143]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_146]], %[[VAL_147]] : index
// CHECK-NEXT:                  pod.write %[[VAL_142]][@count] = %[[VAL_148]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_148]], %[[VAL_149]] : index
// CHECK-NEXT:                  scf.if %[[VAL_150]] {
// CHECK-NEXT:                    %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_154:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_152]], %[[VAL_153]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_142]][@comp] = %[[VAL_154]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_125]][@idx_1] = %[[VAL_142]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_125]], %[[VAL_126]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_155:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_136]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_158]]{{\[}}%[[VAL_159]]] = %[[VAL_131]] : <249 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    pod.write %[[VAL_157]][@e] = %[[VAL_158]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_126]][@idx_0] = %[[VAL_157]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_160]], %[[VAL_161]] : index
// CHECK-NEXT:                    pod.write %[[VAL_156]][@count] = %[[VAL_162]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_162]], %[[VAL_163]] : index
// CHECK-NEXT:                    scf.if %[[VAL_164]] {
// CHECK-NEXT:                      %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_168:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_166]], %[[VAL_167]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_156]][@comp] = %[[VAL_168]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_125]][@idx_0] = %[[VAL_156]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_125]], %[[VAL_126]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_169:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_170:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_169]], %[[VAL_170]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_155]]#0, %[[VAL_155]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_141]]#0, %[[VAL_141]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_124]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_172]], %[[VAL_140]]#0, %[[VAL_140]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_174:[0-9a-zA-Z_\.]+]] = %[[VAL_109]], %[[VAL_175:[0-9a-zA-Z_\.]+]] = %[[VAL_119]]#1, %[[VAL_176:[0-9a-zA-Z_\.]+]] = %[[VAL_119]]#2) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_117]], %[[VAL_177]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_179:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_174]], %[[VAL_178]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_179]]) %[[VAL_174]], %[[VAL_175]], %[[VAL_176]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_180:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_181:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_182:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:              %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_180]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_185]]{{\[}}%[[VAL_186]]] = %[[VAL_183]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_187]][@e] = %[[VAL_185]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_182]][@idx_1] = %[[VAL_187]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_188]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_190]], %[[VAL_191]] : index
// CHECK-NEXT:              pod.write %[[VAL_188]][@count] = %[[VAL_192]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_192]], %[[VAL_193]] : index
// CHECK-NEXT:              scf.if %[[VAL_194]] {
// CHECK-NEXT:                %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_188]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_198:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_196]], %[[VAL_197]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_188]][@comp] = %[[VAL_198]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_181]][@idx_1] = %[[VAL_188]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_180]], %[[VAL_199]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_200]], %[[VAL_181]], %[[VAL_182]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_104]], %[[VAL_201]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]]:4 = scf.if %[[VAL_202]] -> (!array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_207]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_206]]{{\[}}%[[VAL_208]]] = %[[VAL_204]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_209]][@base] = %[[VAL_206]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_173]]#2[@idx_0] = %[[VAL_209]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_212]], %[[VAL_213]] : index
// CHECK-NEXT:              pod.write %[[VAL_210]][@count] = %[[VAL_214]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_215:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_216:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_214]], %[[VAL_215]] : index
// CHECK-NEXT:              scf.if %[[VAL_216]] {
// CHECK-NEXT:                %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_220:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_218]], %[[VAL_219]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_210]][@comp] = %[[VAL_220]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_173]]#1[@idx_0] = %[[VAL_210]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:              %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_222]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_224]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_223]]{{\[}}%[[VAL_225]]] = %[[VAL_221]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_226]][@base] = %[[VAL_223]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_173]]#2[@idx_0] = %[[VAL_226]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_227]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_229]], %[[VAL_230]] : index
// CHECK-NEXT:              pod.write %[[VAL_227]][@count] = %[[VAL_231]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_231]], %[[VAL_232]] : index
// CHECK-NEXT:              scf.if %[[VAL_233]] {
// CHECK-NEXT:                %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_227]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_228]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_228]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_237:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_235]], %[[VAL_236]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_227]][@comp] = %[[VAL_237]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_173]]#1[@idx_0] = %[[VAL_227]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              scf.yield %[[VAL_102]], %[[VAL_103]], %[[VAL_173]]#1, %[[VAL_173]]#2 : !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_238]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_239]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_241]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_243:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_240]]{{\[}}%[[VAL_242]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_244]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_246:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_245]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_246]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_249:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_248]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_247]]{{\[}}%[[VAL_249]]] = %[[VAL_243]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_250]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_251]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_252]][@in] = %[[VAL_247]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_103]]{{\[}}%[[VAL_254]]] = %[[VAL_252]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_256]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_259:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_258]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_260:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_259]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_261:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_257]][@count] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_262:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_263:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_261]], %[[VAL_262]] : index
// CHECK-NEXT:              pod.write %[[VAL_257]][@count] = %[[VAL_263]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_264:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_265:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_263]], %[[VAL_264]] : index
// CHECK-NEXT:              scf.if %[[VAL_265]] {
// CHECK-NEXT:                %[[VAL_266:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_257]][@params] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_267:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_260]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_268:[0-9a-zA-Z_\.]+]] = function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@compute(%[[VAL_267]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                pod.write %[[VAL_257]][@comp] = %[[VAL_268]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_269]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_102]]{{\[}}%[[VAL_270]]] = %[[VAL_257]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_271]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_272]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_275:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_274]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_276:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_273]]{{\[}}%[[VAL_275]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_278:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_279:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_278]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_279]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_282:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_281]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_280]]{{\[}}%[[VAL_282]]] = %[[VAL_276]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_284:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_283]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_285:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_284]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_285]][@in] = %[[VAL_280]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_287:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_103]]{{\[}}%[[VAL_287]]] = %[[VAL_285]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_289:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_289]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_291]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_292]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_290]][@count] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_296:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_294]], %[[VAL_295]] : index
// CHECK-NEXT:              pod.write %[[VAL_290]][@count] = %[[VAL_296]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_296]], %[[VAL_297]] : index
// CHECK-NEXT:              scf.if %[[VAL_298]] {
// CHECK-NEXT:                %[[VAL_299:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_290]][@params] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_293]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_301:[0-9a-zA-Z_\.]+]] = function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@compute(%[[VAL_300]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                pod.write %[[VAL_290]][@comp] = %[[VAL_301]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_302:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_303:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_302]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_102]]{{\[}}%[[VAL_303]]] = %[[VAL_290]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_304:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_305:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_304]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_306:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_305]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_307:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_306]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_308:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_307]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_310:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_309]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_308]]{{\[}}%[[VAL_310]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_312]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_314:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_315:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_314]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_313]]{{\[}}%[[VAL_315]]] = %[[VAL_311]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_316:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_316]][@base] = %[[VAL_313]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_173]]#2[@idx_1] = %[[VAL_316]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_317]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_320:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_321:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_319]], %[[VAL_320]] : index
// CHECK-NEXT:              pod.write %[[VAL_317]][@count] = %[[VAL_321]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_322:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_323:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_321]], %[[VAL_322]] : index
// CHECK-NEXT:              scf.if %[[VAL_323]] {
// CHECK-NEXT:                %[[VAL_324:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_317]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_325:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_326:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_327:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_325]], %[[VAL_326]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_317]][@comp] = %[[VAL_327]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_173]]#1[@idx_1] = %[[VAL_317]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_328:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_329:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_328]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_330:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_329]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_331:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_330]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_332:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_331]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_333:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_334:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_333]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_332]]{{\[}}%[[VAL_334]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_336:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_337:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_336]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_338:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_339:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_338]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_337]]{{\[}}%[[VAL_339]]] = %[[VAL_335]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_340:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_340]][@base] = %[[VAL_337]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_173]]#2[@idx_1] = %[[VAL_340]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_341:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_342:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_343:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_344:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_345:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_343]], %[[VAL_344]] : index
// CHECK-NEXT:              pod.write %[[VAL_341]][@count] = %[[VAL_345]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_346:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_347:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_345]], %[[VAL_346]] : index
// CHECK-NEXT:              scf.if %[[VAL_347]] {
// CHECK-NEXT:                %[[VAL_348:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_349:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_342]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_350:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_342]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_351:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_349]], %[[VAL_350]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_341]][@comp] = %[[VAL_351]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_173]]#1[@idx_1] = %[[VAL_341]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              scf.yield %[[VAL_102]], %[[VAL_103]], %[[VAL_173]]#1, %[[VAL_173]]#2 : !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_352:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_353:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_104]], %[[VAL_352]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_203]]#0, %[[VAL_203]]#1, %[[VAL_353]], %[[VAL_203]]#2, %[[VAL_203]]#3 : !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_72]][@m2e$inputs] = %[[VAL_94]]#1 : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_358:[0-9a-zA-Z_\.]+]] = %[[VAL_356]] to %[[VAL_355]] step %[[VAL_357]] {
// CHECK-NEXT:            %[[VAL_359:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]#0{{\[}}%[[VAL_358]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_359]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:            array.write %[[VAL_354]]{{\[}}%[[VAL_358]]] = %[[VAL_360]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_72]][@m2e] = %[[VAL_354]] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_72]][@segments$inputs] = %[[VAL_94]]#4 : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]]#3[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_362:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_361]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_363:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]]#3[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_364:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_363]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_365:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_362]], @idx_1 = %[[VAL_364]] }  : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_72]][@segments] = %[[VAL_365]] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_72]] : !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_366:[0-9a-zA-Z_\.]+]]: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, %[[VAL_367:[0-9a-zA-Z_\.]+]]: !array.type<253 x !felt.type<"bn128">> {function.arg_name = "emfIn"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_368:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_366]][@m2e] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          %[[VAL_369:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_366]][@m2e$inputs] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_370:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_366]][@segments] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          %[[VAL_371:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_366]][@segments$inputs] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = global.read @vcp_array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_373:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:          %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_376:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_377:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_378:[0-9a-zA-Z_\.]+]] = %[[VAL_376]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_379:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_380:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_378]], %[[VAL_379]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_380]]) %[[VAL_378]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_381:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_383:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_381]], %[[VAL_382]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_384:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_383]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_385:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_385]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_386:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_386]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_388:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_384]], %[[VAL_387]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_389:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_390:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_388]], %[[VAL_389]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_391:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_392:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_390]], %[[VAL_391]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_393:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_394:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_395:[0-9a-zA-Z_\.]+]] = %[[VAL_393]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_395]], %[[VAL_384]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_396]]) %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_397:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_398:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              %[[VAL_399:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_381]], %[[VAL_398]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_400:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_399]], %[[VAL_397]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_401:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_400]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_402:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_367]]{{\[}}%[[VAL_401]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_403:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_381]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_404:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_405:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_406:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_403]], %[[VAL_405]] : index
// CHECK-NEXT:              %[[VAL_407:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_404]], %[[VAL_406]] : i1, i1
// CHECK-NEXT:              %[[VAL_408:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_409:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_403]], %[[VAL_408]] : index
// CHECK-NEXT:              %[[VAL_410:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_404]], %[[VAL_409]] : i1, i1
// CHECK-NEXT:              scf.execute_region {
// CHECK-NEXT:                scf.if %[[VAL_410]] {
// CHECK-NEXT:                  %[[VAL_411:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_412:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_411]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_413:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_397]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_414:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_412]]{{\[}}%[[VAL_413]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_414]], %[[VAL_402]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  scf.if %[[VAL_407]] {
// CHECK-NEXT:                    %[[VAL_415:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_416:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_415]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_417:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_397]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_418:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_416]]{{\[}}%[[VAL_417]]] : <249 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    constrain.eq %[[VAL_418]], %[[VAL_402]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                  }
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_419:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_420:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_397]], %[[VAL_419]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_420]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_421:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_422:[0-9a-zA-Z_\.]+]] = %[[VAL_384]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_423:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_424:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_392]], %[[VAL_423]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_425:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_422]], %[[VAL_424]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_425]]) %[[VAL_422]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_426:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_427:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_428:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_429:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_428]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_430:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_426]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_431:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_429]]{{\[}}%[[VAL_430]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_431]], %[[VAL_427]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_432:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_433:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_426]], %[[VAL_432]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_433]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_434:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_435:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_381]], %[[VAL_434]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_435]] {
// CHECK-NEXT:              %[[VAL_436:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:              %[[VAL_437:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_438:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_437]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_439:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_440:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_439]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_441:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_438]]{{\[}}%[[VAL_440]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_441]], %[[VAL_436]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_442:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:              %[[VAL_443:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_444:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_443]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_445:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_446:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_445]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_447:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_444]]{{\[}}%[[VAL_446]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_447]], %[[VAL_442]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_448:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_370]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_449:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_448]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_450:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_451:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_450]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_452:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_449]]{{\[}}%[[VAL_451]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_453:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_454:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_453]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_455:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_369]]{{\[}}%[[VAL_454]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_456:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_455]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_457:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_458:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_457]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_459:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_456]]{{\[}}%[[VAL_458]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_459]], %[[VAL_452]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_460:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_370]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_461:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_460]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_462:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_463:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_462]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_464:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_461]]{{\[}}%[[VAL_463]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_465:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_466:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_465]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_467:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_369]]{{\[}}%[[VAL_466]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_468:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_467]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_469:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_470:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_469]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_471:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_468]]{{\[}}%[[VAL_470]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_471]], %[[VAL_464]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_472:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_473:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_472]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_474:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_368]]{{\[}}%[[VAL_473]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_475:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_474]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_476:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_477:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_476]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_478:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_475]]{{\[}}%[[VAL_477]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_479:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_480:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_479]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_481:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_482:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_481]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_483:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_480]]{{\[}}%[[VAL_482]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_483]], %[[VAL_478]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_484:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_485:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_484]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_486:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_368]]{{\[}}%[[VAL_485]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_487:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_486]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_488:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_489:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_488]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_490:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_487]]{{\[}}%[[VAL_489]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_491:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_492:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_491]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_493:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_494:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_493]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_495:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_492]]{{\[}}%[[VAL_494]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_495]], %[[VAL_490]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_496:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_497:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_381]], %[[VAL_496]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_497]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_498:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_499:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_500:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_501:[0-9a-zA-Z_\.]+]] = %[[VAL_499]] to %[[VAL_498]] step %[[VAL_500]] {
// CHECK-NEXT:            %[[VAL_502:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_368]]{{\[}}%[[VAL_501]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:            %[[VAL_503:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_369]]{{\[}}%[[VAL_501]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_504:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_503]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@constrain(%[[VAL_502]], %[[VAL_504]]) : (!struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_505:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_370]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_506:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_507:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_506]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_508:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_506]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @SegmentMulFix_0::@SegmentMulFix_0::@constrain(%[[VAL_505]], %[[VAL_507]], %[[VAL_508]]) : (!struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_509:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_370]][@idx_1] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_510:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_371]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_511:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_510]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_512:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_510]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @SegmentMulFix_1::@SegmentMulFix_1::@constrain(%[[VAL_509]], %[[VAL_511]], %[[VAL_512]]) : (!struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, !array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @vcp_array_const_0 : !array.type<2 x !felt.type<"bn128">> = [#felt<const 5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">> : !felt.type<"bn128">, #felt<const 16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">> : !felt.type<"bn128">]
// CHECK-NEXT:    poly.template @Montgomery2Edwards_2 {
// CHECK-NEXT:      struct.def @Montgomery2Edwards_2 {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_513:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_514:[0-9a-zA-Z_\.]+]] = struct.new : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:          function.return %[[VAL_514]] : !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_515:[0-9a-zA-Z_\.]+]]: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, %[[VAL_516:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_517:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_515]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SegmentMulFix_0 {
// CHECK-NEXT:      struct.def @SegmentMulFix_0 {
// CHECK-NEXT:        struct.member @dbl : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_518:[0-9a-zA-Z_\.]+]]: !array.type<249 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_519:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_520:[0-9a-zA-Z_\.]+]] = struct.new : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_521:[0-9a-zA-Z_\.]+]] = felt.const  83 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_520]] : !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_522:[0-9a-zA-Z_\.]+]]: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, %[[VAL_523:[0-9a-zA-Z_\.]+]]: !array.type<249 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_524:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_525:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_522]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_526:[0-9a-zA-Z_\.]+]] = felt.const  83 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SegmentMulFix_1 {
// CHECK-NEXT:      struct.def @SegmentMulFix_1 {
// CHECK-NEXT:        struct.member @dbl : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_527:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_528:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_529:[0-9a-zA-Z_\.]+]] = struct.new : <@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_530:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_529]] : !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_531:[0-9a-zA-Z_\.]+]]: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, %[[VAL_532:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_533:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_534:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_531]][@dbl] : <@SegmentMulFix_1::@SegmentMulFix_1<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_535:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
