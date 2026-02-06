// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.3;

// matrix multiplication by element
template matElemMul (m,n) {
    signal input a[m][n];
    signal input b[m][n];
    signal output out[m][n];

    for (var i=0; i < m; i++) {
        for (var j=0; j < n; j++) {
            out[i][j] <== a[i][j] * b[i][j];
        }
    }
}

// sum of all elements in a matrix
template matElemSum (m,n) {
    signal input a[m][n];
    signal output out;

    signal sum[m*n];
    sum[0] <== a[0][0];
    var idx = 0;

    for (var i=0; i < m; i++) {
        for (var j=0; j < n; j++) {
            if (idx > 0) {
                sum[idx] <== sum[idx-1] + a[i][j];
            }
            idx++;
        }
    }

    out <== sum[m*n-1];
}

// matrix multiplication
template matMul (m,n,p) {
    signal input a[m][n];
    signal input b[n][p];
    signal output out[m][p];

    component matElemMulComp[m][p];
    component matElemSumComp[m][p];

    for (var i=0; i < m; i++) {
        for (var j=0; j < p; j++) {
            matElemMulComp[i][j] = matElemMul(1,n);
            matElemSumComp[i][j] = matElemSum(1,n);
            for (var k=0; k < n; k++) {
                matElemMulComp[i][j].a[0][k] <== a[i][k];
                matElemMulComp[i][j].b[0][k] <== b[k][j];
            }
            for (var k=0; k < n; k++) {
                matElemSumComp[i][j].a[0][k] <== matElemMulComp[i][j].out[0][k];
            }
            out[i][j] <== matElemSumComp[i][j].out;
        }
    }
}

component main = matMul(2,3,2);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@matMul_2<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @matElemMul_0<[]> {
// CHECK-NEXT:      struct.field @out : !array.type<1,3 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type>) -> !struct.type<@matElemMul_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@matElemMul_0<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_9]])
// CHECK-NEXT:          scf.condition(%[[VAL_10]]) %[[VAL_8]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_12]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_15]])
// CHECK-NEXT:            scf.condition(%[[VAL_16]]) %[[VAL_14]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]]
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_19]], %[[VAL_20]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_23]], %[[VAL_24]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_21]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]]
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_28]], %[[VAL_29]]] = %[[VAL_26]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_30]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_31]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          scf.yield %[[VAL_32]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_2]][@out] = %[[VAL_3]] : <@matElemMul_0<[]>>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !struct.type<@matElemMul_0<[]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_33]][@out] : <@matElemMul_0<[]>>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_39]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_42]])
// CHECK-NEXT:          scf.condition(%[[VAL_43]]) %[[VAL_41]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_47:[0-9a-zA-Z_\.]+]] = %[[VAL_45]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_47]], %[[VAL_48]])
// CHECK-NEXT:            scf.condition(%[[VAL_49]]) %[[VAL_47]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_50:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]]
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]]
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_52]], %[[VAL_53]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]]
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]]
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_56]], %[[VAL_57]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_54]], %[[VAL_58]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]]
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]]
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_61]], %[[VAL_62]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_63]], %[[VAL_59]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_50]], %[[VAL_64]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_65]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          scf.yield %[[VAL_66]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @matElemSum_1<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @sum : !array.type<3 x !felt.type>
// CHECK-NEXT:      function.def @compute(%[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type>) -> !struct.type<@matElemSum_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.new : <@matElemSum_1<[]>>
// CHECK-NEXT:        %[[VAL_69:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<3 x !felt.type>
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]]
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]]
// CHECK-NEXT:        %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_73]], %[[VAL_75]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]]
// CHECK-NEXT:        array.write %[[VAL_69]]{{\[}}%[[VAL_78]]] = %[[VAL_76]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_81:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_80]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_79]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_84]])
// CHECK-NEXT:          scf.condition(%[[VAL_85]]) %[[VAL_82]], %[[VAL_83]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_87]], %[[VAL_91:[0-9a-zA-Z_\.]+]] = %[[VAL_88]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_91]], %[[VAL_92]])
// CHECK-NEXT:            scf.condition(%[[VAL_93]]) %[[VAL_90]], %[[VAL_91]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_94:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_95:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_94]], %[[VAL_96]])
// CHECK-NEXT:            scf.if %[[VAL_97]] {
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_94]], %[[VAL_98]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_99]]
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_100]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]]
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]]
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_103]], %[[VAL_104]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_101]], %[[VAL_105]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]]
// CHECK-NEXT:              array.write %[[VAL_69]]{{\[}}%[[VAL_107]]] = %[[VAL_106]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_94]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_95]], %[[VAL_110]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_109]], %[[VAL_111]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          scf.yield %[[VAL_112]], %[[VAL_89]]#0 : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]]
// CHECK-NEXT:        %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_114]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_68]][@out] = %[[VAL_115]] : <@matElemSum_1<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_68]][@sum] = %[[VAL_69]] : <@matElemSum_1<[]>>, !array.type<3 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_68]] : !struct.type<@matElemSum_1<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_116:[0-9a-zA-Z_\.]+]]: !struct.type<@matElemSum_1<[]>>, %[[VAL_117:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_118:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_116]][@out] : <@matElemSum_1<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_119:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_116]][@sum] : <@matElemSum_1<[]>>, !array.type<3 x !felt.type>
// CHECK-NEXT:        %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]]
// CHECK-NEXT:        %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]]
// CHECK-NEXT:        %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_123]], %[[VAL_125]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_127]]
// CHECK-NEXT:        %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_128]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_129]], %[[VAL_126]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_132:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_131]], %[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_130]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_133]], %[[VAL_135]])
// CHECK-NEXT:          scf.condition(%[[VAL_136]]) %[[VAL_133]], %[[VAL_134]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_137:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_141:[0-9a-zA-Z_\.]+]] = %[[VAL_138]], %[[VAL_142:[0-9a-zA-Z_\.]+]] = %[[VAL_139]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_142]], %[[VAL_143]])
// CHECK-NEXT:            scf.condition(%[[VAL_144]]) %[[VAL_141]], %[[VAL_142]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_145:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_146:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_145]], %[[VAL_147]])
// CHECK-NEXT:            scf.if %[[VAL_148]] {
// CHECK-NEXT:              %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_145]], %[[VAL_149]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_150]]
// CHECK-NEXT:              %[[VAL_152:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_151]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]]
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_146]]
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_154]], %[[VAL_155]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_152]], %[[VAL_156]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]]
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_158]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:              constrain.eq %[[VAL_159]], %[[VAL_157]] : !felt.type, !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_145]], %[[VAL_160]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_146]], %[[VAL_162]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_161]], %[[VAL_163]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          scf.yield %[[VAL_164]], %[[VAL_140]]#0 : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_165]]
// CHECK-NEXT:        %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_166]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_118]], %[[VAL_167]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @matMul_2<[]> {
// CHECK-NEXT:      struct.field @out : !array.type<2,2 x !felt.type> {llzk.pub}
// CHECK-NEXT:      struct.field @matElemMulComp : !array.type<2,2 x !struct.type<@matElemMul_0<[]>>>
// CHECK-NEXT:      struct.field @matElemMulComp$inputs : !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:      struct.field @matElemSumComp : !array.type<2,2 x !struct.type<@matElemSum_1<[]>>>
// CHECK-NEXT:      struct.field @matElemSumComp$inputs : !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_168:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type>, %[[VAL_169:[0-9a-zA-Z_\.]+]]: !array.type<3,2 x !felt.type>) -> !struct.type<@matMul_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_170:[0-9a-zA-Z_\.]+]] = struct.new : <@matMul_2<[]>>
// CHECK-NEXT:        %[[VAL_171:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_172:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:        %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        scf.for %[[VAL_177:[0-9a-zA-Z_\.]+]] = %[[VAL_173]] to %[[VAL_175]] step %[[VAL_174]] {
// CHECK-NEXT:          scf.for %[[VAL_178:[0-9a-zA-Z_\.]+]] = %[[VAL_173]] to %[[VAL_176]] step %[[VAL_174]] {
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_172]]{{\[}}%[[VAL_177]], %[[VAL_178]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:            pod.write %[[VAL_179]][@count] = %[[VAL_180]] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            array.write %[[VAL_172]]{{\[}}%[[VAL_177]], %[[VAL_178]]] = %[[VAL_179]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_181:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:        %[[VAL_182:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:        %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        scf.for %[[VAL_187:[0-9a-zA-Z_\.]+]] = %[[VAL_183]] to %[[VAL_185]] step %[[VAL_184]] {
// CHECK-NEXT:          scf.for %[[VAL_188:[0-9a-zA-Z_\.]+]] = %[[VAL_183]] to %[[VAL_186]] step %[[VAL_184]] {
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_187]], %[[VAL_188]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:            pod.write %[[VAL_189]][@count] = %[[VAL_190]] : <[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            array.write %[[VAL_182]]{{\[}}%[[VAL_187]], %[[VAL_188]]] = %[[VAL_189]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:        %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_196:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_197:[0-9a-zA-Z_\.]+]] = %[[VAL_195]], %[[VAL_198:[0-9a-zA-Z_\.]+]] = %[[VAL_181]], %[[VAL_199:[0-9a-zA-Z_\.]+]] = %[[VAL_191]]) : (!felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>) -> (!felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>) {
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_197]], %[[VAL_200]])
// CHECK-NEXT:          scf.condition(%[[VAL_201]]) %[[VAL_197]], %[[VAL_198]], %[[VAL_199]] : !felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_202:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_203:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, %[[VAL_204:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>):
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_207:[0-9a-zA-Z_\.]+]] = %[[VAL_205]], %[[VAL_208:[0-9a-zA-Z_\.]+]] = %[[VAL_203]], %[[VAL_209:[0-9a-zA-Z_\.]+]] = %[[VAL_204]]) : (!felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>) -> (!felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>) {
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_207]], %[[VAL_210]])
// CHECK-NEXT:            scf.condition(%[[VAL_211]]) %[[VAL_207]], %[[VAL_208]], %[[VAL_209]] : !felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_212:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_213:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, %[[VAL_214:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>):
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_217:[0-9a-zA-Z_\.]+]] = %[[VAL_215]], %[[VAL_218:[0-9a-zA-Z_\.]+]] = %[[VAL_213]]) : (!felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>) -> (!felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>) {
// CHECK-NEXT:              %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:              %[[VAL_220:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_217]], %[[VAL_219]])
// CHECK-NEXT:              scf.condition(%[[VAL_220]]) %[[VAL_217]], %[[VAL_218]] : !felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_221:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_222:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>):
// CHECK-NEXT:              %[[VAL_223:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_224:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_221]]
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_168]]{{\[}}%[[VAL_223]], %[[VAL_224]]] : <2,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_226]], %[[VAL_227]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_228]][@a] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_230]]
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_221]]
// CHECK-NEXT:              array.write %[[VAL_229]]{{\[}}%[[VAL_231]], %[[VAL_232]]] = %[[VAL_225]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_233]], %[[VAL_234]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              pod.write %[[VAL_235]][@a] = %[[VAL_229]] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              array.write %[[VAL_222]]{{\[}}%[[VAL_236]], %[[VAL_237]]] = %[[VAL_235]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_172]]{{\[}}%[[VAL_238]], %[[VAL_239]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_240]][@count] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_243:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_241]], %[[VAL_242]] : index
// CHECK-NEXT:              pod.write %[[VAL_240]][@count] = %[[VAL_243]] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_244:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_243]], %[[VAL_244]] : index
// CHECK-NEXT:              scf.if %[[VAL_245]] {
// CHECK-NEXT:                %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_235]][@a] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:                %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_235]][@b] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:                %[[VAL_248:[0-9a-zA-Z_\.]+]] = function.call @matElemMul_0::@compute(%[[VAL_246]], %[[VAL_247]]) : (!array.type<1,3 x !felt.type>, !array.type<1,3 x !felt.type>) -> !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_240]][@comp] = %[[VAL_248]] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:                %[[VAL_249:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:                %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:                array.write %[[VAL_172]]{{\[}}%[[VAL_249]], %[[VAL_250]]] = %[[VAL_240]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_221]]
// CHECK-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_251]], %[[VAL_252]]] : <3,2 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_254]], %[[VAL_255]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_256]][@b] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_259:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_258]]
// CHECK-NEXT:              %[[VAL_260:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_221]]
// CHECK-NEXT:              array.write %[[VAL_257]]{{\[}}%[[VAL_259]], %[[VAL_260]]] = %[[VAL_253]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_261:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_262:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_263:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_261]], %[[VAL_262]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              pod.write %[[VAL_263]][@b] = %[[VAL_257]] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_264:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              array.write %[[VAL_222]]{{\[}}%[[VAL_264]], %[[VAL_265]]] = %[[VAL_263]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_266:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_268:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_172]]{{\[}}%[[VAL_266]], %[[VAL_267]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_269:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_268]][@count] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_269]], %[[VAL_270]] : index
// CHECK-NEXT:              pod.write %[[VAL_268]][@count] = %[[VAL_271]] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_271]], %[[VAL_272]] : index
// CHECK-NEXT:              scf.if %[[VAL_273]] {
// CHECK-NEXT:                %[[VAL_274:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_263]][@a] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:                %[[VAL_275:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_263]][@b] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:                %[[VAL_276:[0-9a-zA-Z_\.]+]] = function.call @matElemMul_0::@compute(%[[VAL_274]], %[[VAL_275]]) : (!array.type<1,3 x !felt.type>, !array.type<1,3 x !felt.type>) -> !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:                pod.write %[[VAL_268]][@comp] = %[[VAL_276]] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:                %[[VAL_277:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:                %[[VAL_278:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:                array.write %[[VAL_172]]{{\[}}%[[VAL_277]], %[[VAL_278]]] = %[[VAL_268]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_279:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_221]], %[[VAL_279]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_280]], %[[VAL_222]] : !felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_283:[0-9a-zA-Z_\.]+]] = %[[VAL_281]], %[[VAL_284:[0-9a-zA-Z_\.]+]] = %[[VAL_214]]) : (!felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>) -> (!felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>) {
// CHECK-NEXT:              %[[VAL_285:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:              %[[VAL_286:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_283]], %[[VAL_285]])
// CHECK-NEXT:              scf.condition(%[[VAL_286]]) %[[VAL_283]], %[[VAL_284]] : !felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_287:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_288:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>):
// CHECK-NEXT:              %[[VAL_289:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_172]]{{\[}}%[[VAL_289]], %[[VAL_290]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_291]][@comp] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_292]][@out] : <@matElemMul_0<[]>>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_294]]
// CHECK-NEXT:              %[[VAL_296:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_287]]
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_293]]{{\[}}%[[VAL_295]], %[[VAL_296]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_300:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_288]]{{\[}}%[[VAL_298]], %[[VAL_299]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@a] : <[@a: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_302:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_303:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_302]]
// CHECK-NEXT:              %[[VAL_304:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_287]]
// CHECK-NEXT:              array.write %[[VAL_301]]{{\[}}%[[VAL_303]], %[[VAL_304]]] = %[[VAL_297]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_305:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_306:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_307:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_288]]{{\[}}%[[VAL_305]], %[[VAL_306]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              pod.write %[[VAL_307]][@a] = %[[VAL_301]] : <[@a: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_308:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_309:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              array.write %[[VAL_288]]{{\[}}%[[VAL_308]], %[[VAL_309]]] = %[[VAL_307]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_310:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:              %[[VAL_311:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_310]], %[[VAL_311]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_312]][@count] : <[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_314:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_315:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_313]], %[[VAL_314]] : index
// CHECK-NEXT:              pod.write %[[VAL_312]][@count] = %[[VAL_315]] : <[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_316:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_317:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_315]], %[[VAL_316]] : index
// CHECK-NEXT:              scf.if %[[VAL_317]] {
// CHECK-NEXT:                %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_307]][@a] : <[@a: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:                %[[VAL_319:[0-9a-zA-Z_\.]+]] = function.call @matElemSum_1::@compute(%[[VAL_318]]) : (!array.type<1,3 x !felt.type>) -> !struct.type<@matElemSum_1<[]>>
// CHECK-NEXT:                pod.write %[[VAL_312]][@comp] = %[[VAL_319]] : <[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemSum_1<[]>>
// CHECK-NEXT:                %[[VAL_320:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:                %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:                array.write %[[VAL_182]]{{\[}}%[[VAL_320]], %[[VAL_321]]] = %[[VAL_312]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_322:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_323:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_287]], %[[VAL_322]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_323]], %[[VAL_288]] : !felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_324]], %[[VAL_325]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_326]][@comp] : <[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemSum_1<[]>>
// CHECK-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_327]][@out] : <@matElemSum_1<[]>>, !felt.type
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:            array.write %[[VAL_171]]{{\[}}%[[VAL_329]], %[[VAL_330]]] = %[[VAL_328]] : <2,2 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_332:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_212]], %[[VAL_331]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_332]], %[[VAL_216]]#1, %[[VAL_282]]#1 : !felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_333:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_334:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_202]], %[[VAL_333]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_334]], %[[VAL_206]]#1, %[[VAL_206]]#2 : !felt.type, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_170]][@matElemMulComp$inputs] = %[[VAL_196]]#1 : <@matMul_2<[]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:        %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !struct.type<@matElemMul_0<[]>>>
// CHECK-NEXT:        %[[VAL_336:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_337:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_338:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_339:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        scf.for %[[VAL_340:[0-9a-zA-Z_\.]+]] = %[[VAL_336]] to %[[VAL_338]] step %[[VAL_337]] {
// CHECK-NEXT:          scf.for %[[VAL_341:[0-9a-zA-Z_\.]+]] = %[[VAL_336]] to %[[VAL_339]] step %[[VAL_337]] {
// CHECK-NEXT:            %[[VAL_342:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_172]]{{\[}}%[[VAL_340]], %[[VAL_341]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_343:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_342]][@comp] : <[@count: index, @comp: !struct.type<@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:            array.write %[[VAL_335]]{{\[}}%[[VAL_340]], %[[VAL_341]]] = %[[VAL_343]] : <2,2 x !struct.type<@matElemMul_0<[]>>>, !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_170]][@matElemMulComp] = %[[VAL_335]] : <@matMul_2<[]>>, !array.type<2,2 x !struct.type<@matElemMul_0<[]>>>
// CHECK-NEXT:        struct.writef %[[VAL_170]][@matElemSumComp$inputs] = %[[VAL_196]]#2 : <@matMul_2<[]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:        %[[VAL_344:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !struct.type<@matElemSum_1<[]>>>
// CHECK-NEXT:        %[[VAL_345:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_346:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_347:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_348:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        scf.for %[[VAL_349:[0-9a-zA-Z_\.]+]] = %[[VAL_345]] to %[[VAL_347]] step %[[VAL_346]] {
// CHECK-NEXT:          scf.for %[[VAL_350:[0-9a-zA-Z_\.]+]] = %[[VAL_345]] to %[[VAL_348]] step %[[VAL_346]] {
// CHECK-NEXT:            %[[VAL_351:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_349]], %[[VAL_350]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_352:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_351]][@comp] : <[@count: index, @comp: !struct.type<@matElemSum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemSum_1<[]>>
// CHECK-NEXT:            array.write %[[VAL_344]]{{\[}}%[[VAL_349]], %[[VAL_350]]] = %[[VAL_352]] : <2,2 x !struct.type<@matElemSum_1<[]>>>, !struct.type<@matElemSum_1<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_170]][@matElemSumComp] = %[[VAL_344]] : <@matMul_2<[]>>, !array.type<2,2 x !struct.type<@matElemSum_1<[]>>>
// CHECK-NEXT:        struct.writef %[[VAL_170]][@out] = %[[VAL_171]] : <@matMul_2<[]>>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_170]] : !struct.type<@matMul_2<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_353:[0-9a-zA-Z_\.]+]]: !struct.type<@matMul_2<[]>>, %[[VAL_354:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type>, %[[VAL_355:[0-9a-zA-Z_\.]+]]: !array.type<3,2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_356:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_353]][@out] : <@matMul_2<[]>>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_357:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_353]][@matElemMulComp] : <@matMul_2<[]>>, !array.type<2,2 x !struct.type<@matElemMul_0<[]>>>
// CHECK-NEXT:        %[[VAL_358:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_353]][@matElemMulComp$inputs] : <@matMul_2<[]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:        %[[VAL_359:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_353]][@matElemSumComp] : <@matMul_2<[]>>, !array.type<2,2 x !struct.type<@matElemSum_1<[]>>>
// CHECK-NEXT:        %[[VAL_360:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_353]][@matElemSumComp$inputs] : <@matMul_2<[]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>
// CHECK-NEXT:        %[[VAL_361:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_362:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_363:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_364:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_365:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_366:[0-9a-zA-Z_\.]+]] = %[[VAL_364]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_367:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_368:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_366]], %[[VAL_367]])
// CHECK-NEXT:          scf.condition(%[[VAL_368]]) %[[VAL_366]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_369:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_370:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_371:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_372:[0-9a-zA-Z_\.]+]] = %[[VAL_370]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_373:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_374:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_372]], %[[VAL_373]])
// CHECK-NEXT:            scf.condition(%[[VAL_374]]) %[[VAL_372]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_375:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_376:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_377:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_378:[0-9a-zA-Z_\.]+]] = %[[VAL_376]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:              %[[VAL_379:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:              %[[VAL_380:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_378]], %[[VAL_379]])
// CHECK-NEXT:              scf.condition(%[[VAL_380]]) %[[VAL_378]] : !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_381:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_382:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_369]]
// CHECK-NEXT:              %[[VAL_383:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_381]]
// CHECK-NEXT:              %[[VAL_384:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_354]]{{\[}}%[[VAL_382]], %[[VAL_383]]] : <2,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_385:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_369]]
// CHECK-NEXT:              %[[VAL_386:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_375]]
// CHECK-NEXT:              %[[VAL_387:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_358]]{{\[}}%[[VAL_385]], %[[VAL_386]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_388:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_387]][@a] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_389:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_390:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_389]]
// CHECK-NEXT:              %[[VAL_391:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_381]]
// CHECK-NEXT:              %[[VAL_392:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_388]]{{\[}}%[[VAL_390]], %[[VAL_391]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              constrain.eq %[[VAL_392]], %[[VAL_384]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_393:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_381]]
// CHECK-NEXT:              %[[VAL_394:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_375]]
// CHECK-NEXT:              %[[VAL_395:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_355]]{{\[}}%[[VAL_393]], %[[VAL_394]]] : <3,2 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_369]]
// CHECK-NEXT:              %[[VAL_397:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_375]]
// CHECK-NEXT:              %[[VAL_398:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_358]]{{\[}}%[[VAL_396]], %[[VAL_397]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_399:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_398]][@b] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_400:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_401:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_400]]
// CHECK-NEXT:              %[[VAL_402:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_381]]
// CHECK-NEXT:              %[[VAL_403:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_399]]{{\[}}%[[VAL_401]], %[[VAL_402]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              constrain.eq %[[VAL_403]], %[[VAL_395]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_404:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_405:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_381]], %[[VAL_404]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_405]] : !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_406:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_407:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_408:[0-9a-zA-Z_\.]+]] = %[[VAL_406]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:              %[[VAL_409:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:              %[[VAL_410:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_408]], %[[VAL_409]])
// CHECK-NEXT:              scf.condition(%[[VAL_410]]) %[[VAL_408]] : !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_411:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_412:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_369]]
// CHECK-NEXT:              %[[VAL_413:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_375]]
// CHECK-NEXT:              %[[VAL_414:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_357]]{{\[}}%[[VAL_412]], %[[VAL_413]]] : <2,2 x !struct.type<@matElemMul_0<[]>>>, !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:              %[[VAL_415:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_414]][@out] : <@matElemMul_0<[]>>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_416:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_417:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_416]]
// CHECK-NEXT:              %[[VAL_418:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]]
// CHECK-NEXT:              %[[VAL_419:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_415]]{{\[}}%[[VAL_417]], %[[VAL_418]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_420:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_369]]
// CHECK-NEXT:              %[[VAL_421:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_375]]
// CHECK-NEXT:              %[[VAL_422:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_360]]{{\[}}%[[VAL_420]], %[[VAL_421]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_423:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_422]][@a] : <[@a: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:              %[[VAL_424:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_425:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_424]]
// CHECK-NEXT:              %[[VAL_426:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_411]]
// CHECK-NEXT:              %[[VAL_427:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_423]]{{\[}}%[[VAL_425]], %[[VAL_426]]] : <1,3 x !felt.type>, !felt.type
// CHECK-NEXT:              constrain.eq %[[VAL_427]], %[[VAL_419]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_428:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_429:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_411]], %[[VAL_428]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_429]] : !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_430:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_369]]
// CHECK-NEXT:            %[[VAL_431:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_375]]
// CHECK-NEXT:            %[[VAL_432:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_359]]{{\[}}%[[VAL_430]], %[[VAL_431]]] : <2,2 x !struct.type<@matElemSum_1<[]>>>, !struct.type<@matElemSum_1<[]>>
// CHECK-NEXT:            %[[VAL_433:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_432]][@out] : <@matElemSum_1<[]>>, !felt.type
// CHECK-NEXT:            %[[VAL_434:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_369]]
// CHECK-NEXT:            %[[VAL_435:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_375]]
// CHECK-NEXT:            %[[VAL_436:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_356]]{{\[}}%[[VAL_434]], %[[VAL_435]]] : <2,2 x !felt.type>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_436]], %[[VAL_433]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_437:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_438:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_375]], %[[VAL_437]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_438]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_439:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_440:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_369]], %[[VAL_439]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_440]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_441:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_442:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_443:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_444:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        scf.for %[[VAL_445:[0-9a-zA-Z_\.]+]] = %[[VAL_441]] to %[[VAL_443]] step %[[VAL_442]] {
// CHECK-NEXT:          scf.for %[[VAL_446:[0-9a-zA-Z_\.]+]] = %[[VAL_441]] to %[[VAL_444]] step %[[VAL_442]] {
// CHECK-NEXT:            %[[VAL_447:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_357]]{{\[}}%[[VAL_445]], %[[VAL_446]]] : <2,2 x !struct.type<@matElemMul_0<[]>>>, !struct.type<@matElemMul_0<[]>>
// CHECK-NEXT:            %[[VAL_448:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_358]]{{\[}}%[[VAL_445]], %[[VAL_446]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:            %[[VAL_449:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_448]][@a] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:            %[[VAL_450:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_448]][@b] : <[@a: !array.type<1,3 x !felt.type>, @b: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:            function.call @matElemMul_0::@constrain(%[[VAL_447]], %[[VAL_449]], %[[VAL_450]]) : (!struct.type<@matElemMul_0<[]>>, !array.type<1,3 x !felt.type>, !array.type<1,3 x !felt.type>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_451:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_452:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_453:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_454:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        scf.for %[[VAL_455:[0-9a-zA-Z_\.]+]] = %[[VAL_451]] to %[[VAL_453]] step %[[VAL_452]] {
// CHECK-NEXT:          scf.for %[[VAL_456:[0-9a-zA-Z_\.]+]] = %[[VAL_451]] to %[[VAL_454]] step %[[VAL_452]] {
// CHECK-NEXT:            %[[VAL_457:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_359]]{{\[}}%[[VAL_455]], %[[VAL_456]]] : <2,2 x !struct.type<@matElemSum_1<[]>>>, !struct.type<@matElemSum_1<[]>>
// CHECK-NEXT:            %[[VAL_458:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_360]]{{\[}}%[[VAL_455]], %[[VAL_456]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type>]>
// CHECK-NEXT:            %[[VAL_459:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_458]][@a] : <[@a: !array.type<1,3 x !felt.type>]>, !array.type<1,3 x !felt.type>
// CHECK-NEXT:            function.call @matElemSum_1::@constrain(%[[VAL_457]], %[[VAL_459]]) : (!struct.type<@matElemSum_1<[]>>, !array.type<1,3 x !felt.type>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
