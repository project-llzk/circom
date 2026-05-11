// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function sum(a, b, c) {
    return a[0][0][0] + a[1][0][0] + a[2][0][0] + a[3][0][0] + b[0][0] + b[1][2] + c;
}

template CallArgTest() {
    signal input x[4][2][3];
    signal input y[2][3];
    signal input z;
    signal output q;

    q <-- sum(x, y, z);
}

component main = CallArgTest();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@CallArgTest::@CallArgTest<[]>>} {
// CHECK-NEXT:    poly.template @sum {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @sum(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1>, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<?,?,? x !poly.tvar<@"$e">>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_4]], %[[VAL_6]], %[[VAL_8]]] : <?,?,? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<?,?,? x !poly.tvar<@"$e_0">>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_12]], %[[VAL_14]], %[[VAL_16]]] : <?,?,? x !poly.tvar<@"$e_0">>, !poly.tvar<@"$e_0">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_10]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_18]] : (!poly.tvar<@"$e_0">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_20]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<?,?,? x !poly.tvar<@"$e_1">>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_23]], %[[VAL_25]], %[[VAL_27]]] : <?,?,? x !poly.tvar<@"$e_1">>, !poly.tvar<@"$e_1">
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_29]] : (!poly.tvar<@"$e_1">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<?,?,? x !poly.tvar<@"$e_2">>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_33]], %[[VAL_35]], %[[VAL_37]]] : <?,?,? x !poly.tvar<@"$e_2">>, !poly.tvar<@"$e_2">
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_39]] : (!poly.tvar<@"$e_2">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !array.type<?,? x !poly.tvar<@"$e_3">>
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_43]], %[[VAL_45]]] : <?,? x !poly.tvar<@"$e_3">>, !poly.tvar<@"$e_3">
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_47]] : (!poly.tvar<@"$e_3">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !array.type<?,? x !poly.tvar<@"$e_4">>
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_51]], %[[VAL_53]]] : <?,? x !poly.tvar<@"$e_4">>, !poly.tvar<@"$e_4">
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_55]] : (!poly.tvar<@"$e_4">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_49]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_57]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_59]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_60]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:      poly.param @"$e_0" : !poly.tvar<@"$e_0">
// CHECK-NEXT:      poly.param @"$e_1" : !poly.tvar<@"$e_1">
// CHECK-NEXT:      poly.param @"$e_2" : !poly.tvar<@"$e_2">
// CHECK-NEXT:      poly.param @"$e_3" : !poly.tvar<@"$e_3">
// CHECK-NEXT:      poly.param @"$e_4" : !poly.tvar<@"$e_4">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallArgTest {
// CHECK-NEXT:      struct.def @CallArgTest {
// CHECK-NEXT:        struct.member @q : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<4,2,3 x !felt.type<"bn128">>, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">>, %[[VAL_63:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@CallArgTest::@CallArgTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.new : <@CallArgTest::@CallArgTest<[]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = function.call @sum::@sum<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?]>(%[[VAL_61]], %[[VAL_62]], %[[VAL_63]]) : (!array.type<4,2,3 x !felt.type<"bn128">>, !array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_64]][@q] = %[[VAL_65]] : <@CallArgTest::@CallArgTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_64]] : !struct.type<@CallArgTest::@CallArgTest<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !struct.type<@CallArgTest::@CallArgTest<[]>>, %[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<4,2,3 x !felt.type<"bn128">>, %[[VAL_68:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">>, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@q] : <@CallArgTest::@CallArgTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
