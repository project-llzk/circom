// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Literal, template-parameter, and constant-tag conditions preserve tag values
// for both component and local bus layouts.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main(N) {
    Tagged() left;
    Tagged() right;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;

    Tagged() zero;
    if (0) { zero <-- left; }
    else { zero <-- right; }
    Tagged() one;
    if (1) { one <-- left; }
    else { one <-- right; }
    Tagged() param;
    if (N != 0) { param <-- left; }
    else { param <-- right; }
    Tagged() tag;
    if (left.x.size == 2) { tag <-- left; }
    else { tag <-- right; }

    component fromZero = Expand();
    component fromOne = Expand();
    component fromParam = Expand();
    component fromTag = Expand();
    fromZero.in <== zero;
    fromOne.in <== one;
    fromParam.in <== param;
    fromTag.in <== tag;
    signal output out;
    out <== fromZero.out.x[0] + fromOne.out.x[0] + fromParam.out.x[0] + fromTag.out.x[0];

    Vec(zero.x.size) output localZero;
    Vec(one.x.size) output localOne;
    Vec(param.x.size) output localParam;
    Vec(tag.x.size) output localTag;
    for (var i = 0; i < zero.x.size; i++) { localZero.x[i] <== zero.x; }
    for (var i = 0; i < one.x.size; i++) { localOne.x[i] <== one.x; }
    for (var i = 0; i < param.x.size; i++) { localParam.x[i] <== param.x; }
    for (var i = 0; i < tag.x.size; i++) { localTag.x[i] <== tag.x; }
}

component main = Main(1);

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@"$bus_entry"<[1, 2]>>} {
// TEMPLATED-NEXT:    poly.template @Expand {
// TEMPLATED-NEXT:      poly.param @"$tag$in$x$size" : index
// TEMPLATED-NEXT:      struct.def @Expand {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand::@Expand<[@"$tag$in$x$size"]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : index
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_.-]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_8:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_10:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_0]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_11:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_4]][@x] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_12:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_13:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_12]]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_12]]] = %[[VAL_10]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_4]][@x] = %[[VAL_11]] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_14:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_15:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_9]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_15]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@Expand::@Expand<[@"$tag$in$x$size"]>>, !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand::@Expand<[@"$tag$in$x$size"]>>, %[[VAL_17:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = poly.read_const @"$tag$in$x$size" : index
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_18]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_16]][@out] : <@Expand::@Expand<[@"$tag$in$x$size"]>>, !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_23:[0-9a-zA-Z_.-]+]] = %[[VAL_21]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_23]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_23]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_17]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_20]][@x] : <[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>, !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_28]]] : <@"$tag$in$x$size" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_29]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_30:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_31:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_25]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_31]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      poly.param @N
// TEMPLATED-NEXT:      poly.param @"$layout$((N_NotEq_0)?2:3)" : index
// TEMPLATED-NEXT:      poly.expr @"N_NotEq_0?2:3@[[OFFSET0:[0-9]+]]" {
// TEMPLATED-NEXT:        %[[VAL_32:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:        %[[VAL_33:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:        %[[VAL_34:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:        %[[VAL_35:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$((N_NotEq_0)?2:3)" : index
// TEMPLATED-NEXT:        %[[VAL_36:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_35]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_37:[0-9a-zA-Z_.-]+]] = poly.read_const @N : !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_38:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_37]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:        %[[VAL_39:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_38]], %[[VAL_33]], %[[VAL_34]] : !felt.type<"bn128">
// TEMPLATED-NEXT:        poly.yield %[[VAL_39]] : !felt.type<"bn128">
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @left : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @right : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @zero : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @one : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @param : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @tag : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @localZero : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @localOne : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @localParam : !pod.type<[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @localTag : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @fromOne : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:        struct.member @fromOne$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        struct.member @fromParam : !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED-NEXT:        struct.member @fromParam$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        struct.member @fromTag : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:        struct.member @fromTag$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        struct.member @fromZero : !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED-NEXT:        struct.member @fromZero$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$((N_NotEq_0)?2:3)" : index
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_41]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_.-]+]] = poly.read_const @N : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_.-]+]] = poly.read_const @"N_NotEq_0?2:3@[[OFFSET0]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_45]][@x] = %[[VAL_55]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_50]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_50]][@x] = %[[VAL_57]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@zero] = %[[VAL_50]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@one] = %[[VAL_45]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_43]], %[[VAL_59]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_60]] -> (!pod.type<[@x: !felt.type<"bn128">]>) {
// TEMPLATED-NEXT:            struct.writem %[[VAL_40]][@param] = %[[VAL_45]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_45]] : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:            struct.writem %[[VAL_40]][@param] = %[[VAL_50]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:            scf.yield %[[VAL_50]] : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@tag] = %[[VAL_45]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_62]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_64]], @params = %[[VAL_63]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_66]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_68]], @params = %[[VAL_67]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = poly.read_const @"N_NotEq_0?2:3@[[OFFSET0]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_70]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_72]], @params = %[[VAL_71]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = pod.new { @"$tag$in$x$size" = %[[VAL_74]] }  : <[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_76]], @params = %[[VAL_75]] }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_54]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_54]][@in] = %[[VAL_50]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_79]], %[[VAL_80]] : index
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_81]], %[[VAL_82]], %[[VAL_80]] : index
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_83]], %[[VAL_84]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_85]] {
// TEMPLATED-NEXT:            %[[VAL_86:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_86]], %[[VAL_87]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_65]][@count] = %[[VAL_88]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_89:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_90:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_88]], %[[VAL_89]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_90]] {
// TEMPLATED-NEXT:              %[[VAL_91:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_92:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_54]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_93:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_92]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_65]][@comp] = %[[VAL_93]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_51]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_51]][@in] = %[[VAL_45]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_95]], %[[VAL_96]] : index
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_97]], %[[VAL_98]], %[[VAL_96]] : index
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_99]], %[[VAL_100]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_101]] {
// TEMPLATED-NEXT:            %[[VAL_102:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_103:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_104:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_102]], %[[VAL_103]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_69]][@count] = %[[VAL_104]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_105:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_106:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_104]], %[[VAL_105]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_106]] {
// TEMPLATED-NEXT:              %[[VAL_107:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_108:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_51]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_109:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_108]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_69]][@comp] = %[[VAL_109]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_52]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_52]][@in] = %[[VAL_61]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_111]], %[[VAL_112]] : index
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_113]], %[[VAL_114]], %[[VAL_112]] : index
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_117:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_115]], %[[VAL_116]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_117]] {
// TEMPLATED-NEXT:            %[[VAL_118:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_119:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_120:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_118]], %[[VAL_119]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_73]][@count] = %[[VAL_120]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_121:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_122:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_120]], %[[VAL_121]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_122]] {
// TEMPLATED-NEXT:              %[[VAL_123:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_124:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_52]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_125:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_124]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_73]][@comp] = %[[VAL_125]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_53]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_53]][@in] = %[[VAL_45]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_127]], %[[VAL_128]] : index
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_129]], %[[VAL_130]], %[[VAL_128]] : index
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_131]], %[[VAL_132]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_133]] {
// TEMPLATED-NEXT:            %[[VAL_134:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@count] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_135:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:            %[[VAL_136:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_134]], %[[VAL_135]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_77]][@count] = %[[VAL_136]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_137:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_138:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_136]], %[[VAL_137]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_138]] {
// TEMPLATED-NEXT:              %[[VAL_139:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@params] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_140:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_53]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_141:[0-9a-zA-Z_.-]+]] = function.call @Expand::@Expand::@compute(%[[VAL_140]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_77]][@comp] = %[[VAL_141]] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_142]][@out] : <@Expand::@Expand<[3]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_144:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_143]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_145:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_144]]{{\[}}%[[VAL_146]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_148]][@out] : <@Expand::@Expand<[2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_149]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_151]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_150]]{{\[}}%[[VAL_152]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_147]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_155]][@out] : <@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_156]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_158:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_157]]{{\[}}%[[VAL_159]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_154]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_162]][@out] : <@Expand::@Expand<[2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_163]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_165]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_164]]{{\[}}%[[VAL_166]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_168:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_161]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@out] = %[[VAL_168]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_169:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_171:[0-9a-zA-Z_.-]+]] = %[[VAL_169]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_172:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_173:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_171]], %[[VAL_172]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_173]]) %[[VAL_171]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_174:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_175:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_50]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_176:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_49]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_177:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_174]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_178:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_176]]{{\[}}%[[VAL_177]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_176]]{{\[}}%[[VAL_177]]] = %[[VAL_175]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_49]][@x] = %[[VAL_176]] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_179:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_180:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_174]], %[[VAL_179]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_180]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_181:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_183:[0-9a-zA-Z_.-]+]] = %[[VAL_181]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_184:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_185:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_183]], %[[VAL_184]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_185]]) %[[VAL_183]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_186:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_187:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_188:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_46]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_189:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_186]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_190:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_188]]{{\[}}%[[VAL_189]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_188]]{{\[}}%[[VAL_189]]] = %[[VAL_187]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_46]][@x] = %[[VAL_188]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_191:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_192:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_186]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_192]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_195:[0-9a-zA-Z_.-]+]] = %[[VAL_193]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_196:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_197:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_43]], %[[VAL_196]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_198:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_197]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:              %[[VAL_199:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_199]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_200:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_200]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_201:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_195]], %[[VAL_198]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_201]]) %[[VAL_195]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_202:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_203:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_61]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_204:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_47]][@x] : <[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_205:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_206:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_204]]{{\[}}%[[VAL_205]]] : <@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_204]]{{\[}}%[[VAL_205]]] = %[[VAL_203]] : <@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_47]][@x] = %[[VAL_204]] : <[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_207:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_208:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_202]], %[[VAL_207]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_208]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_209:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_211:[0-9a-zA-Z_.-]+]] = %[[VAL_209]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_212:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_213:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_211]], %[[VAL_212]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_213]]) %[[VAL_211]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_214:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_215:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_45]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_216:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_48]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_217:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_218:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_216]]{{\[}}%[[VAL_217]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_216]]{{\[}}%[[VAL_217]]] = %[[VAL_215]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_48]][@x] = %[[VAL_216]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_219:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_220:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_214]], %[[VAL_219]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_220]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@fromOne$inputs] = %[[VAL_51]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_221:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@fromOne] = %[[VAL_221]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@fromParam$inputs] = %[[VAL_52]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_222:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@fromParam] = %[[VAL_222]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@fromTag$inputs] = %[[VAL_53]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_223:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@fromTag] = %[[VAL_223]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@fromZero$inputs] = %[[VAL_54]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_224:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@comp] : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>, !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@fromZero] = %[[VAL_224]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@left] = %[[VAL_45]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@right] = %[[VAL_50]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@localZero] = %[[VAL_49]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@localOne] = %[[VAL_46]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@localParam] = %[[VAL_47]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_40]][@localTag] = %[[VAL_48]] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_40]] : !struct.type<@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_225:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_226:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$((N_NotEq_0)?2:3)" : index
// TEMPLATED-NEXT:          %[[VAL_227:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_226]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_228:[0-9a-zA-Z_.-]+]] = poly.read_const @N : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_.-]+]] = poly.read_const @"N_NotEq_0?2:3@[[OFFSET0]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@left] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@right] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@zero] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@one] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@param] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@tag] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_236:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@out] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_237:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@localZero] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_238:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@localOne] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_239:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@localParam] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_240:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@localTag] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_241:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@fromOne] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          %[[VAL_242:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@fromOne$inputs] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_243:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@fromParam] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED-NEXT:          %[[VAL_244:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@fromParam$inputs] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_245:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@fromTag] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED-NEXT:          %[[VAL_246:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@fromTag$inputs] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_247:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@fromZero] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED-NEXT:          %[[VAL_248:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_225]][@fromZero$inputs] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_249:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_250:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_230]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_250]], %[[VAL_249]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_251:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_252:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_231]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_252]], %[[VAL_251]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_253:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_254:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_228]], %[[VAL_253]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          scf.if %[[VAL_254]] {
// TEMPLATED-NEXT:          } else {
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_255:[0-9a-zA-Z_.-]+]] = poly.read_const @"N_NotEq_0?2:3@[[OFFSET0]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_256:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_248]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_257:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_256]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_258:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_232]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_257]], %[[VAL_258]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_259:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_242]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_260:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_259]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_261:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_233]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_260]], %[[VAL_261]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_262:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_244]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_263:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_262]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_264:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_234]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_263]], %[[VAL_264]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_265:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_246]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_266:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_265]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_267:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_235]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_266]], %[[VAL_267]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_268:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_247]][@out] : <@Expand::@Expand<[3]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_269:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_268]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_270:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_271:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_270]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_272:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_271]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_273:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_241]][@out] : <@Expand::@Expand<[2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_274:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_273]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_275:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_276:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_275]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_277:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_274]]{{\[}}%[[VAL_276]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_278:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_272]], %[[VAL_277]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_279:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_243]][@out] : <@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_280:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_279]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_281:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_282:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_281]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_283:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_280]]{{\[}}%[[VAL_282]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_284:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_278]], %[[VAL_283]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_285:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_245]][@out] : <@Expand::@Expand<[2]>>, !pod.type<[@x: !array.type<? x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_286:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_285]][@x] : <[@x: !array.type<? x !felt.type<"bn128">>]>, !array.type<? x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_287:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_288:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_287]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_289:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_286]]{{\[}}%[[VAL_288]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_290:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_284]], %[[VAL_289]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_236]], %[[VAL_290]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_291:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_292:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_293:[0-9a-zA-Z_.-]+]] = %[[VAL_291]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_294:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_295:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_293]], %[[VAL_294]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_295]]) %[[VAL_293]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_296:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_297:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_232]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_298:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_237]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_299:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_296]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_300:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_298]]{{\[}}%[[VAL_299]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_300]], %[[VAL_297]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_301:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_302:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_296]], %[[VAL_301]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_302]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_303:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_304:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_305:[0-9a-zA-Z_.-]+]] = %[[VAL_303]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_306:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_307:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_305]], %[[VAL_306]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_307]]) %[[VAL_305]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_308:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_309:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_233]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_310:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_238]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_311:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_308]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_312:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_310]]{{\[}}%[[VAL_311]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_312]], %[[VAL_309]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_313:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_314:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_308]], %[[VAL_313]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_314]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_315:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_316:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_317:[0-9a-zA-Z_.-]+]] = %[[VAL_315]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_318:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_319:[0-9a-zA-Z_.-]+]] = bool.cmp ne(%[[VAL_228]], %[[VAL_318]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_320:[0-9a-zA-Z_.-]+]] = scf.if %[[VAL_319]] -> (!felt.type<"bn128">) {
// TEMPLATED-NEXT:              %[[VAL_321:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_321]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } else {
// TEMPLATED-NEXT:              %[[VAL_322:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_322]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_323:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_317]], %[[VAL_320]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_323]]) %[[VAL_317]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_324:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_325:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_234]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_326:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_239]][@x] : <[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_327:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_324]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_328:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_326]]{{\[}}%[[VAL_327]]] : <@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_328]], %[[VAL_325]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_329:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_330:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_324]], %[[VAL_329]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_330]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_331:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_332:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_333:[0-9a-zA-Z_.-]+]] = %[[VAL_331]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_334:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_335:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_333]], %[[VAL_334]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_335]]) %[[VAL_333]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_336:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_337:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_235]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_338:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_240]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_339:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_336]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_340:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_338]]{{\[}}%[[VAL_339]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_340]], %[[VAL_337]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_341:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_342:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_336]], %[[VAL_341]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_342]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_343:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_242]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @Expand::@Expand::@constrain(%[[VAL_241]], %[[VAL_343]]) : (!struct.type<@Expand::@Expand<[2]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_344:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_244]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @Expand::@Expand::@constrain(%[[VAL_243]], %[[VAL_344]]) : (!struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_345:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_246]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @Expand::@Expand::@constrain(%[[VAL_245]], %[[VAL_345]]) : (!struct.type<@Expand::@Expand<[2]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_346:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_248]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @Expand::@Expand::@constrain(%[[VAL_247]], %[[VAL_346]]) : (!struct.type<@Expand::@Expand<[3]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @localZero.x : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @localOne.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @localParam.x : !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @localTag.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute() -> !struct.type<@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_347:[0-9a-zA-Z_.-]+]] = struct.new : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>
// TEMPLATED-NEXT:          %[[VAL_348:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$((N_NotEq_0)?2:3)" : index
// TEMPLATED-NEXT:          %[[VAL_349:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_348]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_350:[0-9a-zA-Z_.-]+]] = poly.read_const @N : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_351:[0-9a-zA-Z_.-]+]] = poly.read_const @"N_NotEq_0?2:3@[[OFFSET0]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_352:[0-9a-zA-Z_.-]+]] = function.call @Main::@Main::@compute() : () -> !struct.type<@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_347]][@"$component"] = %[[VAL_352]] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>
// TEMPLATED-NEXT:          %[[VAL_353:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@out] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_354:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@localZero] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_355:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_354]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_356:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@localOne] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_357:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_356]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_358:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@localParam] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_359:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_358]][@x] : <[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_360:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@localTag] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_361:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_360]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_347]][@out] = %[[VAL_353]] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_347]][@localZero.x] = %[[VAL_355]] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_347]][@localOne.x] = %[[VAL_357]] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_347]][@localParam.x] = %[[VAL_359]] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_347]][@localTag.x] = %[[VAL_361]] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_347]] : !struct.type<@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_362:[0-9a-zA-Z_.-]+]]: !struct.type<@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_363:[0-9a-zA-Z_.-]+]] = poly.read_const @"$layout$((N_NotEq_0)?2:3)" : index
// TEMPLATED-NEXT:          %[[VAL_364:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_363]] : index, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_365:[0-9a-zA-Z_.-]+]] = poly.read_const @N : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_366:[0-9a-zA-Z_.-]+]] = poly.read_const @"N_NotEq_0?2:3@[[OFFSET0]]" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_367:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_362]][@"$component"] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !struct.type<@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>
// TEMPLATED-NEXT:          function.call @Main::@Main::@constrain(%[[VAL_367]]) : (!struct.type<@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>) -> ()
// TEMPLATED-NEXT:          %[[VAL_368:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_362]][@out] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_369:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_362]][@localZero.x] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_370:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_362]][@localOne.x] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_371:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_362]][@localParam.x] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_372:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_362]][@localTag.x] : <@Main::@"$bus_entry"<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_373:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_367]][@out] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_373]], %[[VAL_368]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_374:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_367]][@localZero] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_375:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_369]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_376:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_374]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_377:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_375]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_376]], %[[VAL_377]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_378:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_367]][@localOne] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_379:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_370]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_380:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_378]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_381:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_379]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_380]], %[[VAL_381]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_382:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_367]][@localParam] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_383:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_371]] }  : <[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_384:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_382]][@x] : <[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_385:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_383]][@x] : <[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_384]], %[[VAL_385]] : !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>, !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_386:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_367]][@localTag] : <@Main::@Main<[@N, @"$layout$((N_NotEq_0)?2:3)"]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_387:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_372]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_388:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_386]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_389:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_387]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_388]], %[[VAL_389]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_2::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @Expand_0 {
// CONCRETE-NEXT:      struct.def @Expand_0 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Expand_0::@Expand_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_5:[0-9a-zA-Z_.-]+]] = %[[VAL_3]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_6:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_7:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_5]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_5]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_9:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_0]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_10:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_2]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_11:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_12:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_11]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_10]]{{\[}}%[[VAL_11]]] = %[[VAL_9]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_2]][@x] = %[[VAL_10]] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_13:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_14:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_8]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_14]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_15:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand_0::@Expand_0<[]>>, %[[VAL_16:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_15]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_20:[0-9a-zA-Z_.-]+]] = %[[VAL_18]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_21:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_22]]) %[[VAL_20]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_23:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_24:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_16]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_17]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_26]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_27]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_28:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_23]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_29]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Expand_1 {
// CONCRETE-NEXT:      struct.def @Expand_1 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_30:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@Expand_1::@Expand_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_.-]+]] = struct.new : <@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_35:[0-9a-zA-Z_.-]+]] = %[[VAL_33]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_35]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_37]]) %[[VAL_35]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_38:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_39:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_30]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_40:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_32]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_41:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_42:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_40]]{{\[}}%[[VAL_41]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_40]]{{\[}}%[[VAL_41]]] = %[[VAL_39]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_32]][@x] = %[[VAL_40]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_43:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_44:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_38]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_44]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_31]][@out] = %[[VAL_32]] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_31]] : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_45:[0-9a-zA-Z_.-]+]]: !struct.type<@Expand_1::@Expand_1<[]>>, %[[VAL_46:[0-9a-zA-Z_.-]+]]: !pod.type<[@x: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_45]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_50:[0-9a-zA-Z_.-]+]] = %[[VAL_48]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_51:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_52:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_50]], %[[VAL_51]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_52]]) %[[VAL_50]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_53:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_54:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_46]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_55:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_47]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_56:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_57:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_56]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_57]], %[[VAL_54]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_58:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_59:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_53]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_59]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Main_2 {
// CONCRETE-NEXT:      struct.def @Main_2 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @localZero : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @localOne : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @localParam : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @localTag : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @left : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @right : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @zero : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @one : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @param : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @tag : !pod.type<[@x: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @fromOne : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:        struct.member @fromOne$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        struct.member @fromParam : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:        struct.member @fromParam$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        struct.member @fromTag : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:        struct.member @fromTag$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        struct.member @fromZero : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:        struct.member @fromZero$inputs : !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Main_2::@Main_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_68]], @params = %[[VAL_67]] }  : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_72]], @params = %[[VAL_71]] }  : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_76]], @params = %[[VAL_75]] }  : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_.-]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_80]], @params = %[[VAL_79]] }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_.-]+]] = pod.new : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_61]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_61]][@x] = %[[VAL_83]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_66]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_66]][@x] = %[[VAL_85]] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@zero] = %[[VAL_66]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@one] = %[[VAL_61]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@param] = %[[VAL_61]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@tag] = %[[VAL_61]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_82]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_82]][@in] = %[[VAL_66]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_81]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_88]], %[[VAL_89]] : index
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_90]], %[[VAL_91]], %[[VAL_89]] : index
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_92]], %[[VAL_93]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_94]] {
// CONCRETE-NEXT:            %[[VAL_95:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_81]][@count] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_96:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_97:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_95]], %[[VAL_96]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_81]][@count] = %[[VAL_97]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_98:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_99:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_97]], %[[VAL_98]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_99]] {
// CONCRETE-NEXT:              %[[VAL_100:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_81]][@params] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_101:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_82]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_102:[0-9a-zA-Z_.-]+]] = function.call @Expand_0::@Expand_0::@compute(%[[VAL_101]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_81]][@comp] = %[[VAL_102]] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_103:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_70]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_70]][@in] = %[[VAL_61]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_104:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@count] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_104]], %[[VAL_105]] : index
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_106]], %[[VAL_107]], %[[VAL_105]] : index
// CONCRETE-NEXT:          %[[VAL_109:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_108]], %[[VAL_109]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_110]] {
// CONCRETE-NEXT:            %[[VAL_111:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@count] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_112:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_113:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_111]], %[[VAL_112]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_69]][@count] = %[[VAL_113]] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_114:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_115:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_113]], %[[VAL_114]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_115]] {
// CONCRETE-NEXT:              %[[VAL_116:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@params] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_117:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_70]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_118:[0-9a-zA-Z_.-]+]] = function.call @Expand_1::@Expand_1::@compute(%[[VAL_117]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_69]][@comp] = %[[VAL_118]] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_74]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_74]][@in] = %[[VAL_61]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@count] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_121:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_122:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_120]], %[[VAL_121]] : index
// CONCRETE-NEXT:          %[[VAL_123:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_124:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_122]], %[[VAL_123]], %[[VAL_121]] : index
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_124]], %[[VAL_125]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_126]] {
// CONCRETE-NEXT:            %[[VAL_127:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@count] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_128:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_129:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_127]], %[[VAL_128]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_73]][@count] = %[[VAL_129]] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_130:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_131:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_129]], %[[VAL_130]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_131]] {
// CONCRETE-NEXT:              %[[VAL_132:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@params] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_133:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_74]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_134:[0-9a-zA-Z_.-]+]] = function.call @Expand_1::@Expand_1::@compute(%[[VAL_133]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_73]][@comp] = %[[VAL_134]] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_78]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_78]][@in] = %[[VAL_61]] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_136:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@count] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_136]], %[[VAL_137]] : index
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_140:[0-9a-zA-Z_.-]+]] = arith.select %[[VAL_138]], %[[VAL_139]], %[[VAL_137]] : index
// CONCRETE-NEXT:          %[[VAL_141:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_140]], %[[VAL_141]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_142]] {
// CONCRETE-NEXT:            %[[VAL_143:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@count] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_144:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE-NEXT:            %[[VAL_145:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_143]], %[[VAL_144]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_77]][@count] = %[[VAL_145]] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_146:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_147:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_145]], %[[VAL_146]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_147]] {
// CONCRETE-NEXT:              %[[VAL_148:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@params] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_149:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_78]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_150:[0-9a-zA-Z_.-]+]] = function.call @Expand_1::@Expand_1::@compute(%[[VAL_149]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_77]][@comp] = %[[VAL_150]] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_151:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_81]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_152:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_151]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_153:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_152]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_154:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_155:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_154]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_156:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_153]]{{\[}}%[[VAL_155]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_157:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@comp] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_158:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_157]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_158]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_161:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_161]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_156]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@comp] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_165:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_164]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_165]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_167:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_167]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_166]]{{\[}}%[[VAL_168]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_170:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_163]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_171:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@comp] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_172:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_171]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_173:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_172]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_174:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_175:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_174]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_176:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_173]]{{\[}}%[[VAL_175]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_177:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_170]], %[[VAL_176]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@out] = %[[VAL_177]] : <@Main_2::@Main_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_178:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_179:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_180:[0-9a-zA-Z_.-]+]] = %[[VAL_178]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_181:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_182:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_180]], %[[VAL_181]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_182]]) %[[VAL_180]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_183:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_184:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_66]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_185:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_65]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_186:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_183]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_187:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_185]]{{\[}}%[[VAL_186]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_185]]{{\[}}%[[VAL_186]]] = %[[VAL_184]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_65]][@x] = %[[VAL_185]] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_188:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_189:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_183]], %[[VAL_188]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_189]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_190:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_191:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_192:[0-9a-zA-Z_.-]+]] = %[[VAL_190]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_193:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_194:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_192]], %[[VAL_193]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_194]]) %[[VAL_192]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_195:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_196:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_61]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_197:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_62]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_198:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_195]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_199:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_197]]{{\[}}%[[VAL_198]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_197]]{{\[}}%[[VAL_198]]] = %[[VAL_196]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_62]][@x] = %[[VAL_197]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_200:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_201:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_195]], %[[VAL_200]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_201]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_202:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_203:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_204:[0-9a-zA-Z_.-]+]] = %[[VAL_202]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_205:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_206:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_204]], %[[VAL_205]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_206]]) %[[VAL_204]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_207:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_208:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_61]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_209:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_63]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_210:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_207]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_211:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_209]]{{\[}}%[[VAL_210]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_209]]{{\[}}%[[VAL_210]]] = %[[VAL_208]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_63]][@x] = %[[VAL_209]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_212:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_213:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_207]], %[[VAL_212]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_213]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_214:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_215:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_216:[0-9a-zA-Z_.-]+]] = %[[VAL_214]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_217:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_218:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_216]], %[[VAL_217]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_218]]) %[[VAL_216]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_219:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_220:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_61]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_221:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_64]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_222:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_219]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_223:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_221]]{{\[}}%[[VAL_222]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_221]]{{\[}}%[[VAL_222]]] = %[[VAL_220]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_64]][@x] = %[[VAL_221]] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_224:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_225:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_219]], %[[VAL_224]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_225]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@fromOne$inputs] = %[[VAL_70]] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_226:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_69]][@comp] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@fromOne] = %[[VAL_226]] : <@Main_2::@Main_2<[]>>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@fromParam$inputs] = %[[VAL_74]] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_227:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_73]][@comp] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@fromParam] = %[[VAL_227]] : <@Main_2::@Main_2<[]>>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@fromTag$inputs] = %[[VAL_78]] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_228:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_77]][@comp] : <[@count: index, @comp: !struct.type<@Expand_1::@Expand_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@fromTag] = %[[VAL_228]] : <@Main_2::@Main_2<[]>>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@fromZero$inputs] = %[[VAL_82]] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_229:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_81]][@comp] : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@fromZero] = %[[VAL_229]] : <@Main_2::@Main_2<[]>>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@left] = %[[VAL_61]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@right] = %[[VAL_66]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@localZero] = %[[VAL_65]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@localOne] = %[[VAL_62]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@localParam] = %[[VAL_63]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_60]][@localTag] = %[[VAL_64]] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_60]] : !struct.type<@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_230:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_2::@Main_2<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_231:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@out] : <@Main_2::@Main_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_232:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@localZero] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_233:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@localOne] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_234:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@localParam] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_235:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@localTag] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_236:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@left] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_237:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@right] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_238:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@zero] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_239:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@one] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_240:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@param] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_241:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@tag] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_242:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@fromOne] : <@Main_2::@Main_2<[]>>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_243:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@fromOne$inputs] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_244:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@fromParam] : <@Main_2::@Main_2<[]>>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_245:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@fromParam$inputs] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_246:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@fromTag] : <@Main_2::@Main_2<[]>>, !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE-NEXT:          %[[VAL_247:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@fromTag$inputs] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_248:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@fromZero] : <@Main_2::@Main_2<[]>>, !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE-NEXT:          %[[VAL_249:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_230]][@fromZero$inputs] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !pod.type<[@x: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_250:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_251:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_236]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_251]], %[[VAL_250]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_252:[0-9a-zA-Z_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_253:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_237]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_253]], %[[VAL_252]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_254:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_249]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_255:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_254]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_256:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_238]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_255]], %[[VAL_256]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_257:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_243]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_258:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_257]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_259:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_239]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_258]], %[[VAL_259]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_260:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_245]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_261:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_260]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_262:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_240]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_261]], %[[VAL_262]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_263:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_247]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_264:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_263]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_265:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_241]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_264]], %[[VAL_265]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_266:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_248]][@out] : <@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_267:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_266]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_268:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_269:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_268]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_270:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_269]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_271:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_242]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_272:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_271]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_273:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_274:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_273]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_275:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_272]]{{\[}}%[[VAL_274]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_276:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_270]], %[[VAL_275]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_277:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_244]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_278:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_277]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_279:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_280:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_279]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_281:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_280]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_282:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_276]], %[[VAL_281]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_283:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_246]][@out] : <@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_284:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_283]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_285:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_286:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_285]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_287:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_284]]{{\[}}%[[VAL_286]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_288:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_282]], %[[VAL_287]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_231]], %[[VAL_288]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_289:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_290:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_291:[0-9a-zA-Z_.-]+]] = %[[VAL_289]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_292:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_293:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_291]], %[[VAL_292]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_293]]) %[[VAL_291]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_294:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_295:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_238]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_296:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_232]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_297:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_294]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_298:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_296]]{{\[}}%[[VAL_297]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_298]], %[[VAL_295]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_299:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_300:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_294]], %[[VAL_299]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_300]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_301:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_302:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_303:[0-9a-zA-Z_.-]+]] = %[[VAL_301]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_304:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_305:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_303]], %[[VAL_304]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_305]]) %[[VAL_303]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_306:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_307:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_239]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_308:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_233]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_309:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_306]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_310:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_308]]{{\[}}%[[VAL_309]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_310]], %[[VAL_307]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_311:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_312:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_306]], %[[VAL_311]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_312]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_313:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_314:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_315:[0-9a-zA-Z_.-]+]] = %[[VAL_313]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_316:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_317:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_315]], %[[VAL_316]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_317]]) %[[VAL_315]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_318:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_319:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_240]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_320:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_234]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_321:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_318]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_322:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_320]]{{\[}}%[[VAL_321]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_322]], %[[VAL_319]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_323:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_324:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_318]], %[[VAL_323]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_324]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_325:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_326:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_327:[0-9a-zA-Z_.-]+]] = %[[VAL_325]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_328:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_329:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_327]], %[[VAL_328]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_329]]) %[[VAL_327]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_330:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_331:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_241]][@x] : <[@x: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_332:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_235]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_333:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_330]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_334:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_332]]{{\[}}%[[VAL_333]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_334]], %[[VAL_331]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_335:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_336:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_330]], %[[VAL_335]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_336]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_337:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_243]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_1::@Expand_1::@constrain(%[[VAL_242]], %[[VAL_337]]) : (!struct.type<@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_338:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_245]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_1::@Expand_1::@constrain(%[[VAL_244]], %[[VAL_338]]) : (!struct.type<@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_339:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_247]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_1::@Expand_1::@constrain(%[[VAL_246]], %[[VAL_339]]) : (!struct.type<@Expand_1::@Expand_1<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          %[[VAL_340:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_249]][@in] : <[@in: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @Expand_0::@Expand_0::@constrain(%[[VAL_248]], %[[VAL_340]]) : (!struct.type<@Expand_0::@Expand_0<[]>>, !pod.type<[@x: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @localZero.x : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @localOne.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @localParam.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @localTag.x : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute() -> !struct.type<@Main_2::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_341:[0-9a-zA-Z_.-]+]] = struct.new : <@Main_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_342:[0-9a-zA-Z_.-]+]] = function.call @Main_2::@Main_2::@compute() : () -> !struct.type<@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_341]][@"$component"] = %[[VAL_342]] : <@Main_2::@"$bus_entry"<[]>>, !struct.type<@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:          %[[VAL_343:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_342]][@out] : <@Main_2::@Main_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_344:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_342]][@localZero] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_345:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_344]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_346:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_342]][@localOne] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_347:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_346]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_348:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_342]][@localParam] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_349:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_348]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_350:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_342]][@localTag] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_351:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_350]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_341]][@out] = %[[VAL_343]] : <@Main_2::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_341]][@localZero.x] = %[[VAL_345]] : <@Main_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_341]][@localOne.x] = %[[VAL_347]] : <@Main_2::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_341]][@localParam.x] = %[[VAL_349]] : <@Main_2::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_341]][@localTag.x] = %[[VAL_351]] : <@Main_2::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_341]] : !struct.type<@Main_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_352:[0-9a-zA-Z_.-]+]]: !struct.type<@Main_2::@"$bus_entry"<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_353:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@"$component"] : <@Main_2::@"$bus_entry"<[]>>, !struct.type<@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:          function.call @Main_2::@Main_2::@constrain(%[[VAL_353]]) : (!struct.type<@Main_2::@Main_2<[]>>) -> ()
// CONCRETE-NEXT:          %[[VAL_354:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@out] : <@Main_2::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_355:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@localZero.x] : <@Main_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_356:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@localOne.x] : <@Main_2::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_357:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@localParam.x] : <@Main_2::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_358:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_352]][@localTag.x] : <@Main_2::@"$bus_entry"<[]>>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_359:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_353]][@out] : <@Main_2::@Main_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_359]], %[[VAL_354]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_360:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_353]][@localZero] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_361:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_355]] }  : <[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_362:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_360]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_363:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_361]][@x] : <[@x: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_362]], %[[VAL_363]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_364:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_353]][@localOne] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_365:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_356]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_366:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_364]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_367:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_365]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_366]], %[[VAL_367]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_368:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_353]][@localParam] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_369:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_357]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_370:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_368]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_371:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_369]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_370]], %[[VAL_371]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_372:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_353]][@localTag] : <@Main_2::@Main_2<[]>>, !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_373:[0-9a-zA-Z_.-]+]] = pod.new { @x = %[[VAL_358]] }  : <[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_374:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_372]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_375:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_373]][@x] : <[@x: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_374]], %[[VAL_375]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }
