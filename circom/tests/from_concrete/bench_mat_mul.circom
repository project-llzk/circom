// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@matMul_2::@matMul_2<[]>>} {
// CHECK-NEXT:    poly.template @matElemMul_0 {
// CHECK-NEXT:      struct.def @matElemMul_0 {
// CHECK-NEXT:        struct.member @out : !array.type<1,3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type<"bn128">> {function.arg_name = "b"}) -> !struct.type<@matElemMul_0::@matElemMul_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_9]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_10]]) %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_12]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_15]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_16]]) %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_19]], %[[VAL_20]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_23]], %[[VAL_24]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_21]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_28]], %[[VAL_29]]] = %[[VAL_26]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@matElemMul_0::@matElemMul_0<[]>>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type<"bn128">> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@out] : <@matElemMul_0::@matElemMul_0<[]>>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_39]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_43]]) %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_47:[0-9a-zA-Z_\.]+]] = %[[VAL_45]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_47]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_49]]) %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_50:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_52]], %[[VAL_53]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_56]], %[[VAL_57]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_54]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_61]], %[[VAL_62]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_63]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_50]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @matElemSum_1 {
// CHECK-NEXT:      struct.def @matElemSum_1 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @sum : !array.type<3 x !felt.type<"bn128">> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@matElemSum_1::@matElemSum_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.new : <@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_73]], %[[VAL_75]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_69]]{{\[}}%[[VAL_78]]] = %[[VAL_76]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_80]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_79]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_84]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_85]]) %[[VAL_82]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_87]], %[[VAL_91:[0-9a-zA-Z_\.]+]] = %[[VAL_88]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_91]], %[[VAL_92]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_93]]) %[[VAL_90]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_94:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_95:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_94]], %[[VAL_96]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.if %[[VAL_97]] {
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_94]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_99]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_100]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_103]], %[[VAL_104]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_101]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_69]]{{\[}}%[[VAL_107]]] = %[[VAL_106]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_94]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_95]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_109]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_112]], %[[VAL_89]]#0 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_114]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_68]][@out] = %[[VAL_115]] : <@matElemSum_1::@matElemSum_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_68]][@sum] = %[[VAL_69]] : <@matElemSum_1::@matElemSum_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_68]] : !struct.type<@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_116:[0-9a-zA-Z_\.]+]]: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, %[[VAL_117:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_116]][@out] : <@matElemSum_1::@matElemSum_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_116]][@sum] : <@matElemSum_1::@matElemSum_1<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_123]], %[[VAL_125]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_128]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_129]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_131]], %[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_130]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_133]], %[[VAL_135]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_136]]) %[[VAL_133]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_137:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_141:[0-9a-zA-Z_\.]+]] = %[[VAL_138]], %[[VAL_142:[0-9a-zA-Z_\.]+]] = %[[VAL_139]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_142]], %[[VAL_143]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_144]]) %[[VAL_141]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_145:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_146:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_148:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_145]], %[[VAL_147]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.if %[[VAL_148]] {
// CHECK-NEXT:                %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_145]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_150]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_152:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_151]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_146]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_154]], %[[VAL_155]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_152]], %[[VAL_156]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_158]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_159]], %[[VAL_157]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_145]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_146]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_161]], %[[VAL_163]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_164]], %[[VAL_140]]#0 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_165]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_166]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_118]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @matMul_2 {
// CHECK-NEXT:      struct.def @matMul_2 {
// CHECK-NEXT:        struct.member @out : !array.type<2,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @matElemMulComp : !array.type<2,2 x !struct.type<@matElemMul_0::@matElemMul_0<[]>>>
// CHECK-NEXT:        struct.member @matElemMulComp$inputs : !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        struct.member @matElemSumComp : !array.type<2,2 x !struct.type<@matElemSum_1::@matElemSum_1<[]>>>
// CHECK-NEXT:        struct.member @matElemSumComp$inputs : !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_168:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_169:[0-9a-zA-Z_\.]+]]: !array.type<3,2 x !felt.type<"bn128">> {function.arg_name = "b"}) -> !struct.type<@matMul_2::@matMul_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = struct.new : <@matMul_2::@matMul_2<[]>>
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_178:[0-9a-zA-Z_\.]+]] = %[[VAL_176]] to %[[VAL_174]] step %[[VAL_177]] {
// CHECK-NEXT:            scf.for %[[VAL_179:[0-9a-zA-Z_\.]+]] = %[[VAL_176]] to %[[VAL_175]] step %[[VAL_177]] {
// CHECK-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:              %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_180]], @params = %[[VAL_173]] }  : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              array.write %[[VAL_172]]{{\[}}%[[VAL_178]], %[[VAL_179]]] = %[[VAL_181]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_189:[0-9a-zA-Z_\.]+]] = %[[VAL_187]] to %[[VAL_185]] step %[[VAL_188]] {
// CHECK-NEXT:            scf.for %[[VAL_190:[0-9a-zA-Z_\.]+]] = %[[VAL_187]] to %[[VAL_186]] step %[[VAL_188]] {
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_191]], @params = %[[VAL_184]] }  : <[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              array.write %[[VAL_183]]{{\[}}%[[VAL_189]], %[[VAL_190]]] = %[[VAL_192]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]]:5 = scf.while (%[[VAL_199:[0-9a-zA-Z_\.]+]] = %[[VAL_197]], %[[VAL_200:[0-9a-zA-Z_\.]+]] = %[[VAL_172]], %[[VAL_201:[0-9a-zA-Z_\.]+]] = %[[VAL_182]], %[[VAL_202:[0-9a-zA-Z_\.]+]] = %[[VAL_183]], %[[VAL_203:[0-9a-zA-Z_\.]+]] = %[[VAL_193]]) : (!felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_199]], %[[VAL_204]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_205]]) %[[VAL_199]], %[[VAL_200]], %[[VAL_201]], %[[VAL_202]], %[[VAL_203]] : !felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_206:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_207:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_208:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, %[[VAL_209:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, %[[VAL_210:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]]:5 = scf.while (%[[VAL_213:[0-9a-zA-Z_\.]+]] = %[[VAL_211]], %[[VAL_214:[0-9a-zA-Z_\.]+]] = %[[VAL_207]], %[[VAL_215:[0-9a-zA-Z_\.]+]] = %[[VAL_208]], %[[VAL_216:[0-9a-zA-Z_\.]+]] = %[[VAL_209]], %[[VAL_217:[0-9a-zA-Z_\.]+]] = %[[VAL_210]]) : (!felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:              %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_219:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_213]], %[[VAL_218]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_219]]) %[[VAL_213]], %[[VAL_214]], %[[VAL_215]], %[[VAL_216]], %[[VAL_217]] : !felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_220:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_221:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_222:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, %[[VAL_223:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, %[[VAL_224:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_227:[0-9a-zA-Z_\.]+]] = %[[VAL_225]], %[[VAL_228:[0-9a-zA-Z_\.]+]] = %[[VAL_221]], %[[VAL_229:[0-9a-zA-Z_\.]+]] = %[[VAL_222]]) : (!felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:                %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:                %[[VAL_231:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_227]], %[[VAL_230]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_231]]) %[[VAL_227]], %[[VAL_228]], %[[VAL_229]] : !felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_232:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_233:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, %[[VAL_234:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:                %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_236:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_237:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_168]]{{\[}}%[[VAL_235]], %[[VAL_236]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_239:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_240:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_238]], %[[VAL_239]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_241:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_240]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_242:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_243:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_242]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_244:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_241]]{{\[}}%[[VAL_243]], %[[VAL_244]]] = %[[VAL_237]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_247:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_245]], %[[VAL_246]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_247]][@a] = %[[VAL_241]] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_248:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_249:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_234]]{{\[}}%[[VAL_248]], %[[VAL_249]]] = %[[VAL_247]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_251:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_252:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_233]]{{\[}}%[[VAL_250]], %[[VAL_251]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_253:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_254:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_255:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_253]], %[[VAL_254]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_256:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@count] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_257:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_258:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_256]], %[[VAL_257]] : index
// CHECK-NEXT:                pod.write %[[VAL_252]][@count] = %[[VAL_258]] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_259:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_260:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_258]], %[[VAL_259]] : index
// CHECK-NEXT:                scf.if %[[VAL_260]] {
// CHECK-NEXT:                  %[[VAL_261:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@params] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_255]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_263:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_255]][@b] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_264:[0-9a-zA-Z_\.]+]] = function.call @matElemMul_0::@matElemMul_0::@compute(%[[VAL_262]], %[[VAL_263]]) : (!array.type<1,3 x !felt.type<"bn128">>, !array.type<1,3 x !felt.type<"bn128">>) -> !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_252]][@comp] = %[[VAL_264]] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_266:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_233]]{{\[}}%[[VAL_265]], %[[VAL_266]]] = %[[VAL_252]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_268:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_269:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_267]], %[[VAL_268]]] : <3,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_270:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_270]], %[[VAL_271]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_273:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_272]][@b] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_275:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_274]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_276:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_273]]{{\[}}%[[VAL_275]], %[[VAL_276]]] = %[[VAL_269]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_277:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_278:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_279:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_277]], %[[VAL_278]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_279]][@b] = %[[VAL_273]] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_280:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_281:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_234]]{{\[}}%[[VAL_280]], %[[VAL_281]]] = %[[VAL_279]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_282:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_283:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_284:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_233]]{{\[}}%[[VAL_282]], %[[VAL_283]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_285:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_286:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_287:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_285]], %[[VAL_286]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_288:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_284]][@count] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_289:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_290:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_288]], %[[VAL_289]] : index
// CHECK-NEXT:                pod.write %[[VAL_284]][@count] = %[[VAL_290]] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_291:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_292:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_290]], %[[VAL_291]] : index
// CHECK-NEXT:                scf.if %[[VAL_292]] {
// CHECK-NEXT:                  %[[VAL_293:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_284]][@params] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_287]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_295:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_287]][@b] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_296:[0-9a-zA-Z_\.]+]] = function.call @matElemMul_0::@matElemMul_0::@compute(%[[VAL_294]], %[[VAL_295]]) : (!array.type<1,3 x !felt.type<"bn128">>, !array.type<1,3 x !felt.type<"bn128">>) -> !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_284]][@comp] = %[[VAL_296]] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_298:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_233]]{{\[}}%[[VAL_297]], %[[VAL_298]]] = %[[VAL_284]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_232]], %[[VAL_299]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_300]], %[[VAL_233]], %[[VAL_234]] : !felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_301:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_302:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_303:[0-9a-zA-Z_\.]+]] = %[[VAL_301]], %[[VAL_304:[0-9a-zA-Z_\.]+]] = %[[VAL_223]], %[[VAL_305:[0-9a-zA-Z_\.]+]] = %[[VAL_224]]) : (!felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:                %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:                %[[VAL_307:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_303]], %[[VAL_306]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_307]]) %[[VAL_303]], %[[VAL_304]], %[[VAL_305]] : !felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_308:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_309:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, %[[VAL_310:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:                %[[VAL_311:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_312:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_313:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_226]]#1{{\[}}%[[VAL_311]], %[[VAL_312]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_314:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_313]][@comp] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:                %[[VAL_315:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_314]][@out] : <@matElemMul_0::@matElemMul_0<[]>>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_316:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_317:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_316]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_318:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_308]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_319:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_315]]{{\[}}%[[VAL_317]], %[[VAL_318]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_320:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_322:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_310]]{{\[}}%[[VAL_320]], %[[VAL_321]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_323:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_322]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_324]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_326:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_308]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_323]]{{\[}}%[[VAL_325]], %[[VAL_326]]] = %[[VAL_319]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_327:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_328:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_329:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_310]]{{\[}}%[[VAL_327]], %[[VAL_328]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_329]][@a] = %[[VAL_323]] : <[@a: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_330:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_331:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_310]]{{\[}}%[[VAL_330]], %[[VAL_331]]] = %[[VAL_329]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_332:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_333:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_334:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_309]]{{\[}}%[[VAL_332]], %[[VAL_333]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_335:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_336:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_337:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_310]]{{\[}}%[[VAL_335]], %[[VAL_336]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_338:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_334]][@count] : <[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_339:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_340:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_338]], %[[VAL_339]] : index
// CHECK-NEXT:                pod.write %[[VAL_334]][@count] = %[[VAL_340]] : <[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_341:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_342:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_340]], %[[VAL_341]] : index
// CHECK-NEXT:                scf.if %[[VAL_342]] {
// CHECK-NEXT:                  %[[VAL_343:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_334]][@params] : <[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_344:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_337]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_345:[0-9a-zA-Z_\.]+]] = function.call @matElemSum_1::@matElemSum_1::@compute(%[[VAL_344]]) : (!array.type<1,3 x !felt.type<"bn128">>) -> !struct.type<@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_334]][@comp] = %[[VAL_345]] : <[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_346:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_347:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_309]]{{\[}}%[[VAL_346]], %[[VAL_347]]] = %[[VAL_334]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_349:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_308]], %[[VAL_348]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_349]], %[[VAL_309]], %[[VAL_310]] : !felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_350:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_351:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_352:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_302]]#1{{\[}}%[[VAL_350]], %[[VAL_351]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_353:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_352]][@comp] : <[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:              %[[VAL_354:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_353]][@out] : <@matElemSum_1::@matElemSum_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_355:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_356:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_171]]{{\[}}%[[VAL_355]], %[[VAL_356]]] = %[[VAL_354]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_357:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_358:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_220]], %[[VAL_357]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_358]], %[[VAL_226]]#1, %[[VAL_226]]#2, %[[VAL_302]]#1, %[[VAL_302]]#2 : !felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_359:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_206]], %[[VAL_359]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_360]], %[[VAL_212]]#1, %[[VAL_212]]#2, %[[VAL_212]]#3, %[[VAL_212]]#4 : !felt.type<"bn128">, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !array.type<2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_170]][@matElemMulComp$inputs] = %[[VAL_198]]#2 : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_361:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !struct.type<@matElemMul_0::@matElemMul_0<[]>>>
// CHECK-NEXT:          %[[VAL_362:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_363:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_364:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_365:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_366:[0-9a-zA-Z_\.]+]] = %[[VAL_364]] to %[[VAL_362]] step %[[VAL_365]] {
// CHECK-NEXT:            scf.for %[[VAL_367:[0-9a-zA-Z_\.]+]] = %[[VAL_364]] to %[[VAL_363]] step %[[VAL_365]] {
// CHECK-NEXT:              %[[VAL_368:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_198]]#1{{\[}}%[[VAL_366]], %[[VAL_367]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_369:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_368]][@comp] : <[@count: index, @comp: !struct.type<@matElemMul_0::@matElemMul_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:              array.write %[[VAL_361]]{{\[}}%[[VAL_366]], %[[VAL_367]]] = %[[VAL_369]] : <2,2 x !struct.type<@matElemMul_0::@matElemMul_0<[]>>>, !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_170]][@matElemMulComp] = %[[VAL_361]] : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !struct.type<@matElemMul_0::@matElemMul_0<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_170]][@matElemSumComp$inputs] = %[[VAL_198]]#4 : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_370:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !struct.type<@matElemSum_1::@matElemSum_1<[]>>>
// CHECK-NEXT:          %[[VAL_371:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_373:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_374:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_375:[0-9a-zA-Z_\.]+]] = %[[VAL_373]] to %[[VAL_371]] step %[[VAL_374]] {
// CHECK-NEXT:            scf.for %[[VAL_376:[0-9a-zA-Z_\.]+]] = %[[VAL_373]] to %[[VAL_372]] step %[[VAL_374]] {
// CHECK-NEXT:              %[[VAL_377:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_198]]#3{{\[}}%[[VAL_375]], %[[VAL_376]]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_378:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_377]][@comp] : <[@count: index, @comp: !struct.type<@matElemSum_1::@matElemSum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:              array.write %[[VAL_370]]{{\[}}%[[VAL_375]], %[[VAL_376]]] = %[[VAL_378]] : <2,2 x !struct.type<@matElemSum_1::@matElemSum_1<[]>>>, !struct.type<@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_170]][@matElemSumComp] = %[[VAL_370]] : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !struct.type<@matElemSum_1::@matElemSum_1<[]>>>
// CHECK-NEXT:          struct.writem %[[VAL_170]][@out] = %[[VAL_171]] : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_170]] : !struct.type<@matMul_2::@matMul_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_379:[0-9a-zA-Z_\.]+]]: !struct.type<@matMul_2::@matMul_2<[]>>, %[[VAL_380:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_381:[0-9a-zA-Z_\.]+]]: !array.type<3,2 x !felt.type<"bn128">> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_382:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_379]][@out] : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_383:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_379]][@matElemMulComp] : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !struct.type<@matElemMul_0::@matElemMul_0<[]>>>
// CHECK-NEXT:          %[[VAL_384:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_379]][@matElemMulComp$inputs] : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_385:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_379]][@matElemSumComp] : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !struct.type<@matElemSum_1::@matElemSum_1<[]>>>
// CHECK-NEXT:          %[[VAL_386:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_379]][@matElemSumComp$inputs] : <@matMul_2::@matMul_2<[]>>, !array.type<2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_387:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_388:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_389:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_390:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_391:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_392:[0-9a-zA-Z_\.]+]] = %[[VAL_390]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_393:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_394:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_392]], %[[VAL_393]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_394]]) %[[VAL_392]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_395:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_396:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_397:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_398:[0-9a-zA-Z_\.]+]] = %[[VAL_396]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_399:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_400:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_398]], %[[VAL_399]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_400]]) %[[VAL_398]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_401:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_402:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_403:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_404:[0-9a-zA-Z_\.]+]] = %[[VAL_402]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_405:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:                %[[VAL_406:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_404]], %[[VAL_405]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_406]]) %[[VAL_404]] : !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_407:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_408:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_409:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_407]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_410:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_380]]{{\[}}%[[VAL_408]], %[[VAL_409]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_411:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_412:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_401]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_413:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_384]]{{\[}}%[[VAL_411]], %[[VAL_412]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_414:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_413]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_415:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_416:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_415]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_417:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_407]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_418:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_414]]{{\[}}%[[VAL_416]], %[[VAL_417]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_418]], %[[VAL_410]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_419:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_407]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_420:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_401]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_421:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_381]]{{\[}}%[[VAL_419]], %[[VAL_420]]] : <3,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_422:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_423:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_401]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_424:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_384]]{{\[}}%[[VAL_422]], %[[VAL_423]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_425:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_424]][@b] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_426:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_427:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_426]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_428:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_407]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_429:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_425]]{{\[}}%[[VAL_427]], %[[VAL_428]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_429]], %[[VAL_421]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_430:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_431:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_407]], %[[VAL_430]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_431]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_432:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_433:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_434:[0-9a-zA-Z_\.]+]] = %[[VAL_432]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_435:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:                %[[VAL_436:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_434]], %[[VAL_435]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_436]]) %[[VAL_434]] : !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_437:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_438:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_439:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_401]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_440:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_383]]{{\[}}%[[VAL_438]], %[[VAL_439]]] : <2,2 x !struct.type<@matElemMul_0::@matElemMul_0<[]>>>, !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:                %[[VAL_441:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_440]][@out] : <@matElemMul_0::@matElemMul_0<[]>>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_442:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_443:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_442]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_444:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_437]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_445:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_441]]{{\[}}%[[VAL_443]], %[[VAL_444]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_446:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_447:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_401]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_448:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_386]]{{\[}}%[[VAL_446]], %[[VAL_447]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_449:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_448]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_450:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_451:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_450]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_452:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_437]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_453:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_449]]{{\[}}%[[VAL_451]], %[[VAL_452]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_453]], %[[VAL_445]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_454:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_455:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_437]], %[[VAL_454]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_455]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_456:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_457:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_401]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_458:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_385]]{{\[}}%[[VAL_456]], %[[VAL_457]]] : <2,2 x !struct.type<@matElemSum_1::@matElemSum_1<[]>>>, !struct.type<@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:              %[[VAL_459:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_458]][@out] : <@matElemSum_1::@matElemSum_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_460:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_395]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_461:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_401]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_462:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_382]]{{\[}}%[[VAL_460]], %[[VAL_461]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_462]], %[[VAL_459]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_463:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_464:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_401]], %[[VAL_463]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_464]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_465:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_466:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_395]], %[[VAL_465]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_466]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_467:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_468:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_469:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_470:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_471:[0-9a-zA-Z_\.]+]] = %[[VAL_469]] to %[[VAL_467]] step %[[VAL_470]] {
// CHECK-NEXT:            scf.for %[[VAL_472:[0-9a-zA-Z_\.]+]] = %[[VAL_469]] to %[[VAL_468]] step %[[VAL_470]] {
// CHECK-NEXT:              %[[VAL_473:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_383]]{{\[}}%[[VAL_471]], %[[VAL_472]]] : <2,2 x !struct.type<@matElemMul_0::@matElemMul_0<[]>>>, !struct.type<@matElemMul_0::@matElemMul_0<[]>>
// CHECK-NEXT:              %[[VAL_474:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_384]]{{\[}}%[[VAL_471]], %[[VAL_472]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_475:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_474]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_476:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_474]][@b] : <[@a: !array.type<1,3 x !felt.type<"bn128">>, @b: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:              function.call @matElemMul_0::@matElemMul_0::@constrain(%[[VAL_473]], %[[VAL_475]], %[[VAL_476]]) : (!struct.type<@matElemMul_0::@matElemMul_0<[]>>, !array.type<1,3 x !felt.type<"bn128">>, !array.type<1,3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_477:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_478:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_479:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_480:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_481:[0-9a-zA-Z_\.]+]] = %[[VAL_479]] to %[[VAL_477]] step %[[VAL_480]] {
// CHECK-NEXT:            scf.for %[[VAL_482:[0-9a-zA-Z_\.]+]] = %[[VAL_479]] to %[[VAL_478]] step %[[VAL_480]] {
// CHECK-NEXT:              %[[VAL_483:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_385]]{{\[}}%[[VAL_481]], %[[VAL_482]]] : <2,2 x !struct.type<@matElemSum_1::@matElemSum_1<[]>>>, !struct.type<@matElemSum_1::@matElemSum_1<[]>>
// CHECK-NEXT:              %[[VAL_484:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_386]]{{\[}}%[[VAL_481]], %[[VAL_482]]] : <2,2 x !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<1,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_485:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_484]][@a] : <[@a: !array.type<1,3 x !felt.type<"bn128">>]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:              function.call @matElemSum_1::@matElemSum_1::@constrain(%[[VAL_483]], %[[VAL_485]]) : (!struct.type<@matElemSum_1::@matElemSum_1<[]>>, !array.type<1,3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
