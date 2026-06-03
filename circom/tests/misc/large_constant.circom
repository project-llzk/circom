// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

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

    num2bits.in <== sout;

    out <== num2bits.out[127];
}

template Sign() {
    signal input in[254];
    signal output sign;

    component comp = CompConstant(10944121435919637611123202872628637544274182200208017171849102093287904247808);

    var i;

    for (i=0; i<254; i++) {
        comp.in[i] <== in[i];
    }

    sign <== comp.out;
}

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

template IsNegative() {
    signal input in;
    signal output out;

    component num2Bits = Num2Bits(254);
    num2Bits.in <== in;
    component sign = Sign();

    for (var i = 0; i < 254; i++) {
        sign.in[i] <== num2Bits.out[i];
    }

    out <== sign.sign;
}

component main = IsNegative();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@IsNegative::@IsNegative<[]>>} {
// CHECK-NEXT:    poly.template @CompConstant {
// CHECK-NEXT:      poly.param @ct
// CHECK-NEXT:      struct.def @CompConstant {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @parts : !array.type<127 x !felt.type<"bn128">>
// CHECK-NEXT:        struct.member @sout : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @num2bits : !struct.type<@Num2Bits::@Num2Bits<[135]>>
// CHECK-NEXT:        struct.member @num2bits$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@CompConstant::@CompConstant<[@ct]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@CompConstant::@CompConstant<[@ct]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @ct : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<127 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  128 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_10]], %[[VAL_11]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_12]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]]:9 = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_15]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_14]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_6]], %[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_16]], %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_18]], %[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_7]], %[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_8]], %[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  127 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_25]], %[[VAL_29]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_30]]) %[[VAL_20]], %[[VAL_21]], %[[VAL_22]], %[[VAL_23]], %[[VAL_24]], %[[VAL_25]], %[[VAL_26]], %[[VAL_27]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_36]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_2]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_42]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_36]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_2]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_49]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_36]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_54]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_36]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_57]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_60]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_51]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_44]], %[[VAL_64]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_63]], %[[VAL_65]] : i1, i1
// CHECK-NEXT:            scf.if %[[VAL_66]] {
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_67]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_68]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_71]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_74]]] = %[[VAL_73]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_51]], %[[VAL_75]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_44]], %[[VAL_77]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_76]], %[[VAL_78]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_79]] {
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_31]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_80]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_31]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_81]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_31]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_85]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_89]]] = %[[VAL_88]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_51]], %[[VAL_90]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_44]], %[[VAL_92]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_91]], %[[VAL_93]] : i1, i1
// CHECK-NEXT:                scf.if %[[VAL_94]] {
// CHECK-NEXT:                  %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_95]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_31]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_96]], %[[VAL_97]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_98]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_3]]{{\[}}%[[VAL_100]]] = %[[VAL_99]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_101]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_102]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_103]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_3]]{{\[}}%[[VAL_105]]] = %[[VAL_104]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_106]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_32]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_35]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_110]], %[[VAL_109]], %[[VAL_44]], %[[VAL_51]], %[[VAL_112]], %[[VAL_114]], %[[VAL_55]], %[[VAL_61]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sout] = %[[VAL_19]]#8 : <@CompConstant::@CompConstant<[@ct]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  135 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_115]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_117]], @params = %[[VAL_116]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[135]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_19]]#8 : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[135]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_119]], %[[VAL_120]] : index
// CHECK-NEXT:          pod.write %[[VAL_118]][@count] = %[[VAL_121]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[135]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_121]], %[[VAL_122]] : index
// CHECK-NEXT:          scf.if %[[VAL_123]] {
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[135]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_125]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[135]>>
// CHECK-NEXT:            pod.write %[[VAL_118]][@comp] = %[[VAL_126]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[135]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[135]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[135]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[135]>>
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_127]][@out] : <@Num2Bits::@Num2Bits<[135]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  127 : <"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_130]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_131]] : <@CompConstant::@CompConstant<[@ct]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@num2bits$inputs] = %[[VAL_4]] : <@CompConstant::@CompConstant<[@ct]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[135]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[135]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@num2bits] = %[[VAL_132]] : <@CompConstant::@CompConstant<[@ct]>>, !struct.type<@Num2Bits::@Num2Bits<[135]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@parts] = %[[VAL_3]] : <@CompConstant::@CompConstant<[@ct]>>, !array.type<127 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@CompConstant::@CompConstant<[@ct]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_133:[0-9a-zA-Z_\.]+]]: !struct.type<@CompConstant::@CompConstant<[@ct]>>, %[[VAL_134:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = poly.read_const @ct : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_133]][@out] : <@CompConstant::@CompConstant<[@ct]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_133]][@parts] : <@CompConstant::@CompConstant<[@ct]>>, !array.type<127 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_133]][@sout] : <@CompConstant::@CompConstant<[@ct]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_133]][@num2bits] : <@CompConstant::@CompConstant<[@ct]>>, !struct.type<@Num2Bits::@Num2Bits<[135]>>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_133]][@num2bits$inputs] : <@CompConstant::@CompConstant<[@ct]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  128 : <"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_146]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_148]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]]:9 = scf.while (%[[VAL_156:[0-9a-zA-Z_\.]+]] = %[[VAL_151]], %[[VAL_157:[0-9a-zA-Z_\.]+]] = %[[VAL_150]], %[[VAL_158:[0-9a-zA-Z_\.]+]] = %[[VAL_141]], %[[VAL_159:[0-9a-zA-Z_\.]+]] = %[[VAL_142]], %[[VAL_160:[0-9a-zA-Z_\.]+]] = %[[VAL_152]], %[[VAL_161:[0-9a-zA-Z_\.]+]] = %[[VAL_154]], %[[VAL_162:[0-9a-zA-Z_\.]+]] = %[[VAL_143]], %[[VAL_163:[0-9a-zA-Z_\.]+]] = %[[VAL_144]], %[[VAL_164:[0-9a-zA-Z_\.]+]] = %[[VAL_145]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  127 : <"bn128">
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_161]], %[[VAL_165]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_166]]) %[[VAL_156]], %[[VAL_157]], %[[VAL_158]], %[[VAL_159]], %[[VAL_160]], %[[VAL_161]], %[[VAL_162]], %[[VAL_163]], %[[VAL_164]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_167:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_168:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_169:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_170:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_171:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_172:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_173:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_174:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_175:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_172]], %[[VAL_176]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_135]], %[[VAL_177]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_178]], %[[VAL_179]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_172]], %[[VAL_181]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_182]], %[[VAL_183]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_135]], %[[VAL_184]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_185]], %[[VAL_186]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_172]], %[[VAL_188]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_189]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_134]]{{\[}}%[[VAL_190]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_172]], %[[VAL_192]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_194]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_195]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_134]]{{\[}}%[[VAL_196]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_187]], %[[VAL_198]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_180]], %[[VAL_200]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_199]], %[[VAL_201]] : i1, i1
// CHECK-NEXT:            scf.if %[[VAL_202]] {
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_168]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_203]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_204]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_168]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_205]], %[[VAL_206]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_168]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_207]], %[[VAL_208]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_210]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_211]], %[[VAL_209]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_213:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_187]], %[[VAL_212]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_215:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_180]], %[[VAL_214]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_216:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_213]], %[[VAL_215]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_216]] {
// CHECK-NEXT:                %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_167]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_217]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_167]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_218]], %[[VAL_219]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_168]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_220]], %[[VAL_221]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_167]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_222]], %[[VAL_223]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_225:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_224]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_226:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_227:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_226]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_227]], %[[VAL_225]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_229:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_187]], %[[VAL_228]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_231:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_180]], %[[VAL_230]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_232:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_229]], %[[VAL_231]] : i1, i1
// CHECK-NEXT:                scf.if %[[VAL_232]] {
// CHECK-NEXT:                  %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_168]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_233]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_167]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_234]], %[[VAL_235]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_236]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_238]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_239]], %[[VAL_237]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_240:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_167]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_240]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_242:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_241]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_242]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_244:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_245:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_244]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_245]], %[[VAL_243]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_246]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_175]], %[[VAL_247]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_168]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_167]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_252:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_171]], %[[VAL_251]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_172]], %[[VAL_253]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_250]], %[[VAL_249]], %[[VAL_180]], %[[VAL_187]], %[[VAL_252]], %[[VAL_254]], %[[VAL_191]], %[[VAL_197]], %[[VAL_248]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_138]], %[[VAL_155]]#8 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  135 : <"bn128">
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_255]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[135]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_258]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_139]][@out] : <@Num2Bits::@Num2Bits<[135]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = felt.const  127 : <"bn128">
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_260]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_259]]{{\[}}%[[VAL_261]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_136]], %[[VAL_262]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_139]], %[[VAL_263]]) : (!struct.type<@Num2Bits::@Num2Bits<[135]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @IsNegative {
// CHECK-NEXT:      struct.def @IsNegative {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @num2Bits : !struct.type<@Num2Bits::@Num2Bits<[254]>>
// CHECK-NEXT:        struct.member @num2Bits$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        struct.member @sign : !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:        struct.member @sign$inputs : !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_264:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@IsNegative::@IsNegative<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = struct.new : <@IsNegative::@IsNegative<[]>>
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = arith.constant 254 : index
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_268]], @params = %[[VAL_267]] }  : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = felt.const  254 : <"bn128">
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_271]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_273]], @params = %[[VAL_272]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[254]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_266]][@in] = %[[VAL_264]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[254]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_275]], %[[VAL_276]] : index
// CHECK-NEXT:          pod.write %[[VAL_274]][@count] = %[[VAL_277]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[254]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_277]], %[[VAL_278]] : index
// CHECK-NEXT:          scf.if %[[VAL_279]] {
// CHECK-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[254]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_266]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_281]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[254]>>
// CHECK-NEXT:            pod.write %[[VAL_274]][@comp] = %[[VAL_282]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[254]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[254]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_283:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_284:[0-9a-zA-Z_\.]+]] = arith.constant 254 : index
// CHECK-NEXT:          %[[VAL_285:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_284]], @params = %[[VAL_283]] }  : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_287:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_288:[0-9a-zA-Z_\.]+]] = %[[VAL_286]], %[[VAL_289:[0-9a-zA-Z_\.]+]] = %[[VAL_270]]) : (!felt.type<"bn128">, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.const  254 : <"bn128">
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_288]], %[[VAL_290]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_291]]) %[[VAL_288]], %[[VAL_289]] : !felt.type<"bn128">, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_292:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_293:[0-9a-zA-Z_\.]+]]: !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[254]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[254]>>
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_294]][@out] : <@Num2Bits::@Num2Bits<[254]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_295]]{{\[}}%[[VAL_296]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_293]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_298]]{{\[}}%[[VAL_299]]] = %[[VAL_297]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_293]][@in] = %[[VAL_298]] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@count] : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_302:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_300]], %[[VAL_301]] : index
// CHECK-NEXT:            pod.write %[[VAL_285]][@count] = %[[VAL_302]] : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_303:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_304:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_302]], %[[VAL_303]] : index
// CHECK-NEXT:            scf.if %[[VAL_304]] {
// CHECK-NEXT:              %[[VAL_305:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@params] : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_306:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_293]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_307:[0-9a-zA-Z_\.]+]] = function.call @Sign::@Sign::@compute(%[[VAL_306]]) : (!array.type<254 x !felt.type<"bn128">>) -> !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:              pod.write %[[VAL_285]][@comp] = %[[VAL_307]] : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_292]], %[[VAL_308]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_309]], %[[VAL_293]] : !felt.type<"bn128">, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_310:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@comp] : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:          %[[VAL_311:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_310]][@sign] : <@Sign::@Sign<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_265]][@out] = %[[VAL_311]] : <@IsNegative::@IsNegative<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_265]][@num2Bits$inputs] = %[[VAL_266]] : <@IsNegative::@IsNegative<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_274]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[254]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[254]>>
// CHECK-NEXT:          struct.writem %[[VAL_265]][@num2Bits] = %[[VAL_312]] : <@IsNegative::@IsNegative<[]>>, !struct.type<@Num2Bits::@Num2Bits<[254]>>
// CHECK-NEXT:          struct.writem %[[VAL_265]][@sign$inputs] = %[[VAL_287]]#1 : <@IsNegative::@IsNegative<[]>>, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@comp] : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_265]][@sign] = %[[VAL_313]] : <@IsNegative::@IsNegative<[]>>, !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:          function.return %[[VAL_265]] : !struct.type<@IsNegative::@IsNegative<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_314:[0-9a-zA-Z_\.]+]]: !struct.type<@IsNegative::@IsNegative<[]>>, %[[VAL_315:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_316:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_314]][@out] : <@IsNegative::@IsNegative<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_317:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_314]][@num2Bits] : <@IsNegative::@IsNegative<[]>>, !struct.type<@Num2Bits::@Num2Bits<[254]>>
// CHECK-NEXT:          %[[VAL_318:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_314]][@num2Bits$inputs] : <@IsNegative::@IsNegative<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_319:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_314]][@sign] : <@IsNegative::@IsNegative<[]>>, !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_314]][@sign$inputs] : <@IsNegative::@IsNegative<[]>>, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_321:[0-9a-zA-Z_\.]+]] = felt.const  254 : <"bn128">
// CHECK-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_321]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[254]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_324]], %[[VAL_315]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sign::@Sign<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_327:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_329:[0-9a-zA-Z_\.]+]] = %[[VAL_327]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = felt.const  254 : <"bn128">
// CHECK-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_329]], %[[VAL_330]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_331]]) %[[VAL_329]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_332:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_333:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_317]][@out] : <@Num2Bits::@Num2Bits<[254]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_332]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_333]]{{\[}}%[[VAL_334]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_336:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_320]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_337:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_332]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_338:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_336]]{{\[}}%[[VAL_337]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_338]], %[[VAL_335]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_339:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_340:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_332]], %[[VAL_339]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_340]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_341:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_319]][@sign] : <@Sign::@Sign<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_316]], %[[VAL_341]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_342:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_317]], %[[VAL_342]]) : (!struct.type<@Num2Bits::@Num2Bits<[254]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_343:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_320]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sign::@Sign::@constrain(%[[VAL_319]], %[[VAL_343]]) : (!struct.type<@Sign::@Sign<[]>>, !array.type<254 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_344:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_345:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_346:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_347:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_352:[0-9a-zA-Z_\.]+]] = %[[VAL_349]], %[[VAL_353:[0-9a-zA-Z_\.]+]] = %[[VAL_350]], %[[VAL_354:[0-9a-zA-Z_\.]+]] = %[[VAL_348]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_355:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_353]], %[[VAL_346]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_355]]) %[[VAL_352]], %[[VAL_353]], %[[VAL_354]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_356:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_357:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_358:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_359:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_344]], %[[VAL_357]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_361:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_359]], %[[VAL_360]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_362:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_357]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_347]]{{\[}}%[[VAL_362]]] = %[[VAL_361]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_363:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_357]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_364:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_347]]{{\[}}%[[VAL_363]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_365:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_364]], %[[VAL_356]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_366:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_358]], %[[VAL_365]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_356]], %[[VAL_356]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_368:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_369:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_357]], %[[VAL_368]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_367]], %[[VAL_369]], %[[VAL_366]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_345]][@out] = %[[VAL_347]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_345]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_370:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_371:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_372:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_373:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_370]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_376:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_377:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_378:[0-9a-zA-Z_\.]+]] = %[[VAL_375]], %[[VAL_379:[0-9a-zA-Z_\.]+]] = %[[VAL_376]], %[[VAL_380:[0-9a-zA-Z_\.]+]] = %[[VAL_374]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_379]], %[[VAL_372]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_381]]) %[[VAL_378]], %[[VAL_379]], %[[VAL_380]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_382:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_383:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_384:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_385:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_383]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_373]]{{\[}}%[[VAL_385]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_383]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_388:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_373]]{{\[}}%[[VAL_387]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_389:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_390:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_388]], %[[VAL_389]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_391:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_386]], %[[VAL_390]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_392:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_391]], %[[VAL_392]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_393:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_383]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_394:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_373]]{{\[}}%[[VAL_393]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_395:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_394]], %[[VAL_382]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_396:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_384]], %[[VAL_395]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_397:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_382]], %[[VAL_382]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_398:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_399:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_383]], %[[VAL_398]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_397]], %[[VAL_399]], %[[VAL_396]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_377]]#2, %[[VAL_371]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sign {
// CHECK-NEXT:      poly.expr @"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_400:[0-9a-zA-Z_\.]+]] = felt.const  10944121435919637611123202872628637544274182200208017171849102093287904247808 : <"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_400]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @Sign {
// CHECK-NEXT:        struct.member @sign : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @comp : !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>
// CHECK-NEXT:        struct.member @comp$inputs : !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_401:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Sign::@Sign<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_402:[0-9a-zA-Z_\.]+]] = struct.new : <@Sign::@Sign<[]>>
// CHECK-NEXT:          %[[VAL_403:[0-9a-zA-Z_\.]+]] = poly.read_const @"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_404:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_405:[0-9a-zA-Z_\.]+]] = poly.read_const @"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_406:[0-9a-zA-Z_\.]+]] = pod.new { @ct = %[[VAL_405]] }  : <[@ct: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_407:[0-9a-zA-Z_\.]+]] = arith.constant 254 : index
// CHECK-NEXT:          %[[VAL_408:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_407]], @params = %[[VAL_406]] }  : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, @params: !pod.type<[@ct: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_409:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_410:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_411:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_412:[0-9a-zA-Z_\.]+]] = %[[VAL_404]], %[[VAL_413:[0-9a-zA-Z_\.]+]] = %[[VAL_410]]) : (!pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_414:[0-9a-zA-Z_\.]+]] = felt.const  254 : <"bn128">
// CHECK-NEXT:            %[[VAL_415:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_413]], %[[VAL_414]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_415]]) %[[VAL_412]], %[[VAL_413]] : !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_416:[0-9a-zA-Z_\.]+]]: !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, %[[VAL_417:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_418:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_417]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_419:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_401]]{{\[}}%[[VAL_418]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_420:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_416]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_421:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_417]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_420]]{{\[}}%[[VAL_421]]] = %[[VAL_419]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_416]][@in] = %[[VAL_420]] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_422:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_408]][@count] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, @params: !pod.type<[@ct: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_423:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_424:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_422]], %[[VAL_423]] : index
// CHECK-NEXT:            pod.write %[[VAL_408]][@count] = %[[VAL_424]] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, @params: !pod.type<[@ct: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_425:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_426:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_424]], %[[VAL_425]] : index
// CHECK-NEXT:            scf.if %[[VAL_426]] {
// CHECK-NEXT:              %[[VAL_427:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_408]][@params] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, @params: !pod.type<[@ct: !felt.type<"bn128">]>]>, !pod.type<[@ct: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_428:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_416]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_429:[0-9a-zA-Z_\.]+]] = function.call @CompConstant::@CompConstant::@compute(%[[VAL_428]]) : (!array.type<254 x !felt.type<"bn128">>) -> !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>
// CHECK-NEXT:              pod.write %[[VAL_408]][@comp] = %[[VAL_429]] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, @params: !pod.type<[@ct: !felt.type<"bn128">]>]>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_430:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_431:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_417]], %[[VAL_430]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_416]], %[[VAL_431]] : !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_432:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_408]][@comp] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, @params: !pod.type<[@ct: !felt.type<"bn128">]>]>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>
// CHECK-NEXT:          %[[VAL_433:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_432]][@out] : <@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_402]][@sign] = %[[VAL_433]] : <@Sign::@Sign<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_402]][@comp$inputs] = %[[VAL_411]]#0 : <@Sign::@Sign<[]>>, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_434:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_408]][@comp] : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, @params: !pod.type<[@ct: !felt.type<"bn128">]>]>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>
// CHECK-NEXT:          struct.writem %[[VAL_402]][@comp] = %[[VAL_434]] : <@Sign::@Sign<[]>>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>
// CHECK-NEXT:          function.return %[[VAL_402]] : !struct.type<@Sign::@Sign<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_435:[0-9a-zA-Z_\.]+]]: !struct.type<@Sign::@Sign<[]>>, %[[VAL_436:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_437:[0-9a-zA-Z_\.]+]] = poly.read_const @"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_438:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_435]][@sign] : <@Sign::@Sign<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_439:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_435]][@comp] : <@Sign::@Sign<[]>>, !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>
// CHECK-NEXT:          %[[VAL_440:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_435]][@comp$inputs] : <@Sign::@Sign<[]>>, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_441:[0-9a-zA-Z_\.]+]] = poly.read_const @"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_442:[0-9a-zA-Z_\.]+]] = pod.new { @ct = %[[VAL_441]] }  : <[@ct: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_443:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, @params: !pod.type<[@ct: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_444:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_445:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_446:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_447:[0-9a-zA-Z_\.]+]] = %[[VAL_445]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_448:[0-9a-zA-Z_\.]+]] = felt.const  254 : <"bn128">
// CHECK-NEXT:            %[[VAL_449:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_447]], %[[VAL_448]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_449]]) %[[VAL_447]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_450:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_451:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_450]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_452:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_436]]{{\[}}%[[VAL_451]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_453:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_440]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_454:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_450]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_455:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_453]]{{\[}}%[[VAL_454]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_455]], %[[VAL_452]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_456:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_457:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_450]], %[[VAL_456]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_457]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_458:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_439]][@out] : <@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_438]], %[[VAL_458]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_459:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_440]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @CompConstant::@CompConstant::@constrain(%[[VAL_439]], %[[VAL_459]]) : (!struct.type<@CompConstant::@CompConstant<[@"10944121435919637611123202872628637544274182200208017171849102093287904247808@[[ID]]"]>>, !array.type<254 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
