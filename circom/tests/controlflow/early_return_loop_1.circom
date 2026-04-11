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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EarlyReturn<[]>>} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : i1
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_1]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (i1, !felt.type, !felt.type) -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_5]] : i1
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_10]], %[[VAL_9]] : i1, i1
// CHECK-NEXT:        scf.condition(%[[VAL_11]]) %[[VAL_5]], %[[VAL_6]], %[[VAL_7]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: i1, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_14]], %[[VAL_15]]) : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_16]] -> (i1, !felt.type) {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[VAL_18]], %[[VAL_0]] : i1, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          scf.yield %[[VAL_19]], %[[VAL_13]] : i1, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_17]]#0 -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_21]], %[[VAL_17]]#1, %[[VAL_22]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_23]], %[[VAL_24]]) : !felt.type, !felt.type
// CHECK-NEXT:          bool.assert %[[VAL_25]], "assertion failed"
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_17]]#0, %[[VAL_17]]#1, %[[VAL_27]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        scf.yield %[[VAL_20]]#0, %[[VAL_20]]#1, %[[VAL_20]]#2 : i1, !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_28:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_4]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[VAL_4]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_29]] : !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_30]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_28]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    function.def @noEarlyReturnFn(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_32:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:      %[[VAL_33:[0-9a-zA-Z_\.]+]] = llzk.nondet : i1
// CHECK-NEXT:      %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_35:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_33]], %[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_32]], %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_34]]) : (i1, !felt.type, !felt.type) -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_38]], %[[VAL_39]]) : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_36]] : i1
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_41]], %[[VAL_40]] : i1, i1
// CHECK-NEXT:        scf.condition(%[[VAL_42]]) %[[VAL_36]], %[[VAL_37]], %[[VAL_38]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[VAL_43:[0-9a-zA-Z_\.]+]]: i1, %[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_45]], %[[VAL_46]]) : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_47]] -> (i1, !felt.type) {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[VAL_49]], %[[VAL_31]] : i1, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          scf.yield %[[VAL_50]], %[[VAL_44]] : i1, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_48]]#0 -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_52]], %[[VAL_48]]#1, %[[VAL_53]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_31]], %[[VAL_54]]) : !felt.type, !felt.type
// CHECK-NEXT:          bool.assert %[[VAL_55]], "assertion failed"
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_45]], %[[VAL_56]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_48]]#0, %[[VAL_48]]#1, %[[VAL_57]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        scf.yield %[[VAL_51]]#0, %[[VAL_51]]#1, %[[VAL_51]]#2 : i1, !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_58:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_35]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[VAL_35]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_59]] : !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_60]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_58]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !array.type<2 x !felt.type> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = function.call @noEarlyReturnFn(%[[VAL_61]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type
// CHECK-NEXT:          array.write %[[VAL_63]]{{\[}}%[[VAL_66]]] = %[[VAL_64]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_61]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_68]] : !felt.type
// CHECK-NEXT:          array.write %[[VAL_63]]{{\[}}%[[VAL_69]]] = %[[VAL_67]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_62]][@outp] = %[[VAL_63]] : <@EarlyReturn::@EarlyReturn<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:          function.return %[[VAL_62]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_70:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_71:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:           %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_70]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !array.type<2 x !felt.type>
// CHECK-DAG:           %[[VAL_73:[0-9a-zA-Z_\.]+]] = function.call @noEarlyReturnFn(%[[VAL_71]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_75]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_76]], %[[VAL_73]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_71]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_79]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_80]], %[[VAL_77]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
