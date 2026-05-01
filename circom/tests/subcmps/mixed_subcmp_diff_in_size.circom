// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>} {
// CHECK-NEXT:    poly.template @BabyPbk_4 {
// CHECK-NEXT:      struct.def @BabyPbk_4 {
// CHECK-NEXT:        struct.member @mulFix : !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:        struct.member @mulFix$inputs : !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@BabyPbk_4::@BabyPbk_4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BabyPbk_4::@BabyPbk_4<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_10]]] = %[[VAL_8]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_13]]] = %[[VAL_11]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_16]]] = %[[VAL_14]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_17]], %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_19]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_22]]) %[[VAL_19]], %[[VAL_20]] : !felt.type<"bn128">, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_25]]{{\[}}%[[VAL_26]]] = %[[VAL_0]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_24]][@emfIn] = %[[VAL_25]] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@count] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:            pod.write %[[VAL_2]][@count] = %[[VAL_29]] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_29]], %[[VAL_30]] : index
// CHECK-NEXT:            scf.if %[[VAL_31]] {
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@params] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = function.call @EscalarMulFix_3::@EscalarMulFix_3::@compute(%[[VAL_33]]) : (!array.type<253 x !felt.type<"bn128">>) -> !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:              pod.write %[[VAL_2]][@comp] = %[[VAL_34]] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_36]], %[[VAL_24]] : !felt.type<"bn128">, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@mulFix$inputs] = %[[VAL_18]]#1 : <@BabyPbk_4::@BabyPbk_4<[]>>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@comp] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@mulFix] = %[[VAL_37]] : <@BabyPbk_4::@BabyPbk_4<[]>>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@mulFix] : <@BabyPbk_4::@BabyPbk_4<[]>>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@mulFix$inputs] : <@BabyPbk_4::@BabyPbk_4<[]>>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_42]]{{\[}}%[[VAL_45]]] = %[[VAL_43]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_42]]{{\[}}%[[VAL_48]]] = %[[VAL_46]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_42]]{{\[}}%[[VAL_51]]] = %[[VAL_49]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_42]]{{\[}}%[[VAL_54]]] = %[[VAL_52]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_57:[0-9a-zA-Z_\.]+]] = %[[VAL_55]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_57]], %[[VAL_58]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_59]]) %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_62]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_63]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_60]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @EscalarMulFix_3::@EscalarMulFix_3::@constrain(%[[VAL_40]], %[[VAL_66]]) : (!struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<253 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EscalarMulFix_3 {
// CHECK-NEXT:      struct.def @EscalarMulFix_3 {
// CHECK-NEXT:        struct.member @m2e : !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:        struct.member @m2e$inputs : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:        struct.member @segments : !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:        struct.member @segments$inputs : !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<253 x !felt.type<"bn128">>) -> !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.new : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_73]], %[[VAL_74]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_70]], %[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_79]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_71]], %[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_72]]) : (!array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_85]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_86]]) %[[VAL_81]], %[[VAL_82]], %[[VAL_83]], %[[VAL_84]] : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_87:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_88:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_89:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_90:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_88]], %[[VAL_91]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_92]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_93]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_97]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_99]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]], %[[VAL_105:[0-9a-zA-Z_\.]+]] = %[[VAL_89]], %[[VAL_106:[0-9a-zA-Z_\.]+]] = %[[VAL_90]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_104]], %[[VAL_93]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_107]]) %[[VAL_104]], %[[VAL_105]], %[[VAL_106]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_108:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_109:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_110:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_88]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_112]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_114]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_88]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_116]], %[[VAL_118]] : index
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_117]], %[[VAL_119]] : i1, i1
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_116]], %[[VAL_121]] : index
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_117]], %[[VAL_122]] : i1, i1
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_125:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_123]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_128]]{{\[}}%[[VAL_129]]] = %[[VAL_115]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  pod.write %[[VAL_127]][@e] = %[[VAL_128]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_110]][@idx_1] = %[[VAL_127]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_130]], %[[VAL_131]] : index
// CHECK-NEXT:                  pod.write %[[VAL_126]][@count] = %[[VAL_132]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_132]], %[[VAL_133]] : index
// CHECK-NEXT:                  scf.if %[[VAL_134]] {
// CHECK-NEXT:                    %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_138:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_136]], %[[VAL_137]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_126]][@comp] = %[[VAL_138]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_109]][@idx_1] = %[[VAL_126]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_109]], %[[VAL_110]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_139:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_120]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_142]]{{\[}}%[[VAL_143]]] = %[[VAL_115]] : <249 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    pod.write %[[VAL_141]][@e] = %[[VAL_142]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_110]][@idx_0] = %[[VAL_141]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_144]], %[[VAL_145]] : index
// CHECK-NEXT:                    pod.write %[[VAL_140]][@count] = %[[VAL_146]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_147]] : index
// CHECK-NEXT:                    scf.if %[[VAL_148]] {
// CHECK-NEXT:                      %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_152:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_150]], %[[VAL_151]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_140]][@comp] = %[[VAL_152]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_109]][@idx_0] = %[[VAL_140]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_109]], %[[VAL_110]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_153:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_154:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_153]], %[[VAL_154]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_139]]#0, %[[VAL_139]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_125]]#0, %[[VAL_125]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_108]], %[[VAL_155]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_156]], %[[VAL_124]]#0, %[[VAL_124]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_158:[0-9a-zA-Z_\.]+]] = %[[VAL_93]], %[[VAL_159:[0-9a-zA-Z_\.]+]] = %[[VAL_103]]#2) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_101]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_158]], %[[VAL_161]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_162]]) %[[VAL_158]], %[[VAL_159]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_163:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_164:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_167]]{{\[}}%[[VAL_168]]] = %[[VAL_165]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_169]][@e] = %[[VAL_167]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_164]][@idx_1] = %[[VAL_169]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_172]], %[[VAL_173]] : index
// CHECK-NEXT:              pod.write %[[VAL_170]][@count] = %[[VAL_174]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_174]], %[[VAL_175]] : index
// CHECK-NEXT:              scf.if %[[VAL_176]] {
// CHECK-NEXT:                %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_180:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_178]], %[[VAL_179]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_170]][@comp] = %[[VAL_180]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_103]]#1[@idx_1] = %[[VAL_170]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_163]], %[[VAL_181]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_182]], %[[VAL_164]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_88]], %[[VAL_183]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_185:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_184]] -> (!array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:              %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_189]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_188]]{{\[}}%[[VAL_190]]] = %[[VAL_186]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_191]][@base] = %[[VAL_188]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_157]]#1[@idx_0] = %[[VAL_191]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_194]], %[[VAL_195]] : index
// CHECK-NEXT:              pod.write %[[VAL_192]][@count] = %[[VAL_196]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_197:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_196]], %[[VAL_197]] : index
// CHECK-NEXT:              scf.if %[[VAL_198]] {
// CHECK-NEXT:                %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_202:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_200]], %[[VAL_201]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_192]][@comp] = %[[VAL_202]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_103]]#1[@idx_0] = %[[VAL_192]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_207:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_205]]{{\[}}%[[VAL_207]]] = %[[VAL_203]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_208]][@base] = %[[VAL_205]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_157]]#1[@idx_0] = %[[VAL_208]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_212:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_211]], %[[VAL_212]] : index
// CHECK-NEXT:              pod.write %[[VAL_209]][@count] = %[[VAL_213]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_215:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_213]], %[[VAL_214]] : index
// CHECK-NEXT:              scf.if %[[VAL_215]] {
// CHECK-NEXT:                %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_219:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_217]], %[[VAL_218]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_209]][@comp] = %[[VAL_219]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_103]]#1[@idx_0] = %[[VAL_209]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_87]], %[[VAL_157]]#1 : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_220]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_222:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_221]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_224:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_223]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_224]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_226]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_227]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_228]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_230]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_229]]{{\[}}%[[VAL_231]]] = %[[VAL_225]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_233]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_234]][@in] = %[[VAL_229]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_87]]{{\[}}%[[VAL_236]]] = %[[VAL_234]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_238]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_241]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_243:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@count] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_244:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_243]], %[[VAL_244]] : index
// CHECK-NEXT:              pod.write %[[VAL_239]][@count] = %[[VAL_245]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_246:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_247:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_245]], %[[VAL_246]] : index
// CHECK-NEXT:              scf.if %[[VAL_247]] {
// CHECK-NEXT:                %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@params] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_249:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_242]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_250:[0-9a-zA-Z_\.]+]] = function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@compute(%[[VAL_249]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                pod.write %[[VAL_239]][@comp] = %[[VAL_250]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_252:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_251]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_69]]{{\[}}%[[VAL_252]]] = %[[VAL_239]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_253]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_254]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_256]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_255]]{{\[}}%[[VAL_257]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_260:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_259]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_261:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_260]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_261]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_264:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_263]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_262]]{{\[}}%[[VAL_264]]] = %[[VAL_258]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_265:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_266:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_265]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_267:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_266]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_267]][@in] = %[[VAL_262]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_269:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_268]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_87]]{{\[}}%[[VAL_269]]] = %[[VAL_267]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_270]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_271]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_274:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_273]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_275:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_274]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_272]][@count] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_277:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_278:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_276]], %[[VAL_277]] : index
// CHECK-NEXT:              pod.write %[[VAL_272]][@count] = %[[VAL_278]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_279:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_280:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_278]], %[[VAL_279]] : index
// CHECK-NEXT:              scf.if %[[VAL_280]] {
// CHECK-NEXT:                %[[VAL_281:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_272]][@params] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_282:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_283:[0-9a-zA-Z_\.]+]] = function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@compute(%[[VAL_282]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                pod.write %[[VAL_272]][@comp] = %[[VAL_283]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                %[[VAL_284:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_285:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_284]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_69]]{{\[}}%[[VAL_285]]] = %[[VAL_272]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_287:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_288:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_287]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_288]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_289]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_291]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_290]]{{\[}}%[[VAL_292]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_294]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_296]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_295]]{{\[}}%[[VAL_297]]] = %[[VAL_293]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_298]][@base] = %[[VAL_295]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_157]]#1[@idx_1] = %[[VAL_298]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_299:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_299]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_302:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_303:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_301]], %[[VAL_302]] : index
// CHECK-NEXT:              pod.write %[[VAL_299]][@count] = %[[VAL_303]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_304:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_305:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_303]], %[[VAL_304]] : index
// CHECK-NEXT:              scf.if %[[VAL_305]] {
// CHECK-NEXT:                %[[VAL_306:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_299]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_307:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_308:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_309:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_307]], %[[VAL_308]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_299]][@comp] = %[[VAL_309]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_103]]#1[@idx_1] = %[[VAL_299]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_310:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_311:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_311]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_312]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_314:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_313]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_315:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_316:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_315]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_317:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_314]]{{\[}}%[[VAL_316]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_320:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_320]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_319]]{{\[}}%[[VAL_321]]] = %[[VAL_317]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_322:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_322]][@base] = %[[VAL_319]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_157]]#1[@idx_1] = %[[VAL_322]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_323:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_324:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_325:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_323]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_326:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_327:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_325]], %[[VAL_326]] : index
// CHECK-NEXT:              pod.write %[[VAL_323]][@count] = %[[VAL_327]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_328:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_329:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_327]], %[[VAL_328]] : index
// CHECK-NEXT:              scf.if %[[VAL_329]] {
// CHECK-NEXT:                %[[VAL_330:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_323]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_331:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_324]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_332:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_324]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_333:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_331]], %[[VAL_332]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_323]][@comp] = %[[VAL_333]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_103]]#1[@idx_1] = %[[VAL_323]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_87]], %[[VAL_157]]#1 : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_88]], %[[VAL_334]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_185]]#0, %[[VAL_335]], %[[VAL_103]]#1, %[[VAL_185]]#1 : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_68]][@m2e$inputs] = %[[VAL_80]]#0 : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_336:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          %[[VAL_337:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_338:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_340:[0-9a-zA-Z_\.]+]] = %[[VAL_338]] to %[[VAL_337]] step %[[VAL_339]] {
// CHECK-NEXT:            %[[VAL_341:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_340]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_342:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_341]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:            array.write %[[VAL_336]]{{\[}}%[[VAL_340]]] = %[[VAL_342]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_68]][@m2e] = %[[VAL_336]] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_68]][@segments$inputs] = %[[VAL_80]]#3 : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_343:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]]#2[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_344:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_343]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_345:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]]#2[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_345]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_347:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_344]], @idx_1 = %[[VAL_346]] }  : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_68]][@segments] = %[[VAL_347]] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_68]] : !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_348:[0-9a-zA-Z_\.]+]]: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, %[[VAL_349:[0-9a-zA-Z_\.]+]]: !array.type<253 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_348]][@m2e] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_348]][@m2e$inputs] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_348]][@segments] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_348]][@segments$inputs] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_354]], %[[VAL_355]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:          %[[VAL_358:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_359:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_362:[0-9a-zA-Z_\.]+]] = %[[VAL_360]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_363:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_364:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_362]], %[[VAL_363]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_364]]) %[[VAL_362]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_365:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_366:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_365]], %[[VAL_366]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_368:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_367]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_369:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_369]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_370:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_370]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_371:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_372:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_368]], %[[VAL_371]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_373:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_372]], %[[VAL_373]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_376:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_374]], %[[VAL_375]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_377:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_378:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_379:[0-9a-zA-Z_\.]+]] = %[[VAL_377]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_380:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_379]], %[[VAL_368]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_380]]) %[[VAL_379]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_381:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_382:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              %[[VAL_383:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_365]], %[[VAL_382]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_384:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_383]], %[[VAL_381]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_385:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_384]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_386:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_349]]{{\[}}%[[VAL_385]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_387:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_365]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_388:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_389:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_390:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_387]], %[[VAL_389]] : index
// CHECK-NEXT:              %[[VAL_391:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_388]], %[[VAL_390]] : i1, i1
// CHECK-NEXT:              %[[VAL_392:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_393:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_387]], %[[VAL_392]] : index
// CHECK-NEXT:              %[[VAL_394:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_388]], %[[VAL_393]] : i1, i1
// CHECK-NEXT:              scf.execute_region {
// CHECK-NEXT:                scf.if %[[VAL_394]] {
// CHECK-NEXT:                  %[[VAL_395:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_396:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_395]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_397:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_381]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_398:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_396]]{{\[}}%[[VAL_397]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_398]], %[[VAL_386]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  scf.if %[[VAL_391]] {
// CHECK-NEXT:                    %[[VAL_399:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_400:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_399]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_401:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_381]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_402:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_400]]{{\[}}%[[VAL_401]]] : <249 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    constrain.eq %[[VAL_402]], %[[VAL_386]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                  }
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_403:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_404:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_381]], %[[VAL_403]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_404]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_405:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_406:[0-9a-zA-Z_\.]+]] = %[[VAL_368]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_407:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_408:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_376]], %[[VAL_407]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_409:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_406]], %[[VAL_408]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_409]]) %[[VAL_406]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_410:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_411:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_412:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_413:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_412]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_414:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_410]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_415:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_413]]{{\[}}%[[VAL_414]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_415]], %[[VAL_411]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_416:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_417:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_410]], %[[VAL_416]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_417]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_418:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_419:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_365]], %[[VAL_418]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_419]] {
// CHECK-NEXT:              %[[VAL_420:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:              %[[VAL_421:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_422:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_421]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_423:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_424:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_423]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_425:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_422]]{{\[}}%[[VAL_424]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_425]], %[[VAL_420]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_426:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:              %[[VAL_427:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_428:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_427]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_429:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_430:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_429]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_431:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_428]]{{\[}}%[[VAL_430]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_431]], %[[VAL_426]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_432:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_352]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_433:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_432]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_434:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_435:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_434]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_436:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_433]]{{\[}}%[[VAL_435]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_437:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_438:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_437]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_439:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_351]]{{\[}}%[[VAL_438]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_440:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_439]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_441:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_442:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_441]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_443:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_440]]{{\[}}%[[VAL_442]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_443]], %[[VAL_436]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_444:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_352]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_445:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_444]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_446:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_447:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_446]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_448:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_445]]{{\[}}%[[VAL_447]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_449:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_450:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_449]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_451:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_351]]{{\[}}%[[VAL_450]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_452:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_451]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_453:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_454:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_453]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_455:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_452]]{{\[}}%[[VAL_454]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_455]], %[[VAL_448]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_456:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_457:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_456]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_458:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_350]]{{\[}}%[[VAL_457]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_459:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_458]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_460:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_461:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_460]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_462:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_459]]{{\[}}%[[VAL_461]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_463:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_464:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_463]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_465:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_466:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_465]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_467:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_464]]{{\[}}%[[VAL_466]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_467]], %[[VAL_462]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_468:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_469:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_468]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_470:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_350]]{{\[}}%[[VAL_469]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_471:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_470]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_472:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_473:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_472]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_474:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_471]]{{\[}}%[[VAL_473]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_475:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_476:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_475]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_477:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_478:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_477]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_479:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_476]]{{\[}}%[[VAL_478]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_479]], %[[VAL_474]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_480:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_481:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_365]], %[[VAL_480]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_481]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_482:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_483:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_484:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_485:[0-9a-zA-Z_\.]+]] = %[[VAL_483]] to %[[VAL_482]] step %[[VAL_484]] {
// CHECK-NEXT:            %[[VAL_486:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_350]]{{\[}}%[[VAL_485]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:            %[[VAL_487:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_351]]{{\[}}%[[VAL_485]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_488:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_487]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@constrain(%[[VAL_486]], %[[VAL_488]]) : (!struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_489:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_352]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_490:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_491:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_490]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_492:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_490]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @SegmentMulFix_0::@SegmentMulFix_0::@constrain(%[[VAL_489]], %[[VAL_491]], %[[VAL_492]]) : (!struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_493:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_352]][@idx_1] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_494:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_353]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_495:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_494]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_496:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_494]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @SegmentMulFix_1::@SegmentMulFix_1::@constrain(%[[VAL_493]], %[[VAL_495]], %[[VAL_496]]) : (!struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, !array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Montgomery2Edwards_2 {
// CHECK-NEXT:      struct.def @Montgomery2Edwards_2 {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_497:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_498:[0-9a-zA-Z_\.]+]] = struct.new : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:          function.return %[[VAL_498]] : !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_499:[0-9a-zA-Z_\.]+]]: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, %[[VAL_500:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_501:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_499]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SegmentMulFix_0 {
// CHECK-NEXT:      struct.def @SegmentMulFix_0 {
// CHECK-NEXT:        struct.member @dbl : !array.type<2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_502:[0-9a-zA-Z_\.]+]]: !array.type<249 x !felt.type<"bn128">>, %[[VAL_503:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_504:[0-9a-zA-Z_\.]+]] = struct.new : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_505:[0-9a-zA-Z_\.]+]] = felt.const  83 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_504]] : !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_506:[0-9a-zA-Z_\.]+]]: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, %[[VAL_507:[0-9a-zA-Z_\.]+]]: !array.type<249 x !felt.type<"bn128">>, %[[VAL_508:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_509:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_506]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_510:[0-9a-zA-Z_\.]+]] = felt.const  83 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SegmentMulFix_1 {
// CHECK-NEXT:      struct.def @SegmentMulFix_1 {
// CHECK-NEXT:        struct.member @dbl : !array.type<2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_511:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">>, %[[VAL_512:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_513:[0-9a-zA-Z_\.]+]] = struct.new : <@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_514:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_513]] : !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_515:[0-9a-zA-Z_\.]+]]: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, %[[VAL_516:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">>, %[[VAL_517:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_518:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_515]][@dbl] : <@SegmentMulFix_1::@SegmentMulFix_1<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_519:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
