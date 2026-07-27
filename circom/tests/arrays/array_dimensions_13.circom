// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@EvilArrayDims::@EvilArrayDims<[7, 2]>>} {
// CHECK-NEXT:    poly.template @EvilArrayDims {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.param @M
// CHECK-NEXT:      poly.expr @"D@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_2]], %[[VAL_0]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_3]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_4]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_7]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"D@[[OFFSET1:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_11]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_12]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_11]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_17]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @EvilArrayDims {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.new : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_21]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_24]], %[[VAL_26]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_27]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_31]], %[[VAL_32]] : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_34]] to %[[VAL_33]] step %[[VAL_35]] {
// CHECK-NEXT:              array.write %[[VAL_31]]{{\[}}%[[VAL_36]]] = %[[VAL_30]] : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_29]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_31]]{{\[}}%[[VAL_40]]] = %[[VAL_37]] : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_29]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_43]]] : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_24]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_45]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_49]], %[[VAL_50]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]] to %[[VAL_51]] step %[[VAL_53]] {
// CHECK-NEXT:              array.write %[[VAL_49]]{{\[}}%[[VAL_54]]] = %[[VAL_48]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_47]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_49]]{{\[}}%[[VAL_58]]] = %[[VAL_55]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_47]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_49]]{{\[}}%[[VAL_61]]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_18]] : !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_64]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_66]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_69]], %[[VAL_71]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_72]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_76]], %[[VAL_77]] : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_79]] to %[[VAL_78]] step %[[VAL_80]] {
// CHECK-NEXT:              array.write %[[VAL_76]]{{\[}}%[[VAL_81]]] = %[[VAL_75]] : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_74]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_85]]] = %[[VAL_82]] : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_74]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_88]]] : <@"D@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_69]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_90]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_94]], %[[VAL_95]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_99:[0-9a-zA-Z_\.]+]] = %[[VAL_97]] to %[[VAL_96]] step %[[VAL_98]] {
// CHECK-NEXT:              array.write %[[VAL_94]]{{\[}}%[[VAL_99]]] = %[[VAL_93]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_92]], %[[VAL_101]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_94]]{{\[}}%[[VAL_103]]] = %[[VAL_100]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_92]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_106]]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
