// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in;
}

// Returns 1 if in (in binary) > ct
template CompConstant(ct) {
    signal input in[254];
    signal output out;

    signal parts[127];
    signal sout;

    var clsb;
    var cmsb;
    var slsb;
    var smsb;

    var sum=0;

    var b = (1 << 128) -1;
    var a = 1;
    var e = 1;
    var i;

    for (i=0;i<127; i++) {
        clsb = (ct >> (i*2)) & 1;
        cmsb = (ct >> (i*2+1)) & 1;
        slsb = in[i*2];
        smsb = in[i*2+1];

        if ((cmsb==0)&&(clsb==0)) {
            parts[i] <== -b*smsb*slsb + b*smsb + b*slsb;
        } else if ((cmsb==0)&&(clsb==1)) {
            parts[i] <== a*smsb*slsb - a*slsb + b*smsb - a*smsb + a;
        } else if ((cmsb==1)&&(clsb==0)) {
            parts[i] <== b*smsb*slsb - a*smsb + a;
        } else {
            parts[i] <== -a*smsb*slsb + a;
        }

        sum = sum + parts[i];

        b = b -e;
        a = a +e;
        e = e*2;
    }

    sout <== sum;

    component num2bits = Num2Bits(135);
    num2bits.in <== sum;

    out <== num2bits.out[127];
}

template AliasCheck() {
    signal input in[254];

    component compConstant = CompConstant(-1);
    for (var i=0; i<254; i++) in[i] ==> compConstant.in[i];

    compConstant.out === 0;
}

component main = AliasCheck();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@AliasCheck_2<[]>>} {
// CHECK-NEXT:    struct.def @AliasCheck_2<[]> {
// CHECK-NEXT:      struct.member @compConstant : !struct.type<@CompConstant_1<[]>>
// CHECK-NEXT:      struct.member @compConstant$inputs : !pod.type<[@in: !array.type<254 x !felt.type>]>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type>) -> !struct.type<@AliasCheck_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@AliasCheck_2<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = arith.constant 254 : index
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@CompConstant_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<254 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!pod.type<[@in: !array.type<254 x !felt.type>]>, !felt.type) -> (!pod.type<[@in: !array.type<254 x !felt.type>]>, !felt.type) {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  254
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_9]])
// CHECK-NEXT:          scf.condition(%[[VAL_10]]) %[[VAL_7]], %[[VAL_8]] : !pod.type<[@in: !array.type<254 x !felt.type>]>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !pod.type<[@in: !array.type<254 x !felt.type>]>, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]]
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_13]]] : <254 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@in] : <[@in: !array.type<254 x !felt.type>]>, !array.type<254 x !felt.type>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]]
// CHECK-NEXT:          array.write %[[VAL_15]]{{\[}}%[[VAL_16]]] = %[[VAL_14]] : <254 x !felt.type>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_11]][@in] = %[[VAL_15]] : <[@in: !array.type<254 x !felt.type>]>, !array.type<254 x !felt.type>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@count] : <[@count: index, @comp: !struct.type<@CompConstant_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_17]], %[[VAL_18]] : index
// CHECK-NEXT:          pod.write %[[VAL_3]][@count] = %[[VAL_19]] : <[@count: index, @comp: !struct.type<@CompConstant_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_19]], %[[VAL_20]] : index
// CHECK-NEXT:          scf.if %[[VAL_21]] {
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@in] : <[@in: !array.type<254 x !felt.type>]>, !array.type<254 x !felt.type>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @CompConstant_1::@compute(%[[VAL_22]]) : (!array.type<254 x !felt.type>) -> !struct.type<@CompConstant_1<[]>>
// CHECK-NEXT:            pod.write %[[VAL_3]][@comp] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@CompConstant_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@CompConstant_1<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_11]], %[[VAL_25]] : !pod.type<[@in: !array.type<254 x !felt.type>]>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@compConstant$inputs] = %[[VAL_6]]#0 : <@AliasCheck_2<[]>>, !pod.type<[@in: !array.type<254 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@CompConstant_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@CompConstant_1<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_1]][@compConstant] = %[[VAL_26]] : <@AliasCheck_2<[]>>, !struct.type<@CompConstant_1<[]>>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@AliasCheck_2<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@AliasCheck_2<[]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@compConstant] : <@AliasCheck_2<[]>>, !struct.type<@CompConstant_1<[]>>
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@compConstant$inputs] : <@AliasCheck_2<[]>>, !pod.type<[@in: !array.type<254 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_31]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  254
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_33]], %[[VAL_34]])
// CHECK-NEXT:          scf.condition(%[[VAL_35]]) %[[VAL_33]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]]
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_37]]] : <254 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@in] : <[@in: !array.type<254 x !felt.type>]>, !array.type<254 x !felt.type>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]]
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_40]]] : <254 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_41]], %[[VAL_38]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_43]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@CompConstant_1<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        constrain.eq %[[VAL_44]], %[[VAL_45]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@in] : <[@in: !array.type<254 x !felt.type>]>, !array.type<254 x !felt.type>
// CHECK-NEXT:        function.call @CompConstant_1::@constrain(%[[VAL_29]], %[[VAL_46]]) : (!struct.type<@CompConstant_1<[]>>, !array.type<254 x !felt.type>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @CompConstant_1<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.member @parts : !array.type<127 x !felt.type>
// CHECK-NEXT:      struct.member @sout : !felt.type
// CHECK-NEXT:      struct.member @num2bits : !struct.type<@Num2Bits_0<[]>>
// CHECK-NEXT:      struct.member @num2bits$inputs : !pod.type<[@in: !felt.type]>
// CHECK-NEXT:      function.def @compute(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type>) -> !struct.type<@CompConstant_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.new : <@CompConstant_1<[]>>
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<127 x !felt.type>
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_50]] }  : <[@count: index, @comp: !struct.type<@Num2Bits_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type]>
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  340282366920938463463374607431768211455
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]]:9 = scf.while (%[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_60]], %[[VAL_66:[0-9a-zA-Z_\.]+]] = %[[VAL_59]], %[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_54]], %[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_55]], %[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_61]], %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_63]], %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_56]], %[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_58]]) : (!felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  127
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_70]], %[[VAL_74]])
// CHECK-NEXT:          scf.condition(%[[VAL_75]]) %[[VAL_65]], %[[VAL_66]], %[[VAL_67]], %[[VAL_68]], %[[VAL_69]], %[[VAL_70]], %[[VAL_71]], %[[VAL_72]], %[[VAL_73]] : !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_79:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_83:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_81]], %[[VAL_86]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_85]], %[[VAL_87]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_88]], %[[VAL_89]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_81]], %[[VAL_92]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_93]], %[[VAL_94]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_91]], %[[VAL_95]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_96]], %[[VAL_97]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_81]], %[[VAL_99]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]]
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_101]]] : <254 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_81]], %[[VAL_103]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_104]], %[[VAL_105]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]]
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_107]]] : <254 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_98]], %[[VAL_109]])
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_90]], %[[VAL_111]])
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_110]], %[[VAL_112]] : i1, i1
// CHECK-NEXT:          scf.if %[[VAL_113]] {
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_77]] : !felt.type
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_114]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_115]], %[[VAL_102]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_77]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_116]], %[[VAL_117]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_77]], %[[VAL_102]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_118]], %[[VAL_119]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]]
// CHECK-NEXT:            array.write %[[VAL_49]]{{\[}}%[[VAL_121]]] = %[[VAL_120]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_98]], %[[VAL_122]])
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_90]], %[[VAL_124]])
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_123]], %[[VAL_125]] : i1, i1
// CHECK-NEXT:            scf.if %[[VAL_126]] {
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_76]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_127]], %[[VAL_102]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_76]], %[[VAL_102]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_128]], %[[VAL_129]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_77]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_130]], %[[VAL_131]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_76]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_132]], %[[VAL_133]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_134]], %[[VAL_76]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]]
// CHECK-NEXT:              array.write %[[VAL_49]]{{\[}}%[[VAL_136]]] = %[[VAL_135]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_90]], %[[VAL_138]])
// CHECK-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_137]], %[[VAL_140]])
// CHECK-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_141]], %[[VAL_139]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_142]] {
// CHECK-NEXT:                %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_77]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_143]], %[[VAL_102]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_76]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_144]], %[[VAL_145]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_146]], %[[VAL_76]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]]
// CHECK-NEXT:                array.write %[[VAL_49]]{{\[}}%[[VAL_148]]] = %[[VAL_147]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_76]] : !felt.type
// CHECK-NEXT:                %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_149]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_150]], %[[VAL_102]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_151]], %[[VAL_76]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_153:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]]
// CHECK-NEXT:                array.write %[[VAL_49]]{{\[}}%[[VAL_153]]] = %[[VAL_152]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]]
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_49]]{{\[}}%[[VAL_154]]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_155]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_77]], %[[VAL_80]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_76]], %[[VAL_80]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_80]], %[[VAL_159]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_81]], %[[VAL_161]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_158]], %[[VAL_157]], %[[VAL_90]], %[[VAL_98]], %[[VAL_160]], %[[VAL_162]], %[[VAL_102]], %[[VAL_108]], %[[VAL_156]] : !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_48]][@sout] = %[[VAL_64]]#8 : <@CompConstant_1<[]>>, !felt.type
// CHECK-NEXT:        pod.write %[[VAL_52]][@in] = %[[VAL_64]]#8 : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_165:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_163]], %[[VAL_164]] : index
// CHECK-NEXT:        pod.write %[[VAL_51]][@count] = %[[VAL_165]] : <[@count: index, @comp: !struct.type<@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_166:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_165]], %[[VAL_166]] : index
// CHECK-NEXT:        scf.if %[[VAL_167]] {
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits_0::@compute(%[[VAL_168]]) : (!felt.type) -> !struct.type<@Num2Bits_0<[]>>
// CHECK-NEXT:          pod.write %[[VAL_51]][@comp] = %[[VAL_169]] : <[@count: index, @comp: !struct.type<@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits_0<[]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits_0<[]>>
// CHECK-NEXT:        %[[VAL_171:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_170]][@out] : <@Num2Bits_0<[]>>, !array.type<135 x !felt.type>
// CHECK-NEXT:        %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  127
// CHECK-NEXT:        %[[VAL_173:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]]
// CHECK-NEXT:        %[[VAL_174:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_171]]{{\[}}%[[VAL_173]]] : <135 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_48]][@out] = %[[VAL_174]] : <@CompConstant_1<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_48]][@num2bits$inputs] = %[[VAL_52]] : <@CompConstant_1<[]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:        %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits_0<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_48]][@num2bits] = %[[VAL_175]] : <@CompConstant_1<[]>>, !struct.type<@Num2Bits_0<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_48]][@parts] = %[[VAL_49]] : <@CompConstant_1<[]>>, !array.type<127 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_48]] : !struct.type<@CompConstant_1<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_176:[0-9a-zA-Z_\.]+]]: !struct.type<@CompConstant_1<[]>>, %[[VAL_177:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_178:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@out] : <@CompConstant_1<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_179:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@parts] : <@CompConstant_1<[]>>, !array.type<127 x !felt.type>
// CHECK-NEXT:        %[[VAL_180:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@sout] : <@CompConstant_1<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_181:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@num2bits] : <@CompConstant_1<[]>>, !struct.type<@Num2Bits_0<[]>>
// CHECK-NEXT:        %[[VAL_182:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@num2bits$inputs] : <@CompConstant_1<[]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:        %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616
// CHECK-NEXT:        %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.const  340282366920938463463374607431768211455
// CHECK-NEXT:        %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_194:[0-9a-zA-Z_\.]+]]:9 = scf.while (%[[VAL_195:[0-9a-zA-Z_\.]+]] = %[[VAL_190]], %[[VAL_196:[0-9a-zA-Z_\.]+]] = %[[VAL_189]], %[[VAL_197:[0-9a-zA-Z_\.]+]] = %[[VAL_184]], %[[VAL_198:[0-9a-zA-Z_\.]+]] = %[[VAL_185]], %[[VAL_199:[0-9a-zA-Z_\.]+]] = %[[VAL_191]], %[[VAL_200:[0-9a-zA-Z_\.]+]] = %[[VAL_193]], %[[VAL_201:[0-9a-zA-Z_\.]+]] = %[[VAL_186]], %[[VAL_202:[0-9a-zA-Z_\.]+]] = %[[VAL_187]], %[[VAL_203:[0-9a-zA-Z_\.]+]] = %[[VAL_188]]) : (!felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  127
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_200]], %[[VAL_204]])
// CHECK-NEXT:          scf.condition(%[[VAL_205]]) %[[VAL_195]], %[[VAL_196]], %[[VAL_197]], %[[VAL_198]], %[[VAL_199]], %[[VAL_200]], %[[VAL_201]], %[[VAL_202]], %[[VAL_203]] : !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_206:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_207:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_208:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_209:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_210:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_211:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_212:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_213:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_214:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_211]], %[[VAL_216]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_215]], %[[VAL_217]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_218]], %[[VAL_219]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_211]], %[[VAL_222]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_223]], %[[VAL_224]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_221]], %[[VAL_225]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_226]], %[[VAL_227]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_211]], %[[VAL_229]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_230]]
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_231]]] : <254 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_211]], %[[VAL_233]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_234]], %[[VAL_235]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_236]]
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_237]]] : <254 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_228]], %[[VAL_239]])
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_220]], %[[VAL_241]])
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_240]], %[[VAL_242]] : i1, i1
// CHECK-NEXT:          scf.if %[[VAL_243]] {
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_207]] : !felt.type
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_244]], %[[VAL_238]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_245]], %[[VAL_232]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_207]], %[[VAL_238]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_246]], %[[VAL_247]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_207]], %[[VAL_232]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_248]], %[[VAL_249]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_251:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]]
// CHECK-NEXT:            %[[VAL_252:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_251]]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_252]], %[[VAL_250]] : !felt.type, !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_228]], %[[VAL_253]])
// CHECK-NEXT:            %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_256:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_220]], %[[VAL_255]])
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_254]], %[[VAL_256]] : i1, i1
// CHECK-NEXT:            scf.if %[[VAL_257]] {
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_206]], %[[VAL_238]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_258]], %[[VAL_232]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_260:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_206]], %[[VAL_232]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_261:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_259]], %[[VAL_260]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_207]], %[[VAL_238]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_261]], %[[VAL_262]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_264:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_206]], %[[VAL_238]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_265:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_263]], %[[VAL_264]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_266:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_265]], %[[VAL_206]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]]
// CHECK-NEXT:              %[[VAL_268:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_267]]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:              constrain.eq %[[VAL_268]], %[[VAL_266]] : !felt.type, !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_220]], %[[VAL_270]])
// CHECK-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_269]], %[[VAL_272]])
// CHECK-NEXT:              %[[VAL_274:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_273]], %[[VAL_271]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_274]] {
// CHECK-NEXT:                %[[VAL_275:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_207]], %[[VAL_238]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_276:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_275]], %[[VAL_232]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_206]], %[[VAL_238]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_278:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_276]], %[[VAL_277]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_279:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_278]], %[[VAL_206]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_280:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]]
// CHECK-NEXT:                %[[VAL_281:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_280]]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:                constrain.eq %[[VAL_281]], %[[VAL_279]] : !felt.type, !felt.type
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_282:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_206]] : !felt.type
// CHECK-NEXT:                %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_282]], %[[VAL_238]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_284:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_283]], %[[VAL_232]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_285:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_284]], %[[VAL_206]] : !felt.type, !felt.type
// CHECK-NEXT:                %[[VAL_286:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]]
// CHECK-NEXT:                %[[VAL_287:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_286]]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:                constrain.eq %[[VAL_287]], %[[VAL_285]] : !felt.type, !felt.type
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_288:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]]
// CHECK-NEXT:          %[[VAL_289:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_288]]] : <127 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_214]], %[[VAL_289]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_207]], %[[VAL_210]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_206]], %[[VAL_210]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_210]], %[[VAL_293]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_295:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_211]], %[[VAL_295]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_292]], %[[VAL_291]], %[[VAL_220]], %[[VAL_228]], %[[VAL_294]], %[[VAL_296]], %[[VAL_232]], %[[VAL_238]], %[[VAL_290]] : !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_180]], %[[VAL_194]]#8 : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_297:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_297]], %[[VAL_194]]#8 : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_298:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_181]][@out] : <@Num2Bits_0<[]>>, !array.type<135 x !felt.type>
// CHECK-NEXT:        %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.const  127
// CHECK-NEXT:        %[[VAL_300:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_299]]
// CHECK-NEXT:        %[[VAL_301:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_298]]{{\[}}%[[VAL_300]]] : <135 x !felt.type>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_178]], %[[VAL_301]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_302:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @Num2Bits_0::@constrain(%[[VAL_181]], %[[VAL_302]]) : (!struct.type<@Num2Bits_0<[]>>, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Num2Bits_0<[]> {
// CHECK-NEXT:      struct.member @out : !array.type<135 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_303:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Num2Bits_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_304:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits_0<[]>>
// CHECK-NEXT:        %[[VAL_305:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<135 x !felt.type>
// CHECK-NEXT:        %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.const  135
// CHECK-NEXT:        %[[VAL_307:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_310:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_311:[0-9a-zA-Z_\.]+]] = %[[VAL_308]], %[[VAL_312:[0-9a-zA-Z_\.]+]] = %[[VAL_309]], %[[VAL_313:[0-9a-zA-Z_\.]+]] = %[[VAL_307]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_314:[0-9a-zA-Z_\.]+]] = felt.const  135
// CHECK-NEXT:          %[[VAL_315:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_312]], %[[VAL_314]])
// CHECK-NEXT:          scf.condition(%[[VAL_315]]) %[[VAL_311]], %[[VAL_312]], %[[VAL_313]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_316:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_317:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_318:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_319:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_303]], %[[VAL_317]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_321:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_319]], %[[VAL_320]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_317]]
// CHECK-NEXT:          array.write %[[VAL_305]]{{\[}}%[[VAL_322]]] = %[[VAL_321]] : <135 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_317]]
// CHECK-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_305]]{{\[}}%[[VAL_323]]] : <135 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_324]], %[[VAL_308]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_318]], %[[VAL_325]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_327:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_316]], %[[VAL_316]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_317]], %[[VAL_328]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_327]], %[[VAL_329]], %[[VAL_326]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_304]][@out] = %[[VAL_305]] : <@Num2Bits_0<[]>>, !array.type<135 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_304]] : !struct.type<@Num2Bits_0<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_330:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits_0<[]>>, %[[VAL_331:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_332:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_330]][@out] : <@Num2Bits_0<[]>>, !array.type<135 x !felt.type>
// CHECK-NEXT:        %[[VAL_333:[0-9a-zA-Z_\.]+]] = felt.const  135
// CHECK-NEXT:        %[[VAL_334:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_335:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_336:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_337:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_338:[0-9a-zA-Z_\.]+]] = %[[VAL_335]], %[[VAL_339:[0-9a-zA-Z_\.]+]] = %[[VAL_336]], %[[VAL_340:[0-9a-zA-Z_\.]+]] = %[[VAL_334]]) : (!felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_341:[0-9a-zA-Z_\.]+]] = felt.const  135
// CHECK-NEXT:          %[[VAL_342:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_339]], %[[VAL_341]])
// CHECK-NEXT:          scf.condition(%[[VAL_342]]) %[[VAL_338]], %[[VAL_339]], %[[VAL_340]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_343:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_344:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_345:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_344]]
// CHECK-NEXT:          %[[VAL_347:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_332]]{{\[}}%[[VAL_346]]] : <135 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_348:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_344]]
// CHECK-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_332]]{{\[}}%[[VAL_348]]] : <135 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_349]], %[[VAL_350]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_352:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_347]], %[[VAL_351]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          constrain.eq %[[VAL_352]], %[[VAL_353]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_344]]
// CHECK-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_332]]{{\[}}%[[VAL_354]]] : <135 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_355]], %[[VAL_335]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_345]], %[[VAL_356]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_358:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_343]], %[[VAL_343]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_359:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_344]], %[[VAL_359]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_358]], %[[VAL_360]], %[[VAL_357]] : !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_337]]#2, %[[VAL_331]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
