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
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_19]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_21]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_21]], %[[VAL_22]] : !felt.type<"bn128">, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_28]]] = %[[VAL_0]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_26]][@emfIn] = %[[VAL_27]] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_29]], %[[VAL_30]] : index
// CHECK-NEXT:            pod.write %[[VAL_4]][@count] = %[[VAL_31]] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_31]], %[[VAL_32]] : index
// CHECK-NEXT:            scf.if %[[VAL_33]] {
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@params] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = function.call @EscalarMulFix_3::@EscalarMulFix_3::@compute(%[[VAL_35]]) : (!array.type<253 x !felt.type<"bn128">>) -> !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:              pod.write %[[VAL_4]][@comp] = %[[VAL_36]] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_38]], %[[VAL_26]] : !felt.type<"bn128">, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@mulFix$inputs] = %[[VAL_20]]#1 : <@BabyPbk_4::@BabyPbk_4<[]>>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@mulFix] = %[[VAL_39]] : <@BabyPbk_4::@BabyPbk_4<[]>>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>, %[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_40]][@mulFix] : <@BabyPbk_4::@BabyPbk_4<[]>>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_40]][@mulFix$inputs] : <@BabyPbk_4::@BabyPbk_4<[]>>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_44]]{{\[}}%[[VAL_47]]] = %[[VAL_45]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_44]]{{\[}}%[[VAL_50]]] = %[[VAL_48]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_44]]{{\[}}%[[VAL_53]]] = %[[VAL_51]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_44]]{{\[}}%[[VAL_56]]] = %[[VAL_54]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_57]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_59]], %[[VAL_60]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_61]]) %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_64]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_65]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @EscalarMulFix_3::@EscalarMulFix_3::@constrain(%[[VAL_42]], %[[VAL_68]]) : (!struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<253 x !felt.type<"bn128">>) -> ()
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
// CHECK-NEXT:        function.def @compute(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !array.type<253 x !felt.type<"bn128">> {function.arg_name = "emfIn"}) -> !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.new : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_76:[0-9a-zA-Z_\.]+]] = %[[VAL_74]] to %[[VAL_73]] step %[[VAL_75]] {
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_77]], @params = %[[VAL_72]] }  : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_71]]{{\[}}%[[VAL_76]]] = %[[VAL_78]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 251 : index
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_81]], @params = %[[VAL_80]] }  : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_83]], @params = %[[VAL_80]] }  : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_82]], @idx_1 = %[[VAL_84]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_87]], %[[VAL_88]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_95:[0-9a-zA-Z_\.]+]] = %[[VAL_79]], %[[VAL_96:[0-9a-zA-Z_\.]+]] = %[[VAL_93]], %[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_85]], %[[VAL_98:[0-9a-zA-Z_\.]+]] = %[[VAL_86]]) : (!array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_96]], %[[VAL_99]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_100]]) %[[VAL_95]], %[[VAL_96]], %[[VAL_97]], %[[VAL_98]] : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_101:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_102:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_103:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_104:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_102]], %[[VAL_105]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_106]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_107]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_111]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_113]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_118:[0-9a-zA-Z_\.]+]] = %[[VAL_116]], %[[VAL_119:[0-9a-zA-Z_\.]+]] = %[[VAL_103]], %[[VAL_120:[0-9a-zA-Z_\.]+]] = %[[VAL_104]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_118]], %[[VAL_107]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_121]]) %[[VAL_118]], %[[VAL_119]], %[[VAL_120]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_122:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_123:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_124:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_102]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_126]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_128]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_130]], %[[VAL_132]] : index
// CHECK-NEXT:              %[[VAL_134:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_131]], %[[VAL_133]] : i1, i1
// CHECK-NEXT:              %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_130]], %[[VAL_135]] : index
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_131]], %[[VAL_136]] : i1, i1
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_139:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_137]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_142]]{{\[}}%[[VAL_143]]] = %[[VAL_129]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  pod.write %[[VAL_141]][@e] = %[[VAL_142]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_124]][@idx_1] = %[[VAL_141]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_144]], %[[VAL_145]] : index
// CHECK-NEXT:                  pod.write %[[VAL_140]][@count] = %[[VAL_146]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_147]] : index
// CHECK-NEXT:                  scf.if %[[VAL_148]] {
// CHECK-NEXT:                    %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_152:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_150]], %[[VAL_151]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_140]][@comp] = %[[VAL_152]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_123]][@idx_1] = %[[VAL_140]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_123]], %[[VAL_124]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_153:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_134]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_157:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]] : !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_156]]{{\[}}%[[VAL_157]]] = %[[VAL_129]] : <249 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    pod.write %[[VAL_155]][@e] = %[[VAL_156]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_124]][@idx_0] = %[[VAL_155]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_159:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    %[[VAL_160:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_158]], %[[VAL_159]] : index
// CHECK-NEXT:                    pod.write %[[VAL_154]][@count] = %[[VAL_160]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_160]], %[[VAL_161]] : index
// CHECK-NEXT:                    scf.if %[[VAL_162]] {
// CHECK-NEXT:                      %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_166:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_164]], %[[VAL_165]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_154]][@comp] = %[[VAL_166]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_123]][@idx_0] = %[[VAL_154]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_123]], %[[VAL_124]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_167:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_168:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_167]], %[[VAL_168]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_153]]#0, %[[VAL_153]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_139]]#0, %[[VAL_139]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_122]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_170]], %[[VAL_138]]#0, %[[VAL_138]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_172:[0-9a-zA-Z_\.]+]] = %[[VAL_107]], %[[VAL_173:[0-9a-zA-Z_\.]+]] = %[[VAL_117]]#2) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_115]], %[[VAL_174]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_172]], %[[VAL_175]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_176]]) %[[VAL_172]], %[[VAL_173]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_177:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_178:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:              %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_177]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_181]]{{\[}}%[[VAL_182]]] = %[[VAL_179]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_183]][@e] = %[[VAL_181]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_178]][@idx_1] = %[[VAL_183]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_186]], %[[VAL_187]] : index
// CHECK-NEXT:              pod.write %[[VAL_184]][@count] = %[[VAL_188]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_188]], %[[VAL_189]] : index
// CHECK-NEXT:              scf.if %[[VAL_190]] {
// CHECK-NEXT:                %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_194:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_192]], %[[VAL_193]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_184]][@comp] = %[[VAL_194]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_117]]#1[@idx_1] = %[[VAL_184]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_177]], %[[VAL_195]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_196]], %[[VAL_178]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_102]], %[[VAL_197]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_198]] -> (!array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:              %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_201]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_203]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_202]]{{\[}}%[[VAL_204]]] = %[[VAL_200]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_205]][@base] = %[[VAL_202]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_171]]#1[@idx_0] = %[[VAL_205]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_208]], %[[VAL_209]] : index
// CHECK-NEXT:              pod.write %[[VAL_206]][@count] = %[[VAL_210]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_212:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_210]], %[[VAL_211]] : index
// CHECK-NEXT:              scf.if %[[VAL_212]] {
// CHECK-NEXT:                %[[VAL_213:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_207]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_207]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_216:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_214]], %[[VAL_215]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_206]][@comp] = %[[VAL_216]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_117]]#1[@idx_0] = %[[VAL_206]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:              %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_221:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_219]]{{\[}}%[[VAL_221]]] = %[[VAL_217]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_222]][@base] = %[[VAL_219]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_171]]#1[@idx_0] = %[[VAL_222]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_224:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_223]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_225]], %[[VAL_226]] : index
// CHECK-NEXT:              pod.write %[[VAL_223]][@count] = %[[VAL_227]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_227]], %[[VAL_228]] : index
// CHECK-NEXT:              scf.if %[[VAL_229]] {
// CHECK-NEXT:                %[[VAL_230:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_223]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_224]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_224]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_233:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_231]], %[[VAL_232]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_223]][@comp] = %[[VAL_233]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_117]]#1[@idx_0] = %[[VAL_223]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_101]], %[[VAL_171]]#1 : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_235]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_236]]{{\[}}%[[VAL_238]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_101]]{{\[}}%[[VAL_241]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_243:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_242]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_244]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_243]]{{\[}}%[[VAL_245]]] = %[[VAL_239]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_246:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_247:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_246]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_248:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_101]]{{\[}}%[[VAL_247]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_248]][@in] = %[[VAL_243]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_249]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_101]]{{\[}}%[[VAL_250]]] = %[[VAL_248]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_251]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_252]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_254]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_101]]{{\[}}%[[VAL_255]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_253]][@count] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_259:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_257]], %[[VAL_258]] : index
// CHECK-NEXT:              pod.write %[[VAL_253]][@count] = %[[VAL_259]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_260:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_261:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_259]], %[[VAL_260]] : index
// CHECK-NEXT:              scf.if %[[VAL_261]] {
// CHECK-NEXT:                %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_253]][@params] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_263:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_256]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_264:[0-9a-zA-Z_\.]+]] = function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@compute(%[[VAL_263]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                pod.write %[[VAL_253]][@comp] = %[[VAL_264]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                %[[VAL_265:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_266:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_265]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_71]]{{\[}}%[[VAL_266]]] = %[[VAL_253]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_267:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_268:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_267]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_269:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_268]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_270]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_271]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_274:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_273]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_275:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_101]]{{\[}}%[[VAL_274]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_275]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_278:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_276]]{{\[}}%[[VAL_278]]] = %[[VAL_272]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_279:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_280:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_279]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_281:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_101]]{{\[}}%[[VAL_280]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_281]][@in] = %[[VAL_276]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_282:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_283:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_282]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_101]]{{\[}}%[[VAL_283]]] = %[[VAL_281]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_284:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_285:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_284]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_286:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_285]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_287:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_288:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_287]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_289:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_101]]{{\[}}%[[VAL_288]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_286]][@count] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_290]], %[[VAL_291]] : index
// CHECK-NEXT:              pod.write %[[VAL_286]][@count] = %[[VAL_292]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_292]], %[[VAL_293]] : index
// CHECK-NEXT:              scf.if %[[VAL_294]] {
// CHECK-NEXT:                %[[VAL_295:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_286]][@params] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_296:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_289]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_297:[0-9a-zA-Z_\.]+]] = function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@compute(%[[VAL_296]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                pod.write %[[VAL_286]][@comp] = %[[VAL_297]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_71]]{{\[}}%[[VAL_299]]] = %[[VAL_286]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_301:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_300]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_302:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_301]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_303:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_302]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_304:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_303]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_305:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_306:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_305]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_307:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_304]]{{\[}}%[[VAL_306]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_308:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_309:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_308]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_310:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_311:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_309]]{{\[}}%[[VAL_311]]] = %[[VAL_307]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_312]][@base] = %[[VAL_309]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_171]]#1[@idx_1] = %[[VAL_312]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_314:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_315:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_313]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_316:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_317:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_315]], %[[VAL_316]] : index
// CHECK-NEXT:              pod.write %[[VAL_313]][@count] = %[[VAL_317]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_318:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_319:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_317]], %[[VAL_318]] : index
// CHECK-NEXT:              scf.if %[[VAL_319]] {
// CHECK-NEXT:                %[[VAL_320:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_313]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_321:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_314]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_322:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_314]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_323:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_321]], %[[VAL_322]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_313]][@comp] = %[[VAL_323]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_117]]#1[@idx_1] = %[[VAL_313]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_324]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_326:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_325]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_327:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_326]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_328:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_327]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_330:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_329]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_331:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_328]]{{\[}}%[[VAL_330]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_332:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_334:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_335:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_334]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_333]]{{\[}}%[[VAL_335]]] = %[[VAL_331]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_336:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_336]][@base] = %[[VAL_333]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_171]]#1[@idx_1] = %[[VAL_336]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_337:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_338:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]]#1[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_339:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_337]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_340:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_341:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_339]], %[[VAL_340]] : index
// CHECK-NEXT:              pod.write %[[VAL_337]][@count] = %[[VAL_341]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_342:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_343:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_341]], %[[VAL_342]] : index
// CHECK-NEXT:              scf.if %[[VAL_343]] {
// CHECK-NEXT:                %[[VAL_344:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_337]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_345:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_338]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_346:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_338]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_347:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_345]], %[[VAL_346]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_337]][@comp] = %[[VAL_347]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_117]]#1[@idx_1] = %[[VAL_337]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_101]], %[[VAL_171]]#1 : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_349:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_102]], %[[VAL_348]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_199]]#0, %[[VAL_349]], %[[VAL_117]]#1, %[[VAL_199]]#1 : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_70]][@m2e$inputs] = %[[VAL_94]]#0 : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_354:[0-9a-zA-Z_\.]+]] = %[[VAL_352]] to %[[VAL_351]] step %[[VAL_353]] {
// CHECK-NEXT:            %[[VAL_355:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_354]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_356:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_355]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:            array.write %[[VAL_350]]{{\[}}%[[VAL_354]]] = %[[VAL_356]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_70]][@m2e] = %[[VAL_350]] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_70]][@segments$inputs] = %[[VAL_94]]#3 : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]]#2[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_358:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_357]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_359:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]]#2[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_360:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_359]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_358]], @idx_1 = %[[VAL_360]] }  : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_70]][@segments] = %[[VAL_361]] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_70]] : !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_362:[0-9a-zA-Z_\.]+]]: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, %[[VAL_363:[0-9a-zA-Z_\.]+]]: !array.type<253 x !felt.type<"bn128">> {function.arg_name = "emfIn"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_364:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_362]][@m2e] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          %[[VAL_365:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_362]][@m2e$inputs] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_366:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_362]][@segments] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          %[[VAL_367:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_362]][@segments$inputs] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_368:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_369:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_370:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_368]], %[[VAL_369]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_371:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_373:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_375:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_376:[0-9a-zA-Z_\.]+]] = %[[VAL_374]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_377:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_378:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_376]], %[[VAL_377]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_378]]) %[[VAL_376]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_379:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_380:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_379]], %[[VAL_380]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_381]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_383:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_383]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_384:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_384]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_385:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_382]], %[[VAL_385]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_388:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_386]], %[[VAL_387]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_389:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_390:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_388]], %[[VAL_389]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_391:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_392:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_393:[0-9a-zA-Z_\.]+]] = %[[VAL_391]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_394:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_393]], %[[VAL_382]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_394]]) %[[VAL_393]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_395:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              %[[VAL_397:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_379]], %[[VAL_396]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_398:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_397]], %[[VAL_395]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_399:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_398]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_400:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_363]]{{\[}}%[[VAL_399]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_401:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_379]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_402:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_403:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_404:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_401]], %[[VAL_403]] : index
// CHECK-NEXT:              %[[VAL_405:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_402]], %[[VAL_404]] : i1, i1
// CHECK-NEXT:              %[[VAL_406:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_407:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_401]], %[[VAL_406]] : index
// CHECK-NEXT:              %[[VAL_408:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_402]], %[[VAL_407]] : i1, i1
// CHECK-NEXT:              scf.execute_region {
// CHECK-NEXT:                scf.if %[[VAL_408]] {
// CHECK-NEXT:                  %[[VAL_409:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_410:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_409]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_411:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_412:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_410]]{{\[}}%[[VAL_411]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_412]], %[[VAL_400]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  scf.if %[[VAL_405]] {
// CHECK-NEXT:                    %[[VAL_413:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_414:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_413]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_415:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_416:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_414]]{{\[}}%[[VAL_415]]] : <249 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    constrain.eq %[[VAL_416]], %[[VAL_400]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                  }
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_417:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_418:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_395]], %[[VAL_417]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_418]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_419:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_420:[0-9a-zA-Z_\.]+]] = %[[VAL_382]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_421:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_422:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_390]], %[[VAL_421]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_423:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_420]], %[[VAL_422]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_423]]) %[[VAL_420]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_424:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_425:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_426:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_427:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_426]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_428:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_429:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_427]]{{\[}}%[[VAL_428]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_429]], %[[VAL_425]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_430:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_431:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_424]], %[[VAL_430]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_431]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_432:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_433:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_379]], %[[VAL_432]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_433]] {
// CHECK-NEXT:              %[[VAL_434:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:              %[[VAL_435:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_436:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_435]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_437:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_438:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_437]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_439:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_436]]{{\[}}%[[VAL_438]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_439]], %[[VAL_434]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_440:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:              %[[VAL_441:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_442:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_441]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_443:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_444:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_443]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_445:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_442]]{{\[}}%[[VAL_444]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_445]], %[[VAL_440]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_446:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_366]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_447:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_446]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_448:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_449:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_448]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_450:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_447]]{{\[}}%[[VAL_449]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_451:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_452:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_451]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_453:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_365]]{{\[}}%[[VAL_452]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_454:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_453]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_455:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_456:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_455]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_457:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_454]]{{\[}}%[[VAL_456]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_457]], %[[VAL_450]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_458:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_366]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_459:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_458]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_460:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_461:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_460]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_462:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_459]]{{\[}}%[[VAL_461]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_463:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_464:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_463]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_465:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_365]]{{\[}}%[[VAL_464]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_466:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_465]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_467:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_468:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_467]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_469:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_466]]{{\[}}%[[VAL_468]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_469]], %[[VAL_462]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_470:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_471:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_470]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_472:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_364]]{{\[}}%[[VAL_471]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_473:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_472]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_474:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_475:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_474]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_476:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_473]]{{\[}}%[[VAL_475]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_477:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_478:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_477]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_479:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_480:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_479]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_481:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_478]]{{\[}}%[[VAL_480]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_481]], %[[VAL_476]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_482:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_483:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_482]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_484:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_364]]{{\[}}%[[VAL_483]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_485:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_484]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_486:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_487:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_486]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_488:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_485]]{{\[}}%[[VAL_487]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_489:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_490:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_489]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_491:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_492:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_491]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_493:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_490]]{{\[}}%[[VAL_492]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_493]], %[[VAL_488]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_494:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_495:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_379]], %[[VAL_494]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_495]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_496:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_497:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_498:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_499:[0-9a-zA-Z_\.]+]] = %[[VAL_497]] to %[[VAL_496]] step %[[VAL_498]] {
// CHECK-NEXT:            %[[VAL_500:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_364]]{{\[}}%[[VAL_499]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:            %[[VAL_501:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_365]]{{\[}}%[[VAL_499]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_502:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_501]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@constrain(%[[VAL_500]], %[[VAL_502]]) : (!struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_503:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_366]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_504:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_505:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_504]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_506:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_504]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @SegmentMulFix_0::@SegmentMulFix_0::@constrain(%[[VAL_503]], %[[VAL_505]], %[[VAL_506]]) : (!struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_507:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_366]][@idx_1] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_508:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_367]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_509:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_508]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_510:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_508]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @SegmentMulFix_1::@SegmentMulFix_1::@constrain(%[[VAL_507]], %[[VAL_509]], %[[VAL_510]]) : (!struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, !array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Montgomery2Edwards_2 {
// CHECK-NEXT:      struct.def @Montgomery2Edwards_2 {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_511:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_512:[0-9a-zA-Z_\.]+]] = struct.new : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:          function.return %[[VAL_512]] : !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_513:[0-9a-zA-Z_\.]+]]: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, %[[VAL_514:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_515:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_513]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SegmentMulFix_0 {
// CHECK-NEXT:      struct.def @SegmentMulFix_0 {
// CHECK-NEXT:        struct.member @dbl : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_516:[0-9a-zA-Z_\.]+]]: !array.type<249 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_517:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_518:[0-9a-zA-Z_\.]+]] = struct.new : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_519:[0-9a-zA-Z_\.]+]] = felt.const  83 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_518]] : !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_520:[0-9a-zA-Z_\.]+]]: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, %[[VAL_521:[0-9a-zA-Z_\.]+]]: !array.type<249 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_522:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_523:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_520]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_524:[0-9a-zA-Z_\.]+]] = felt.const  83 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SegmentMulFix_1 {
// CHECK-NEXT:      struct.def @SegmentMulFix_1 {
// CHECK-NEXT:        struct.member @dbl : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_525:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_526:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_527:[0-9a-zA-Z_\.]+]] = struct.new : <@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_528:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_527]] : !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_529:[0-9a-zA-Z_\.]+]]: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, %[[VAL_530:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_531:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_532:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_529]][@dbl] : <@SegmentMulFix_1::@SegmentMulFix_1<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_533:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
