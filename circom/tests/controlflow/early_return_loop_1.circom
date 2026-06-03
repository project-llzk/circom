// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(in) {
    for (var i = 0; i < 6; i++) {
        if (i == 0) {
            return in;
        }
        assert(0 == 1); // Unreachable because of the early return above
    }
    return -1;
}

function noEarlyReturnFn(in) {
    for (var i = 0; i < 6; i++) {
        if (i == 99) {
            return in;
        }
        assert(in == 0);
    }
    return -1;
}


template EarlyReturn() {
    signal input inp;
    signal output outp[2];

    outp[0] <== noEarlyReturnFn(inp);
    outp[1] <== earlyReturnFn(inp);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@EarlyReturn::@EarlyReturn<[]>>} {
// CHECK-NEXT:    poly.template @earlyReturnFn {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @earlyReturnFn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "in"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : i1
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_1]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (i1, !poly.tvar<@T_return>, !felt.type<"bn128">) -> (i1, !poly.tvar<@T_return>, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_5]] : i1
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_10]], %[[VAL_9]] : i1, i1
// CHECK-NEXT:          scf.condition(%[[VAL_11]]) %[[VAL_5]], %[[VAL_6]], %[[VAL_7]] : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: i1, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_return>, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_14]], %[[VAL_15]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_16]] -> (i1, !poly.tvar<@T_arg0>) {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            scf.yield %[[VAL_18]], %[[VAL_0]] : i1, !poly.tvar<@T_arg0>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_13]] : (!poly.tvar<@T_return>) -> !poly.tvar<@T_arg0>
// CHECK-NEXT:            scf.yield %[[VAL_19]], %[[VAL_20]] : i1, !poly.tvar<@T_arg0>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_17]]#1 : (!poly.tvar<@T_arg0>) -> !poly.tvar<@T_return>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_17]]#0 -> (i1, !poly.tvar<@T_return>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_23]], %[[VAL_21]], %[[VAL_24]] : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_25]], %[[VAL_26]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            bool.assert %[[VAL_27]], "assertion failed"
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_17]]#0, %[[VAL_21]], %[[VAL_29]] : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_22]]#0, %[[VAL_22]]#1, %[[VAL_22]]#2 : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_4]]#0 -> (!poly.tvar<@T_return>) {
// CHECK-NEXT:          scf.yield %[[VAL_4]]#1 : !poly.tvar<@T_return>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_32]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:          scf.yield %[[VAL_33]] : !poly.tvar<@T_return>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_30]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @noEarlyReturnFn {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @noEarlyReturnFn(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "in"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = llzk.nondet : !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = llzk.nondet : i1
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_36]], %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_35]], %[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_37]]) : (i1, !poly.tvar<@T_return>, !felt.type<"bn128">) -> (i1, !poly.tvar<@T_return>, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_39]] : i1
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_44]], %[[VAL_43]] : i1, i1
// CHECK-NEXT:          scf.condition(%[[VAL_45]]) %[[VAL_39]], %[[VAL_40]], %[[VAL_41]] : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_46:[0-9a-zA-Z_\.]+]]: i1, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_return>, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_48]], %[[VAL_49]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_50]] -> (i1, !poly.tvar<@T_arg0>) {
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            scf.yield %[[VAL_52]], %[[VAL_34]] : i1, !poly.tvar<@T_arg0>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_47]] : (!poly.tvar<@T_return>) -> !poly.tvar<@T_arg0>
// CHECK-NEXT:            scf.yield %[[VAL_53]], %[[VAL_54]] : i1, !poly.tvar<@T_arg0>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_51]]#1 : (!poly.tvar<@T_arg0>) -> !poly.tvar<@T_return>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_51]]#0 -> (i1, !poly.tvar<@T_return>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_57]], %[[VAL_55]], %[[VAL_58]] : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_34]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_60]], %[[VAL_59]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            bool.assert %[[VAL_61]], "assertion failed"
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_48]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_51]]#0, %[[VAL_55]], %[[VAL_63]] : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_56]]#0, %[[VAL_56]]#1, %[[VAL_56]]#2 : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_38]]#0 -> (!poly.tvar<@T_return>) {
// CHECK-NEXT:          scf.yield %[[VAL_38]]#1 : !poly.tvar<@T_return>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_66]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:          scf.yield %[[VAL_67]] : !poly.tvar<@T_return>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_64]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !array.type<2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = function.call @noEarlyReturnFn::@noEarlyReturnFn(%[[VAL_68]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_70]]{{\[}}%[[VAL_73]]] = %[[VAL_71]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn::@earlyReturnFn(%[[VAL_68]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_70]]{{\[}}%[[VAL_76]]] = %[[VAL_74]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_69]][@outp] = %[[VAL_70]] : <@EarlyReturn::@EarlyReturn<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_69]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = function.call @noEarlyReturnFn::@noEarlyReturnFn(%[[VAL_78]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_82]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_83]], %[[VAL_80]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn::@earlyReturnFn(%[[VAL_78]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_86]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_87]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
