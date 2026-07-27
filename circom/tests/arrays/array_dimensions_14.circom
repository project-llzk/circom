// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_10]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_11]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_15]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"D@[[OFFSET2:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_19]], %[[VAL_16]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_20]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_19]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_25]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @EvilArrayDims {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_27]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_29]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET2]]" : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_31]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_34]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_37]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_41]], %[[VAL_42]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_46:[0-9a-zA-Z_\.]+]] = %[[VAL_44]] to %[[VAL_43]] step %[[VAL_45]] {
// CHECK-NEXT:              array.write %[[VAL_41]]{{\[}}%[[VAL_46]]] = %[[VAL_40]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_47]], %[[VAL_48]] : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_50]] to %[[VAL_49]] step %[[VAL_51]] {
// CHECK-NEXT:              array.insert %[[VAL_47]]{{\[}}%[[VAL_52]]] = %[[VAL_41]] : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>, <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_39]], %[[VAL_54]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_39]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_47]]{{\[}}%[[VAL_56]], %[[VAL_59]]] = %[[VAL_53]] : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_39]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_39]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_62]], %[[VAL_65]]] : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_34]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_67]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_71]], %[[VAL_72]] : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_76:[0-9a-zA-Z_\.]+]] = %[[VAL_74]] to %[[VAL_73]] step %[[VAL_75]] {
// CHECK-NEXT:              array.write %[[VAL_71]]{{\[}}%[[VAL_76]]] = %[[VAL_70]] : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_69]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_71]]{{\[}}%[[VAL_80]]] = %[[VAL_77]] : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_69]], %[[VAL_81]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_83]]] : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_26]][@out] = %[[VAL_85]] : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_26]] : !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !struct.type<@EvilArrayDims::@EvilArrayDims<[@N, @M]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_87]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_89]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = poly.read_const @"D@[[OFFSET2]]" : index
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_91]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_86]][@out] : <@EvilArrayDims::@EvilArrayDims<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_94]], %[[VAL_97]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_98]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_94]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_102]], %[[VAL_103]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_107:[0-9a-zA-Z_\.]+]] = %[[VAL_105]] to %[[VAL_104]] step %[[VAL_106]] {
// CHECK-NEXT:              array.write %[[VAL_102]]{{\[}}%[[VAL_107]]] = %[[VAL_101]] : <@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_108]], %[[VAL_109]] : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_113:[0-9a-zA-Z_\.]+]] = %[[VAL_111]] to %[[VAL_110]] step %[[VAL_112]] {
// CHECK-NEXT:              array.insert %[[VAL_108]]{{\[}}%[[VAL_113]]] = %[[VAL_102]] : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>, <@"D@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_100]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_116]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_100]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_108]]{{\[}}%[[VAL_117]], %[[VAL_120]]] = %[[VAL_114]] : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_100]], %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_100]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_123]], %[[VAL_126]]] : <@"D@[[OFFSET0]]",@"D@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_94]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_128]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.new  : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_132]], %[[VAL_133]] : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            scf.for %[[VAL_137:[0-9a-zA-Z_\.]+]] = %[[VAL_135]] to %[[VAL_134]] step %[[VAL_136]] {
// CHECK-NEXT:              array.write %[[VAL_132]]{{\[}}%[[VAL_137]]] = %[[VAL_131]] : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_130]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_140]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_132]]{{\[}}%[[VAL_141]]] = %[[VAL_138]] : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_130]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_143]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_132]]{{\[}}%[[VAL_144]]] : <@"D@[[OFFSET2]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_99]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_95]], %[[VAL_146]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
