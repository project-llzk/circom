// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template EvilArrayDims(N, M) {
    var arr = M;
    var x;
    if (N > 99) {
        var D = N + M;
        var arr[D][D];
        arr[D-1][D-1] = 99;
        x = arr[D-1][D-1];
    } else {
        var D = N * M + 1;
        var arr[D];
        arr[D-1] = 77;
        x = arr[D-1];
    }
    signal output out <== x + arr;
}

component main = EvilArrayDims(7, 2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@EvilArrayDims::@EvilArrayDims<[7, 2]>>} {
// CHECK-NEXT:    poly.template @EvilArrayDims {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.param @M : index
// CHECK-NEXT:      poly.expr @"D@350" {
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
// CHECK-NEXT:      poly.expr @"D@353" {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_11]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_13]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_14]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_15]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_19]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"D@468" {
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_22]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_24]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_25]], %[[VAL_20]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_26]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_25]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_29]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_31]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @EvilArrayDims {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.new : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@350" : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_33]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@353" : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_35]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@468" : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_37]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_39]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_41]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_42]], %[[VAL_44]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_45]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_49]], %[[VAL_50]] : <@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]] to %[[VAL_51]] step %[[VAL_53]] {
// CHECK-NEXT:              array.write %[[VAL_49]]{{\[}}%[[VAL_54]]] = %[[VAL_48]] : <@"D@353" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@350",@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_55]], %[[VAL_56]] : <@"D@350",@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_57]] step %[[VAL_59]] {
// CHECK-NEXT:              array.insert %[[VAL_55]]{{\[}}%[[VAL_60]]] = %[[VAL_49]] : <@"D@350",@"D@353" x !felt.type<"bn128">>, <@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_47]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_47]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_55]]{{\[}}%[[VAL_64]], %[[VAL_67]]] = %[[VAL_61]] : <@"D@350",@"D@353" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_47]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_47]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_70]], %[[VAL_73]]] : <@"D@350",@"D@353" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_42]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_75]], %[[VAL_76]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@468" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_79]], %[[VAL_80]] : <@"D@468" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_82]] to %[[VAL_81]] step %[[VAL_83]] {
// CHECK-NEXT:              array.write %[[VAL_79]]{{\[}}%[[VAL_84]]] = %[[VAL_78]] : <@"D@468" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_77]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_79]]{{\[}}%[[VAL_88]]] = %[[VAL_85]] : <@"D@468" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_77]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_91]]] : <@"D@468" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_32]][@out] = %[[VAL_93]] : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_32]] : !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_94:[0-9a-zA-Z_\.]+]]: !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@350" : index
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_95]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@353" : index
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_97]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@468" : index
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_99]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_101]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_103]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_94]][@out] : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_104]], %[[VAL_107]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_108]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_104]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_112]], %[[VAL_113]] : <@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_117:[0-9a-zA-Z_\.]+]] = %[[VAL_115]] to %[[VAL_114]] step %[[VAL_116]] {
// CHECK-NEXT:              array.write %[[VAL_112]]{{\[}}%[[VAL_117]]] = %[[VAL_111]] : <@"D@353" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@350",@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_118]], %[[VAL_119]] : <@"D@350",@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_123:[0-9a-zA-Z_\.]+]] = %[[VAL_121]] to %[[VAL_120]] step %[[VAL_122]] {
// CHECK-NEXT:              array.insert %[[VAL_118]]{{\[}}%[[VAL_123]]] = %[[VAL_112]] : <@"D@350",@"D@353" x !felt.type<"bn128">>, <@"D@353" x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_110]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_110]], %[[VAL_128]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_118]]{{\[}}%[[VAL_127]], %[[VAL_130]]] = %[[VAL_124]] : <@"D@350",@"D@353" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_110]], %[[VAL_131]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_132]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_110]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_135]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_118]]{{\[}}%[[VAL_133]], %[[VAL_136]]] : <@"D@350",@"D@353" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_137]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_104]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_138]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@468" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_142]], %[[VAL_143]] : <@"D@468" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_147:[0-9a-zA-Z_\.]+]] = %[[VAL_145]] to %[[VAL_144]] step %[[VAL_146]] {
// CHECK-NEXT:              array.write %[[VAL_142]]{{\[}}%[[VAL_147]]] = %[[VAL_141]] : <@"D@468" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_140]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_150]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_142]]{{\[}}%[[VAL_151]]] = %[[VAL_148]] : <@"D@468" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_140]], %[[VAL_152]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]{{\[}}%[[VAL_154]]] : <@"D@468" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_109]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_105]], %[[VAL_156]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
