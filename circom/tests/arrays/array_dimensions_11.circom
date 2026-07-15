// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template EvilArrayDims(N) {
    var x = 12;
    var a[2] = [123, 675];
    x = 6;
    signal input in[x];
    a[1] = N + x;
    signal output out1[a[1]];
    signal output out2[N > 12 ? a[0] + a[1] : 0];
}

component main = EvilArrayDims(7);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@EvilArrayDims::@EvilArrayDims<[7]>>} {
// CHECK-NEXT:    poly.template @EvilArrayDims {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.expr @"N_Greater_12?a[0]_Add_a[1]:0@411" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_7]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_3]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_10]]{{\[}}%[[VAL_5]]] = %[[VAL_11]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_8]], %[[VAL_0]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_12]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_6]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_5]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_1]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_17]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"a[1]@381" {
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_23]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_18]], %[[VAL_18]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_19]], %[[VAL_20]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_26]]{{\[}}%[[VAL_22]]] = %[[VAL_27]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_22]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_29]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"x@336" {
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_30]], %[[VAL_30]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_31]], %[[VAL_32]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        poly.yield %[[VAL_33]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @EvilArrayDims {
// CHECK-NEXT:        struct.member @out1 : !array.type<@"a[1]@381" x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @out2 : !array.type<@"N_Greater_12?a[0]_Add_a[1]:0@411" x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<@"x@336" x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@EvilArrayDims::@EvilArrayDims<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.new : <@EvilArrayDims::@EvilArrayDims<[@N]>>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_38]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Greater_12?a[0]_Add_a[1]:0@411" : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_40]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @"a[1]@381" : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_42]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.read_const @"x@336" : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_44]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_47]], %[[VAL_47]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_49]], %[[VAL_50]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_51]]{{\[}}%[[VAL_55]]] = %[[VAL_53]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_37]] : !struct.type<@EvilArrayDims::@EvilArrayDims<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !struct.type<@EvilArrayDims::@EvilArrayDims<[@N]>>, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<@"x@336" x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_58]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Greater_12?a[0]_Add_a[1]:0@411" : index
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_60]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = poly.read_const @"a[1]@381" : index
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_62]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.read_const @"x@336" : index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_64]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out1] : <@EvilArrayDims::@EvilArrayDims<[@N]>>, !array.type<@"a[1]@381" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out2] : <@EvilArrayDims::@EvilArrayDims<[@N]>>, !array.type<@"N_Greater_12?a[0]_Add_a[1]:0@411" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_69]], %[[VAL_69]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_71]], %[[VAL_72]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_59]], %[[VAL_74]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_73]]{{\[}}%[[VAL_77]]] = %[[VAL_75]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
