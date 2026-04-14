// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional2(N, T) {
    signal output out;

    var acc = 1;
    for (var i = 1; i <= N; i++) {
        if (T == 0) {
            acc += i;
        } else {
            acc *= i;
        }
    }

    out <-- acc;
}

template runner() {
    signal output out;

    component a = InnerConditional2(4, 0);
    component b = InnerConditional2(5, 1);

    out <-- a.out + b.out;
}

component main = runner();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@runner::@runner<[]>>} {
// CHECK-NEXT:    poly.template @InnerConditional2 {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.param @T
// CHECK-NEXT:      struct.def @InnerConditional2 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional2::@InnerConditional2<[@N, @T]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional2::@InnerConditional2<[@N, @T]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @T : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_7]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_6]], %[[VAL_7]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_2]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_12]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_13]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_5]]#0 : <@InnerConditional2::@InnerConditional2<[@N, @T]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@InnerConditional2::@InnerConditional2<[@N, @T]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional2::@InnerConditional2<[@N, @T]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @T : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@out] : <@InnerConditional2::@InnerConditional2<[@N, @T]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_22]], %[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_23]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_26]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_27]]) %[[VAL_25]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_29:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_20]], %[[VAL_30]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_31]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_29]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @runner {
// CHECK-NEXT:      struct.def @runner {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @a : !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[]>
// CHECK-NEXT:        struct.member @b : !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@runner::@runner<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.new : <@runner::@runner<[]>>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @InnerConditional2::@InnerConditional2::@compute() : () -> !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_39]] }  : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = function.call @InnerConditional2::@InnerConditional2::@compute() : () -> !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_43]] }  : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>, @params: !pod.type<[]>]>, !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_46]][@out] : <@InnerConditional2::@InnerConditional2<[4, 0]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>, @params: !pod.type<[]>]>, !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@out] : <@InnerConditional2::@InnerConditional2<[5, 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_47]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_37]][@out] = %[[VAL_50]] : <@runner::@runner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_37]][@a$inputs] = %[[VAL_41]] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>, @params: !pod.type<[]>]>, !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          struct.writem %[[VAL_37]][@a] = %[[VAL_51]] : <@runner::@runner<[]>>, !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          struct.writem %[[VAL_37]][@b$inputs] = %[[VAL_45]] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>, @params: !pod.type<[]>]>, !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          struct.writem %[[VAL_37]][@b] = %[[VAL_52]] : <@runner::@runner<[]>>, !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          function.return %[[VAL_37]] : !struct.type<@runner::@runner<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !struct.type<@runner::@runner<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@out] : <@runner::@runner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@a] : <@runner::@runner<[]>>, !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@a$inputs] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@b] : <@runner::@runner<[]>>, !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@b$inputs] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          function.call @InnerConditional2::@InnerConditional2::@constrain(%[[VAL_55]]) : (!struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>) -> ()
// CHECK-NEXT:          function.call @InnerConditional2::@InnerConditional2::@constrain(%[[VAL_57]]) : (!struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
