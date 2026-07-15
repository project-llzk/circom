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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@EvilArrayDims::@EvilArrayDims<[7, 2]>>} {
// CHECK-NEXT:    poly.template @EvilArrayDims {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.param @M : index
// CHECK-NEXT:      poly.expr @"D@333" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_4]], %[[VAL_0]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_5]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_4]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_9]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"D@438" {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_12]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_14]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_15]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_16]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_15]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_11]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_21]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @EvilArrayDims {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.new : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@333" : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_23]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@438" : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_25]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_27]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_29]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_30]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_33]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@333" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_37]], %[[VAL_38]] : <@"D@333" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_42:[0-9a-zA-Z_\.]+]] = %[[VAL_40]] to %[[VAL_39]] step %[[VAL_41]] {
// CHECK-NEXT:              array.write %[[VAL_37]]{{\[}}%[[VAL_42]]] = %[[VAL_36]] : <@"D@333" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_35]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_37]]{{\[}}%[[VAL_46]]] = %[[VAL_43]] : <@"D@333" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_35]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_49]]] : <@"D@333" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_30]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@438" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_55]], %[[VAL_56]] : <@"D@438" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_57]] step %[[VAL_59]] {
// CHECK-NEXT:              array.write %[[VAL_55]]{{\[}}%[[VAL_60]]] = %[[VAL_54]] : <@"D@438" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_53]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_55]]{{\[}}%[[VAL_64]]] = %[[VAL_61]] : <@"D@438" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_53]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_67]]] : <@"D@438" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_68]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_22]] : !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@333" : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_70]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@438" : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_72]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_74]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_76]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_77]], %[[VAL_79]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_80]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_77]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@333" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_84]], %[[VAL_85]] : <@"D@333" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_89:[0-9a-zA-Z_\.]+]] = %[[VAL_87]] to %[[VAL_86]] step %[[VAL_88]] {
// CHECK-NEXT:              array.write %[[VAL_84]]{{\[}}%[[VAL_89]]] = %[[VAL_83]] : <@"D@333" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_82]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_84]]{{\[}}%[[VAL_93]]] = %[[VAL_90]] : <@"D@333" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_82]], %[[VAL_94]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_84]]{{\[}}%[[VAL_96]]] : <@"D@333" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_77]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_98]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@438" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_102]], %[[VAL_103]] : <@"D@438" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_107:[0-9a-zA-Z_\.]+]] = %[[VAL_105]] to %[[VAL_104]] step %[[VAL_106]] {
// CHECK-NEXT:              array.write %[[VAL_102]]{{\[}}%[[VAL_107]]] = %[[VAL_101]] : <@"D@438" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_100]], %[[VAL_109]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_102]]{{\[}}%[[VAL_111]]] = %[[VAL_108]] : <@"D@438" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_100]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_114]]] : <@"D@438" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
