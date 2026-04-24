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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EvilArrayDims::@EvilArrayDims<[7]>>} {
// CHECK-NEXT:    poly.template @EvilArrayDims {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.expr @"N_Greater_12?a[0]_Add_a[1]:0@411" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_3]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_6]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_7]]{{\[}}%[[VAL_9]]] = %[[VAL_8]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_6]], %[[VAL_0]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_10]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_1]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_12]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_14]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_1]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        poly.yield %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"a[1]@381" {
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_17]], %[[VAL_18]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_19]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_22]]{{\[}}%[[VAL_24]]] = %[[VAL_23]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_25]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"x@336" {
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @EvilArrayDims {
// CHECK-NEXT:        struct.member @out1 : !array.type<@"a[1]@381" x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @out2 : !array.type<@"N_Greater_12?a[0]_Add_a[1]:0@411" x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<@"x@336" x !felt.type<"bn128">>) -> !struct.type<@EvilArrayDims::@EvilArrayDims<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.new : <@EvilArrayDims::@EvilArrayDims<[@N]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Greater_12?a[0]_Add_a[1]:0@411" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = poly.read_const @"a[1]@381" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @"x@336" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_35]], %[[VAL_35]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_37]], %[[VAL_38]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_39]]{{\[}}%[[VAL_43]]] = %[[VAL_41]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_29]] : !struct.type<@EvilArrayDims::@EvilArrayDims<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !struct.type<@EvilArrayDims::@EvilArrayDims<[@N]>>, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<@"x@336" x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Greater_12?a[0]_Add_a[1]:0@411" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = poly.read_const @"a[1]@381" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = poly.read_const @"x@336" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_44]][@out1] : <@EvilArrayDims::@EvilArrayDims<[@N]>>, !array.type<@"a[1]@381" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_44]][@out2] : <@EvilArrayDims::@EvilArrayDims<[@N]>>, !array.type<@"N_Greater_12?a[0]_Add_a[1]:0@411" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_53]], %[[VAL_53]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  123 : <"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  675 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_55]], %[[VAL_56]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_57]]{{\[}}%[[VAL_61]]] = %[[VAL_59]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
