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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@runner::@runner<[]>>} {
// CHECK-NEXT:    poly.template @InnerConditional2 {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.param @T : index
// CHECK-NEXT:      struct.def @InnerConditional2 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional2::@InnerConditional2<[@N, @T]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional2::@InnerConditional2<[@N, @T]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @T : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_9]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_10]]) %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_4]], %[[VAL_13]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_14]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_15]], %[[VAL_19]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_7]]#0 : <@InnerConditional2::@InnerConditional2<[@N, @T]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@InnerConditional2::@InnerConditional2<[@N, @T]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional2::@InnerConditional2<[@N, @T]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_21]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @T : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_23]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@out] : <@InnerConditional2::@InnerConditional2<[@N, @T]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_26]], %[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_27]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_30]], %[[VAL_22]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_31]]) %[[VAL_29]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_24]], %[[VAL_34]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_35]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_32]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_33]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_36]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @runner {
// CHECK-NEXT:      struct.def @runner {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a : !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[]>
// CHECK-NEXT:        struct.member @b : !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@runner::@runner<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.new : <@runner::@runner<[]>>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_44]], @T = %[[VAL_45]] }  : <[@N: index, @T: index]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = function.call @InnerConditional2::@InnerConditional2::@compute() : () -> !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_48]] }  : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>, @params: !pod.type<[@N: index, @T: index]>]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_50]], @T = %[[VAL_51]] }  : <[@N: index, @T: index]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = function.call @InnerConditional2::@InnerConditional2::@compute() : () -> !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_54]] }  : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>, @params: !pod.type<[@N: index, @T: index]>]>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>, @params: !pod.type<[@N: index, @T: index]>]>, !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out] : <@InnerConditional2::@InnerConditional2<[4, 0]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>, @params: !pod.type<[@N: index, @T: index]>]>, !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@out] : <@InnerConditional2::@InnerConditional2<[5, 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_57]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_41]][@out] = %[[VAL_60]] : <@runner::@runner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_41]][@a$inputs] = %[[VAL_42]] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>, @params: !pod.type<[@N: index, @T: index]>]>, !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          struct.writem %[[VAL_41]][@a] = %[[VAL_61]] : <@runner::@runner<[]>>, !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          struct.writem %[[VAL_41]][@b$inputs] = %[[VAL_43]] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>, @params: !pod.type<[@N: index, @T: index]>]>, !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          struct.writem %[[VAL_41]][@b] = %[[VAL_62]] : <@runner::@runner<[]>>, !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          function.return %[[VAL_41]] : !struct.type<@runner::@runner<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !struct.type<@runner::@runner<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@out] : <@runner::@runner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@a] : <@runner::@runner<[]>>, !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@a$inputs] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@b] : <@runner::@runner<[]>>, !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@b$inputs] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_69]], @T = %[[VAL_70]] }  : <[@N: index, @T: index]>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>, @params: !pod.type<[@N: index, @T: index]>]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_73]], @T = %[[VAL_74]] }  : <[@N: index, @T: index]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>, @params: !pod.type<[@N: index, @T: index]>]>
// CHECK-NEXT:          function.call @InnerConditional2::@InnerConditional2::@constrain(%[[VAL_65]]) : (!struct.type<@InnerConditional2::@InnerConditional2<[4, 0]>>) -> ()
// CHECK-NEXT:          function.call @InnerConditional2::@InnerConditional2::@constrain(%[[VAL_67]]) : (!struct.type<@InnerConditional2::@InnerConditional2<[5, 1]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
