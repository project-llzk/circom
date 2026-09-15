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
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]], %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_13]]) %[[VAL_9]], %[[VAL_10]], %[[VAL_11]] : !felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_18]]] = %[[VAL_0]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_16]][@emfIn] = %[[VAL_17]] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@count] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_19]], %[[VAL_20]] : index
// CHECK-NEXT:            pod.write %[[VAL_15]][@count] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:            scf.if %[[VAL_23]] {
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@params] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @EscalarMulFix_3::@EscalarMulFix_3::@compute(%[[VAL_25]]) : (!array.type<253 x !felt.type<"bn128">>) -> !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:              pod.write %[[VAL_15]][@comp] = %[[VAL_26]] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_28]], %[[VAL_15]], %[[VAL_16]] : !felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@mulFix$inputs] = %[[VAL_8]]#2 : <@BabyPbk_4::@BabyPbk_4<[]>>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]]#1[@comp] : <[@count: index, @comp: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, @params: !pod.type<[]>]>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@mulFix] = %[[VAL_29]] : <@BabyPbk_4::@BabyPbk_4<[]>>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@BabyPbk_4::@BabyPbk_4<[]>>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@mulFix] : <@BabyPbk_4::@BabyPbk_4<[]>>, !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@mulFix$inputs] : <@BabyPbk_4::@BabyPbk_4<[]>>, !pod.type<[@emfIn: !array.type<253 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_35]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_37]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_39]]) %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_42]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_43]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@emfIn] : <[@emfIn: !array.type<253 x !felt.type<"bn128">>]>, !array.type<253 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @EscalarMulFix_3::@EscalarMulFix_3::@constrain(%[[VAL_32]], %[[VAL_46]]) : (!struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<253 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">,  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">]
// CHECK-NEXT:      global.def const @vcp_array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">,  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EscalarMulFix_3 {
// CHECK-NEXT:      struct.def @EscalarMulFix_3 {
// CHECK-NEXT:        struct.member @m2e : !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:        struct.member @m2e$inputs : !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        struct.member @segments : !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:        struct.member @segments$inputs : !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !array.type<253 x !felt.type<"bn128">> {function.arg_name = "emfIn"}) -> !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.new : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]] to %[[VAL_51]] step %[[VAL_53]] {
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_55]], @params = %[[VAL_50]] }  : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_49]]{{\[}}%[[VAL_54]]] = %[[VAL_56]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 251 : index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_59]], @params = %[[VAL_58]] }  : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_61]], @params = %[[VAL_58]] }  : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_60]], @idx_1 = %[[VAL_62]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = global.read const @global::@vcp_array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]]:5 = scf.while (%[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_49]], %[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_69]], %[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_63]], %[[VAL_75:[0-9a-zA-Z_\.]+]] = %[[VAL_64]]) : (!array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_73]], %[[VAL_76]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_77]]) %[[VAL_71]], %[[VAL_72]], %[[VAL_73]], %[[VAL_74]], %[[VAL_75]] : !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_78:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, %[[VAL_79:[0-9a-zA-Z_\.]+]]: !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_80]], %[[VAL_83]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_84]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_85]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_89]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_91]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_96:[0-9a-zA-Z_\.]+]] = %[[VAL_94]], %[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_81]], %[[VAL_98:[0-9a-zA-Z_\.]+]] = %[[VAL_82]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_96]], %[[VAL_85]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_99]]) %[[VAL_96]], %[[VAL_97]], %[[VAL_98]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_100:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_101:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_102:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_80]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_104]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_106]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_108]], %[[VAL_110]] : index
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_109]], %[[VAL_111]] : i1, i1
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_108]], %[[VAL_113]] : index
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_109]], %[[VAL_114]] : i1, i1
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_117:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_115]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_120]]{{\[}}%[[VAL_121]]] = %[[VAL_107]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  pod.write %[[VAL_119]][@e] = %[[VAL_120]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_102]][@idx_1] = %[[VAL_119]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_122]], %[[VAL_123]] : index
// CHECK-NEXT:                  pod.write %[[VAL_118]][@count] = %[[VAL_124]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_124]], %[[VAL_125]] : index
// CHECK-NEXT:                  scf.if %[[VAL_126]] {
// CHECK-NEXT:                    %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_130:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_128]], %[[VAL_129]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_118]][@comp] = %[[VAL_130]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_101]][@idx_1] = %[[VAL_118]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_101]], %[[VAL_102]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_131:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_112]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_135:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_134]]{{\[}}%[[VAL_135]]] = %[[VAL_107]] : <249 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    pod.write %[[VAL_133]][@e] = %[[VAL_134]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_102]][@idx_0] = %[[VAL_133]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_136]], %[[VAL_137]] : index
// CHECK-NEXT:                    pod.write %[[VAL_132]][@count] = %[[VAL_138]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_138]], %[[VAL_139]] : index
// CHECK-NEXT:                    scf.if %[[VAL_140]] {
// CHECK-NEXT:                      %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_144:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_142]], %[[VAL_143]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_132]][@comp] = %[[VAL_144]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_101]][@idx_0] = %[[VAL_132]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_101]], %[[VAL_102]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_145:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_146:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_145]], %[[VAL_146]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_131]]#0, %[[VAL_131]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_117]]#0, %[[VAL_117]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_148]], %[[VAL_116]]#0, %[[VAL_116]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_150:[0-9a-zA-Z_\.]+]] = %[[VAL_85]], %[[VAL_151:[0-9a-zA-Z_\.]+]] = %[[VAL_95]]#1, %[[VAL_152:[0-9a-zA-Z_\.]+]] = %[[VAL_95]]#2) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_93]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_150]], %[[VAL_154]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_155]]) %[[VAL_150]], %[[VAL_151]], %[[VAL_152]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_156:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_157:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_158:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_160]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_161]]{{\[}}%[[VAL_162]]] = %[[VAL_159]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_163]][@e] = %[[VAL_161]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_158]][@idx_1] = %[[VAL_163]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_166]], %[[VAL_167]] : index
// CHECK-NEXT:              pod.write %[[VAL_164]][@count] = %[[VAL_168]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_168]], %[[VAL_169]] : index
// CHECK-NEXT:              scf.if %[[VAL_170]] {
// CHECK-NEXT:                %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_174:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_172]], %[[VAL_173]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_164]][@comp] = %[[VAL_174]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_157]][@idx_1] = %[[VAL_164]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_156]], %[[VAL_175]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_176]], %[[VAL_157]], %[[VAL_158]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_80]], %[[VAL_177]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]]:4 = scf.if %[[VAL_178]] -> (!array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:              %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_183]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_182]]{{\[}}%[[VAL_184]]] = %[[VAL_180]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_185]][@base] = %[[VAL_182]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_149]]#2[@idx_0] = %[[VAL_185]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_188]], %[[VAL_189]] : index
// CHECK-NEXT:              pod.write %[[VAL_186]][@count] = %[[VAL_190]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_190]], %[[VAL_191]] : index
// CHECK-NEXT:              scf.if %[[VAL_192]] {
// CHECK-NEXT:                %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_196:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_194]], %[[VAL_195]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_186]][@comp] = %[[VAL_196]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_149]]#1[@idx_0] = %[[VAL_186]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:              %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_201:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_200]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_199]]{{\[}}%[[VAL_201]]] = %[[VAL_197]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_202]][@base] = %[[VAL_199]] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_149]]#2[@idx_0] = %[[VAL_202]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_203]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_207:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_205]], %[[VAL_206]] : index
// CHECK-NEXT:              pod.write %[[VAL_203]][@count] = %[[VAL_207]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_207]], %[[VAL_208]] : index
// CHECK-NEXT:              scf.if %[[VAL_209]] {
// CHECK-NEXT:                %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_203]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_213:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_0::@SegmentMulFix_0::@compute(%[[VAL_211]], %[[VAL_212]]) : (!array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_203]][@comp] = %[[VAL_213]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_149]]#1[@idx_0] = %[[VAL_203]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              scf.yield %[[VAL_78]], %[[VAL_79]], %[[VAL_149]]#1, %[[VAL_149]]#2 : !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_216:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_215]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_218:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_219:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_216]]{{\[}}%[[VAL_218]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_221:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_222:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_221]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_222]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_224]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_223]]{{\[}}%[[VAL_225]]] = %[[VAL_219]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_226]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_227]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_228]][@in] = %[[VAL_223]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_79]]{{\[}}%[[VAL_230]]] = %[[VAL_228]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_231]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_232]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_235]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@count] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_237]], %[[VAL_238]] : index
// CHECK-NEXT:              pod.write %[[VAL_233]][@count] = %[[VAL_239]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_239]], %[[VAL_240]] : index
// CHECK-NEXT:              scf.if %[[VAL_241]] {
// CHECK-NEXT:                %[[VAL_242:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@params] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_243:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_236]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_244:[0-9a-zA-Z_\.]+]] = function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@compute(%[[VAL_243]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                pod.write %[[VAL_233]][@comp] = %[[VAL_244]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_245]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_78]]{{\[}}%[[VAL_246]]] = %[[VAL_233]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_249:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_248]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_250]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_251]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_254]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_255]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_257]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_256]]{{\[}}%[[VAL_258]]] = %[[VAL_252]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_260:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_259]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_261:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_260]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_261]][@in] = %[[VAL_256]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_263:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_262]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_79]]{{\[}}%[[VAL_263]]] = %[[VAL_261]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_264:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_266:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_265]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_267:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_268:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_267]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_269:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_268]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@count] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_270]], %[[VAL_271]] : index
// CHECK-NEXT:              pod.write %[[VAL_266]][@count] = %[[VAL_272]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_274:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_272]], %[[VAL_273]] : index
// CHECK-NEXT:              scf.if %[[VAL_274]] {
// CHECK-NEXT:                %[[VAL_275:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@params] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_269]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_277:[0-9a-zA-Z_\.]+]] = function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@compute(%[[VAL_276]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:                pod.write %[[VAL_266]][@comp] = %[[VAL_277]] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_278:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_279:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_278]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_78]]{{\[}}%[[VAL_279]]] = %[[VAL_266]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_281:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_280]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_282:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_281]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_283:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_282]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_284:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_283]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_285:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_286:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_287:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_284]]{{\[}}%[[VAL_286]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_288:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_288]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_290]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_289]]{{\[}}%[[VAL_291]]] = %[[VAL_287]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_292]][@base] = %[[VAL_289]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_149]]#2[@idx_1] = %[[VAL_292]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_293]][@count] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_296:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_295]], %[[VAL_296]] : index
// CHECK-NEXT:              pod.write %[[VAL_293]][@count] = %[[VAL_297]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_299:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_297]], %[[VAL_298]] : index
// CHECK-NEXT:              scf.if %[[VAL_299]] {
// CHECK-NEXT:                %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_293]][@params] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_294]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_302:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_294]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_303:[0-9a-zA-Z_\.]+]] = function.call @SegmentMulFix_1::@SegmentMulFix_1::@compute(%[[VAL_301]], %[[VAL_302]]) : (!array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_293]][@comp] = %[[VAL_303]] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              pod.write %[[VAL_149]]#1[@idx_1] = %[[VAL_293]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_304:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_305:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_304]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_306:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_305]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_307:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_306]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_308:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_307]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_310:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_309]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_308]]{{\[}}%[[VAL_310]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_312]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_314:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_315:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_314]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_313]]{{\[}}%[[VAL_315]]] = %[[VAL_311]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_316:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_316]][@base] = %[[VAL_313]] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              pod.write %[[VAL_149]]#2[@idx_1] = %[[VAL_316]] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]]#2[@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
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
// CHECK-NEXT:              pod.write %[[VAL_149]]#1[@idx_1] = %[[VAL_317]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              scf.yield %[[VAL_78]], %[[VAL_79]], %[[VAL_149]]#1, %[[VAL_149]]#2 : !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_80]], %[[VAL_328]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_179]]#0, %[[VAL_179]]#1, %[[VAL_329]], %[[VAL_179]]#2, %[[VAL_179]]#3 : !array.type<1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_48]][@m2e$inputs] = %[[VAL_70]]#1 : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_333:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_334:[0-9a-zA-Z_\.]+]] = %[[VAL_332]] to %[[VAL_331]] step %[[VAL_333]] {
// CHECK-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]#0{{\[}}%[[VAL_334]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_336:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_335]][@comp] : <[@count: index, @comp: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:            array.write %[[VAL_330]]{{\[}}%[[VAL_334]]] = %[[VAL_336]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_48]][@m2e] = %[[VAL_330]] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_48]][@segments$inputs] = %[[VAL_70]]#4 : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_337:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]]#3[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_338:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_337]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]]#3[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_340:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_339]][@comp] : <[@count: index, @comp: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_341:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_338]], @idx_1 = %[[VAL_340]] }  : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_48]][@segments] = %[[VAL_341]] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_48]] : !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_342:[0-9a-zA-Z_\.]+]]: !struct.type<@EscalarMulFix_3::@EscalarMulFix_3<[]>>, %[[VAL_343:[0-9a-zA-Z_\.]+]]: !array.type<253 x !felt.type<"bn128">> {function.arg_name = "emfIn"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_344:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_342]][@m2e] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>
// CHECK-NEXT:          %[[VAL_345:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_342]][@m2e$inputs] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !array.type<1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_342]][@segments] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>
// CHECK-NEXT:          %[[VAL_347:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_342]][@segments$inputs] : <@EscalarMulFix_3::@EscalarMulFix_3<[]>>, !pod.type<[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_348:[0-9a-zA-Z_\.]+]] = global.read const @global::@vcp_array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]] = felt.const  253 : <"bn128">
// CHECK-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_354:[0-9a-zA-Z_\.]+]] = %[[VAL_352]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_355:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_356:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_354]], %[[VAL_355]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_356]]) %[[VAL_354]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_357:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_358:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_359:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_357]], %[[VAL_358]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_359]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_361:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_361]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_362:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_362]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_363:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_364:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_360]], %[[VAL_363]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_365:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_366:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_364]], %[[VAL_365]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_368:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_366]], %[[VAL_367]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_369:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_370:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_371:[0-9a-zA-Z_\.]+]] = %[[VAL_369]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_372:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_371]], %[[VAL_360]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_372]]) %[[VAL_371]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_373:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.const  249 : <"bn128">
// CHECK-NEXT:              %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_357]], %[[VAL_374]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_376:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_375]], %[[VAL_373]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_377:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_376]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_378:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_343]]{{\[}}%[[VAL_377]]] : <253 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_379:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_357]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_380:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_381:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_382:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_379]], %[[VAL_381]] : index
// CHECK-NEXT:              %[[VAL_383:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_380]], %[[VAL_382]] : i1, i1
// CHECK-NEXT:              %[[VAL_384:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_385:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_379]], %[[VAL_384]] : index
// CHECK-NEXT:              %[[VAL_386:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_380]], %[[VAL_385]] : i1, i1
// CHECK-NEXT:              scf.execute_region {
// CHECK-NEXT:                scf.if %[[VAL_386]] {
// CHECK-NEXT:                  %[[VAL_387:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_388:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_387]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_389:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_373]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_390:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_388]]{{\[}}%[[VAL_389]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_390]], %[[VAL_378]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  scf.if %[[VAL_383]] {
// CHECK-NEXT:                    %[[VAL_391:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_392:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_391]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_393:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_373]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_394:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_392]]{{\[}}%[[VAL_393]]] : <249 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    constrain.eq %[[VAL_394]], %[[VAL_378]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                  }
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_395:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_373]], %[[VAL_395]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_396]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_397:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_398:[0-9a-zA-Z_\.]+]] = %[[VAL_360]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_399:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_400:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_368]], %[[VAL_399]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_401:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_398]], %[[VAL_400]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_401]]) %[[VAL_398]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_402:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_403:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_404:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_405:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_404]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_406:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_402]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_407:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_405]]{{\[}}%[[VAL_406]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_407]], %[[VAL_403]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_408:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_409:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_402]], %[[VAL_408]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_409]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_410:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_411:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_357]], %[[VAL_410]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_411]] {
// CHECK-NEXT:              %[[VAL_412:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:              %[[VAL_413:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_414:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_413]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_415:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_416:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_415]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_417:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_414]]{{\[}}%[[VAL_416]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_417]], %[[VAL_412]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_418:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:              %[[VAL_419:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_420:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_419]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_421:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_422:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_421]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_423:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_420]]{{\[}}%[[VAL_422]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_423]], %[[VAL_418]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_424:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_346]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_425:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_424]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_426:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_427:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_426]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_428:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_425]]{{\[}}%[[VAL_427]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_429:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_430:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_429]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_431:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_345]]{{\[}}%[[VAL_430]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_432:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_431]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_433:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_434:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_433]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_435:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_432]]{{\[}}%[[VAL_434]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_435]], %[[VAL_428]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_436:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_346]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:              %[[VAL_437:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_436]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_438:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_439:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_438]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_440:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_437]]{{\[}}%[[VAL_439]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_441:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_442:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_441]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_443:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_345]]{{\[}}%[[VAL_442]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_444:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_443]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_445:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_446:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_445]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_447:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_444]]{{\[}}%[[VAL_446]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_447]], %[[VAL_440]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_448:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_449:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_448]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_450:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_344]]{{\[}}%[[VAL_449]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_451:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_450]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_452:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_453:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_452]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_454:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_451]]{{\[}}%[[VAL_453]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_455:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_456:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_455]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_457:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_458:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_457]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_459:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_456]]{{\[}}%[[VAL_458]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_459]], %[[VAL_454]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_460:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_461:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_460]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_462:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_344]]{{\[}}%[[VAL_461]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:              %[[VAL_463:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_462]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_464:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_465:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_464]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_466:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_463]]{{\[}}%[[VAL_465]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_467:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_468:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_467]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_469:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_470:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_469]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_471:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_468]]{{\[}}%[[VAL_470]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_471]], %[[VAL_466]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_472:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_473:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_357]], %[[VAL_472]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_473]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_474:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_475:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_476:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_477:[0-9a-zA-Z_\.]+]] = %[[VAL_475]] to %[[VAL_474]] step %[[VAL_476]] {
// CHECK-NEXT:            %[[VAL_478:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_344]]{{\[}}%[[VAL_477]]] : <1 x !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>>, !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:            %[[VAL_479:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_345]]{{\[}}%[[VAL_477]]] : <1 x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_480:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_479]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Montgomery2Edwards_2::@Montgomery2Edwards_2::@constrain(%[[VAL_478]], %[[VAL_480]]) : (!struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_481:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_346]][@idx_0] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_482:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_0] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_483:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_482]][@e] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<249 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_484:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_482]][@base] : <[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @SegmentMulFix_0::@SegmentMulFix_0::@constrain(%[[VAL_481]], %[[VAL_483]], %[[VAL_484]]) : (!struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<249 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_485:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_346]][@idx_1] : <[@idx_0: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, @idx_1: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>]>, !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_486:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_347]][@idx_1] : <[@idx_0: !pod.type<[@e: !array.type<249 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_487:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_486]][@e] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_488:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_486]][@base] : <[@e: !array.type<6 x !felt.type<"bn128">>, @base: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @SegmentMulFix_1::@SegmentMulFix_1::@constrain(%[[VAL_485]], %[[VAL_487]], %[[VAL_488]]) : (!struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, !array.type<6 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Montgomery2Edwards_2 {
// CHECK-NEXT:      struct.def @Montgomery2Edwards_2 {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_489:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_490:[0-9a-zA-Z_\.]+]] = struct.new : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:          function.return %[[VAL_490]] : !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_491:[0-9a-zA-Z_\.]+]]: !struct.type<@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, %[[VAL_492:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_493:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_491]][@out] : <@Montgomery2Edwards_2::@Montgomery2Edwards_2<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SegmentMulFix_0 {
// CHECK-NEXT:      struct.def @SegmentMulFix_0 {
// CHECK-NEXT:        struct.member @dbl : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_494:[0-9a-zA-Z_\.]+]]: !array.type<249 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_495:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) -> !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_496:[0-9a-zA-Z_\.]+]] = struct.new : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:          %[[VAL_497:[0-9a-zA-Z_\.]+]] = felt.const  83 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_496]] : !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_498:[0-9a-zA-Z_\.]+]]: !struct.type<@SegmentMulFix_0::@SegmentMulFix_0<[]>>, %[[VAL_499:[0-9a-zA-Z_\.]+]]: !array.type<249 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_500:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_501:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_498]][@dbl] : <@SegmentMulFix_0::@SegmentMulFix_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_502:[0-9a-zA-Z_\.]+]] = felt.const  83 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SegmentMulFix_1 {
// CHECK-NEXT:      struct.def @SegmentMulFix_1 {
// CHECK-NEXT:        struct.member @dbl : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_503:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_504:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) -> !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_505:[0-9a-zA-Z_\.]+]] = struct.new : <@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:          %[[VAL_506:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_505]] : !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_507:[0-9a-zA-Z_\.]+]]: !struct.type<@SegmentMulFix_1::@SegmentMulFix_1<[]>>, %[[VAL_508:[0-9a-zA-Z_\.]+]]: !array.type<6 x !felt.type<"bn128">> {function.arg_name = "e"}, %[[VAL_509:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_510:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_507]][@dbl] : <@SegmentMulFix_1::@SegmentMulFix_1<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_511:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
