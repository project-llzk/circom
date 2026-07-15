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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@AliasCheck_2::@AliasCheck_2<[]>>} {
// CHECK-NEXT:    poly.template @AliasCheck_2 {
// CHECK-NEXT:      struct.def @AliasCheck_2 {
// CHECK-NEXT:        struct.member @compConstant : !struct.type<@CompConstant_1::@CompConstant_1<[]>>
// CHECK-NEXT:        struct.member @compConstant$inputs : !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@AliasCheck_2::@AliasCheck_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@AliasCheck_2::@AliasCheck_2<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 254 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@CompConstant_1::@CompConstant_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  254 : <"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_11]]) %[[VAL_8]], %[[VAL_9]] : !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_14]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_17]]] = %[[VAL_15]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_12]][@in] = %[[VAL_16]] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@CompConstant_1::@CompConstant_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_18]], %[[VAL_19]] : index
// CHECK-NEXT:            pod.write %[[VAL_4]][@count] = %[[VAL_20]] : <[@count: index, @comp: !struct.type<@CompConstant_1::@CompConstant_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_20]], %[[VAL_21]] : index
// CHECK-NEXT:            scf.if %[[VAL_22]] {
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@params] : <[@count: index, @comp: !struct.type<@CompConstant_1::@CompConstant_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = function.call @CompConstant_1::@CompConstant_1::@compute(%[[VAL_24]]) : (!array.type<254 x !felt.type<"bn128">>) -> !struct.type<@CompConstant_1::@CompConstant_1<[]>>
// CHECK-NEXT:              pod.write %[[VAL_4]][@comp] = %[[VAL_25]] : <[@count: index, @comp: !struct.type<@CompConstant_1::@CompConstant_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@CompConstant_1::@CompConstant_1<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_12]], %[[VAL_27]] : !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@compConstant$inputs] = %[[VAL_7]]#0 : <@AliasCheck_2::@AliasCheck_2<[]>>, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@CompConstant_1::@CompConstant_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@CompConstant_1::@CompConstant_1<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@compConstant] = %[[VAL_28]] : <@AliasCheck_2::@AliasCheck_2<[]>>, !struct.type<@CompConstant_1::@CompConstant_1<[]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@AliasCheck_2::@AliasCheck_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@AliasCheck_2::@AliasCheck_2<[]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@compConstant] : <@AliasCheck_2::@AliasCheck_2<[]>>, !struct.type<@CompConstant_1::@CompConstant_1<[]>>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@compConstant$inputs] : <@AliasCheck_2::@AliasCheck_2<[]>>, !pod.type<[@in: !array.type<254 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  254 : <"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_35]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_37]]) %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_39]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_42]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_43]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@out] : <@CompConstant_1::@CompConstant_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_46]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@in] : <[@in: !array.type<254 x !felt.type<"bn128">>]>, !array.type<254 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @CompConstant_1::@CompConstant_1::@constrain(%[[VAL_31]], %[[VAL_48]]) : (!struct.type<@CompConstant_1::@CompConstant_1<[]>>, !array.type<254 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CompConstant_1 {
// CHECK-NEXT:      struct.def @CompConstant_1 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @parts : !array.type<127 x !felt.type<"bn128">> {signal}
// CHECK-NEXT:        struct.member @sout : !felt.type<"bn128"> {signal}
// CHECK-NEXT:        struct.member @num2bits : !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:        struct.member @num2bits$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@CompConstant_1::@CompConstant_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.new : <@CompConstant_1::@CompConstant_1<[]>>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<127 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_53]], @params = %[[VAL_52]] }  : <[@count: index, @comp: !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  340282366920938463463374607431768211455 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]]:9 = scf.while (%[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_63]], %[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_62]], %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_58]], %[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_64]], %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_66]], %[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_59]], %[[VAL_75:[0-9a-zA-Z_\.]+]] = %[[VAL_60]], %[[VAL_76:[0-9a-zA-Z_\.]+]] = %[[VAL_61]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  127 : <"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_73]], %[[VAL_77]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_78]]) %[[VAL_68]], %[[VAL_69]], %[[VAL_70]], %[[VAL_71]], %[[VAL_72]], %[[VAL_73]], %[[VAL_74]], %[[VAL_75]], %[[VAL_76]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_83:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_85:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616 : <"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_84]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_88]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_91]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616 : <"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_84]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_96]], %[[VAL_97]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_94]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_99]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_84]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_49]]{{\[}}%[[VAL_104]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_84]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_107]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_49]]{{\[}}%[[VAL_110]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_101]], %[[VAL_112]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_93]], %[[VAL_114]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_113]], %[[VAL_115]] : i1, i1
// CHECK-NEXT:            scf.if %[[VAL_116]] {
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_117]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_118]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_80]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_119]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_80]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_121]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_51]]{{\[}}%[[VAL_124]]] = %[[VAL_123]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_101]], %[[VAL_125]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_93]], %[[VAL_127]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_126]], %[[VAL_128]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_129]] {
// CHECK-NEXT:                %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_79]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_130]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_79]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_131]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_80]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_133]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_79]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_135]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_137]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_51]]{{\[}}%[[VAL_139]]] = %[[VAL_138]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_142:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_93]], %[[VAL_141]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_144:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_140]], %[[VAL_143]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_145:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_144]], %[[VAL_142]] : i1, i1
// CHECK-NEXT:                scf.if %[[VAL_145]] {
// CHECK-NEXT:                  %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_80]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_146]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_79]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_147]], %[[VAL_148]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_149]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_51]]{{\[}}%[[VAL_151]]] = %[[VAL_150]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_152]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_153]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_154]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_51]]{{\[}}%[[VAL_156]]] = %[[VAL_155]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_51]]{{\[}}%[[VAL_157]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_158]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_80]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_79]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_83]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_164]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_161]], %[[VAL_160]], %[[VAL_93]], %[[VAL_101]], %[[VAL_163]], %[[VAL_165]], %[[VAL_105]], %[[VAL_111]], %[[VAL_159]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_50]][@sout] = %[[VAL_67]]#8 : <@CompConstant_1::@CompConstant_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_55]][@in] = %[[VAL_67]]#8 : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_166]], %[[VAL_167]] : index
// CHECK-NEXT:          pod.write %[[VAL_54]][@count] = %[[VAL_168]] : <[@count: index, @comp: !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_168]], %[[VAL_169]] : index
// CHECK-NEXT:          scf.if %[[VAL_170]] {
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits_0::@Num2Bits_0::@compute(%[[VAL_172]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_54]][@comp] = %[[VAL_173]] : <[@count: index, @comp: !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_174]][@out] : <@Num2Bits_0::@Num2Bits_0<[]>>, !array.type<135 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  127 : <"bn128">
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_175]]{{\[}}%[[VAL_177]]] : <135 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_50]][@out] = %[[VAL_178]] : <@CompConstant_1::@CompConstant_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_50]][@num2bits$inputs] = %[[VAL_55]] : <@CompConstant_1::@CompConstant_1<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_50]][@num2bits] = %[[VAL_179]] : <@CompConstant_1::@CompConstant_1<[]>>, !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_50]][@parts] = %[[VAL_51]] : <@CompConstant_1::@CompConstant_1<[]>>, !array.type<127 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_50]] : !struct.type<@CompConstant_1::@CompConstant_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_180:[0-9a-zA-Z_\.]+]]: !struct.type<@CompConstant_1::@CompConstant_1<[]>>, %[[VAL_181:[0-9a-zA-Z_\.]+]]: !array.type<254 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_180]][@out] : <@CompConstant_1::@CompConstant_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_180]][@parts] : <@CompConstant_1::@CompConstant_1<[]>>, !array.type<127 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_180]][@sout] : <@CompConstant_1::@CompConstant_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_180]][@num2bits] : <@CompConstant_1::@CompConstant_1<[]>>, !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_180]][@num2bits$inputs] : <@CompConstant_1::@CompConstant_1<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616 : <"bn128">
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  340282366920938463463374607431768211455 : <"bn128">
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]]:9 = scf.while (%[[VAL_199:[0-9a-zA-Z_\.]+]] = %[[VAL_194]], %[[VAL_200:[0-9a-zA-Z_\.]+]] = %[[VAL_193]], %[[VAL_201:[0-9a-zA-Z_\.]+]] = %[[VAL_188]], %[[VAL_202:[0-9a-zA-Z_\.]+]] = %[[VAL_189]], %[[VAL_203:[0-9a-zA-Z_\.]+]] = %[[VAL_195]], %[[VAL_204:[0-9a-zA-Z_\.]+]] = %[[VAL_197]], %[[VAL_205:[0-9a-zA-Z_\.]+]] = %[[VAL_190]], %[[VAL_206:[0-9a-zA-Z_\.]+]] = %[[VAL_191]], %[[VAL_207:[0-9a-zA-Z_\.]+]] = %[[VAL_192]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.const  127 : <"bn128">
// CHECK-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_204]], %[[VAL_208]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_209]]) %[[VAL_199]], %[[VAL_200]], %[[VAL_201]], %[[VAL_202]], %[[VAL_203]], %[[VAL_204]], %[[VAL_205]], %[[VAL_206]], %[[VAL_207]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_210:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_211:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_212:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_213:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_214:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_215:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_216:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_217:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_218:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616 : <"bn128">
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_215]], %[[VAL_220]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_219]], %[[VAL_221]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_222]], %[[VAL_223]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = felt.const  21888242871839275222246405745257275088548364400416034343698204186575808495616 : <"bn128">
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_215]], %[[VAL_226]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_227]], %[[VAL_228]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_225]], %[[VAL_229]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_230]], %[[VAL_231]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_215]], %[[VAL_233]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_236:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_181]]{{\[}}%[[VAL_235]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_238:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_215]], %[[VAL_237]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_239:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_240:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_238]], %[[VAL_239]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_181]]{{\[}}%[[VAL_241]]] : <254 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_232]], %[[VAL_243]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_224]], %[[VAL_245]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_244]], %[[VAL_246]] : i1, i1
// CHECK-NEXT:            scf.if %[[VAL_247]] {
// CHECK-NEXT:              %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_248]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_249]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_211]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_250]], %[[VAL_251]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_211]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_252]], %[[VAL_253]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_215]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_183]]{{\[}}%[[VAL_255]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_256]], %[[VAL_254]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_232]], %[[VAL_257]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_260:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_224]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_261:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_258]], %[[VAL_260]] : i1, i1
// CHECK-NEXT:              scf.if %[[VAL_261]] {
// CHECK-NEXT:                %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_210]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_262]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_264:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_210]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_265:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_263]], %[[VAL_264]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_266:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_211]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_267:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_265]], %[[VAL_266]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_210]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_267]], %[[VAL_268]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_269]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_215]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_183]]{{\[}}%[[VAL_271]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_272]], %[[VAL_270]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_275:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_224]], %[[VAL_274]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_276:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_277:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_273]], %[[VAL_276]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_278:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_277]], %[[VAL_275]] : i1, i1
// CHECK-NEXT:                scf.if %[[VAL_278]] {
// CHECK-NEXT:                  %[[VAL_279:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_211]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_279]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_210]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_282:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_280]], %[[VAL_281]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_282]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_284:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_215]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_285:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_183]]{{\[}}%[[VAL_284]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_285]], %[[VAL_283]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_210]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_287:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_286]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_287]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_289:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_288]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_290:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_215]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_291:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_183]]{{\[}}%[[VAL_290]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_291]], %[[VAL_289]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_215]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_183]]{{\[}}%[[VAL_292]]] : <127 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_218]], %[[VAL_293]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_211]], %[[VAL_214]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_210]], %[[VAL_214]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_214]], %[[VAL_297]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_215]], %[[VAL_299]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_296]], %[[VAL_295]], %[[VAL_224]], %[[VAL_232]], %[[VAL_298]], %[[VAL_300]], %[[VAL_236]], %[[VAL_242]], %[[VAL_294]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_184]], %[[VAL_198]]#8 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_301]], %[[VAL_198]]#8 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_302:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_185]][@out] : <@Num2Bits_0::@Num2Bits_0<[]>>, !array.type<135 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_303:[0-9a-zA-Z_\.]+]] = felt.const  127 : <"bn128">
// CHECK-NEXT:          %[[VAL_304:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_303]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_305:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_302]]{{\[}}%[[VAL_304]]] : <135 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_182]], %[[VAL_305]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_306:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits_0::@Num2Bits_0::@constrain(%[[VAL_185]], %[[VAL_306]]) : (!struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits_0 {
// CHECK-NEXT:      struct.def @Num2Bits_0 {
// CHECK-NEXT:        struct.member @out : !array.type<135 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_307:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits_0::@Num2Bits_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_308:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:          %[[VAL_309:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<135 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_310:[0-9a-zA-Z_\.]+]] = felt.const  135 : <"bn128">
// CHECK-NEXT:          %[[VAL_311:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_312:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_313:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_314:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_315:[0-9a-zA-Z_\.]+]] = %[[VAL_312]], %[[VAL_316:[0-9a-zA-Z_\.]+]] = %[[VAL_313]], %[[VAL_317:[0-9a-zA-Z_\.]+]] = %[[VAL_311]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = felt.const  135 : <"bn128">
// CHECK-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_316]], %[[VAL_318]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_319]]) %[[VAL_315]], %[[VAL_316]], %[[VAL_317]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_320:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_321:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_322:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_307]], %[[VAL_321]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_323]], %[[VAL_324]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_321]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_309]]{{\[}}%[[VAL_326]]] = %[[VAL_325]] : <135 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_321]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_309]]{{\[}}%[[VAL_327]]] : <135 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_328]], %[[VAL_320]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_322]], %[[VAL_329]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_320]], %[[VAL_320]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_332:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_333:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_321]], %[[VAL_332]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_331]], %[[VAL_333]], %[[VAL_330]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_308]][@out] = %[[VAL_309]] : <@Num2Bits_0::@Num2Bits_0<[]>>, !array.type<135 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_308]] : !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_334:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits_0::@Num2Bits_0<[]>>, %[[VAL_335:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_336:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_334]][@out] : <@Num2Bits_0::@Num2Bits_0<[]>>, !array.type<135 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_337:[0-9a-zA-Z_\.]+]] = felt.const  135 : <"bn128">
// CHECK-NEXT:          %[[VAL_338:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_340:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_341:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_342:[0-9a-zA-Z_\.]+]] = %[[VAL_339]], %[[VAL_343:[0-9a-zA-Z_\.]+]] = %[[VAL_340]], %[[VAL_344:[0-9a-zA-Z_\.]+]] = %[[VAL_338]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_345:[0-9a-zA-Z_\.]+]] = felt.const  135 : <"bn128">
// CHECK-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_343]], %[[VAL_345]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_346]]) %[[VAL_342]], %[[VAL_343]], %[[VAL_344]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_347:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_348:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_349:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_350:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_348]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_351:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_336]]{{\[}}%[[VAL_350]]] : <135 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_352:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_348]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_353:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_336]]{{\[}}%[[VAL_352]]] : <135 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_354:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_355:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_353]], %[[VAL_354]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_356:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_351]], %[[VAL_355]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_357:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_356]], %[[VAL_357]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_358:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_348]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_359:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_336]]{{\[}}%[[VAL_358]]] : <135 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_359]], %[[VAL_347]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_361:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_349]], %[[VAL_360]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_362:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_347]], %[[VAL_347]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_363:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_364:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_348]], %[[VAL_363]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_362]], %[[VAL_364]], %[[VAL_361]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_341]]#2, %[[VAL_335]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
