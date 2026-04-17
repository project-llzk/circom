// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template EvilArrayDims(N, M) {
    var x;
    if (N > 99) {
        var D = N + M;
        var arr[D];
        arr[D-1] = 99;
        x = arr[D-1];
    } else {
        var D = N * M + 1;
        var arr[D];
        arr[D-1] = 77;
        x = arr[D-1];
    }
}

component main = EvilArrayDims(7, 2);

// CHECK: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<()[s0] -> (s0)>
//
// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EvilArrayDims::@EvilArrayDims<[7, 2]>>} {
// CHECK-NEXT:    poly.template @EvilArrayDims {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.param @M
// CHECK-NEXT:      struct.def @EvilArrayDims {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_2]], %[[VAL_4]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_5]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new{(){{\[}}%[[VAL_9]]]} : <#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_10]], %[[VAL_11]] : <#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_13]] to %[[VAL_12]] step %[[VAL_14]] {
// CHECK-NEXT:              array.write %[[VAL_10]]{{\[}}%[[VAL_15]]] = %[[VAL_8]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_7]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_10]]{{\[}}%[[VAL_19]]] = %[[VAL_16]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_7]], %[[VAL_20]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_22]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_2]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.new{(){{\[}}%[[VAL_28]]]} : <#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_29]], %[[VAL_30]] : <#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]] to %[[VAL_31]] step %[[VAL_33]] {
// CHECK-NEXT:              array.write %[[VAL_29]]{{\[}}%[[VAL_34]]] = %[[VAL_27]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_29]]{{\[}}%[[VAL_38]]] = %[[VAL_35]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_41]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_45]], %[[VAL_47]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_48]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_45]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.new{(){{\[}}%[[VAL_52]]]} : <#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_53]], %[[VAL_54]] : <#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_56]] to %[[VAL_55]] step %[[VAL_57]] {
// CHECK-NEXT:              array.write %[[VAL_53]]{{\[}}%[[VAL_58]]] = %[[VAL_51]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_50]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_53]]{{\[}}%[[VAL_62]]] = %[[VAL_59]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_50]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_65]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_45]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_67]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.new{(){{\[}}%[[VAL_71]]]} : <#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_72]], %[[VAL_73]] : <#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_75]] to %[[VAL_74]] step %[[VAL_76]] {
// CHECK-NEXT:              array.write %[[VAL_72]]{{\[}}%[[VAL_77]]] = %[[VAL_70]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_69]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_72]]{{\[}}%[[VAL_81]]] = %[[VAL_78]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_69]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_84]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
