// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// This test demonstrates that the VCP computes the largest possible return size from `POSEIDON_M`
// and uses that for the entire function, even in branches where the actual array size is smaller.
// Although dimension sizes may be different, the number of dimensions must be the same.
function POSEIDON_M(t) {
    if (t == 2) {
        return [
            [2910766817845651019878574839501801340070030115151021261302834310722729507541, 19727366863391167538122140361473584127147630672623100827934084310230022599144],
            [5776684794125549462448597414050232243778680302179439492664047328281728356345, 8348174920934122550483593999453880006756108121341067172388445916328941978568]
        ];
    } else if (t == 3) {
        return [
            [7511745149465107256748700652201246547602992235352608707588321460060273774987, 10370080108974718697676803824769673834027675643658433702224577712625900127200, 19705173408229649878903981084052839426532978878058043055305024233888854471533],
            [18732019378264290557468133440468564866454307626475683536618613112504878618481, 20870176810702568768751421378473869562658540583882454726129544628203806653987, 7266061498423634438633389053804536045105766754026813321943009179476902321146],
            [9131299761947733513298312097611845208338517739621853568979632113419485819303, 10595341252162738537912664445405114076324478519622938027420701542910180337937, 11597556804922396090267472882856054602429588299176362916247939723151043581408]
        ];
    } else {
        return [[0]];
    }
}


template Poseidon(nInputs) {
    signal input inputs[nInputs];
    signal output out;

    var t = nInputs + 1;
    var M[t][t] = POSEIDON_M(t);
}

component main = Poseidon(1);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Poseidon_0::@Poseidon_0<[]>>} {
// CHECK-NEXT:    poly.template @POSEIDON_M_0 {
// CHECK-NEXT:      function.def @POSEIDON_M_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "t"}) -> !array.type<3,3 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!array.type<3,3 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  2910766817845651019878574839501801340070030115151021261302834310722729507541 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  19727366863391167538122140361473584127147630672623100827934084310230022599144 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_10]]] = %[[VAL_8]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  5776684794125549462448597414050232243778680302179439492664047328281728356345 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_14]]] = %[[VAL_12]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  8348174920934122550483593999453880006756108121341067172388445916328941978568 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_17]]] = %[[VAL_15]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_18]]{{\[}}%[[VAL_20]]] = %[[VAL_4]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_18]]{{\[}}%[[VAL_22]]] = %[[VAL_11]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_24]], %[[VAL_25]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_24]], %[[VAL_25]]] = %[[VAL_26]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_27]], %[[VAL_28]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_27]], %[[VAL_28]]] = %[[VAL_29]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_30]], %[[VAL_31]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_30]], %[[VAL_31]]] = %[[VAL_32]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_33]], %[[VAL_34]]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_33]], %[[VAL_34]]] = %[[VAL_35]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_23]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_37]] -> (!array.type<3,3 x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  7511745149465107256748700652201246547602992235352608707588321460060273774987 : <"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_39]]{{\[}}%[[VAL_42]]] = %[[VAL_40]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  10370080108974718697676803824769673834027675643658433702224577712625900127200 : <"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_39]]{{\[}}%[[VAL_45]]] = %[[VAL_43]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  19705173408229649878903981084052839426532978878058043055305024233888854471533 : <"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_39]]{{\[}}%[[VAL_48]]] = %[[VAL_46]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  18732019378264290557468133440468564866454307626475683536618613112504878618481 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_49]]{{\[}}%[[VAL_52]]] = %[[VAL_50]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  20870176810702568768751421378473869562658540583882454726129544628203806653987 : <"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_49]]{{\[}}%[[VAL_55]]] = %[[VAL_53]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  7266061498423634438633389053804536045105766754026813321943009179476902321146 : <"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_49]]{{\[}}%[[VAL_58]]] = %[[VAL_56]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  9131299761947733513298312097611845208338517739621853568979632113419485819303 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_59]]{{\[}}%[[VAL_62]]] = %[[VAL_60]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  10595341252162738537912664445405114076324478519622938027420701542910180337937 : <"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_59]]{{\[}}%[[VAL_65]]] = %[[VAL_63]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  11597556804922396090267472882856054602429588299176362916247939723151043581408 : <"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_59]]{{\[}}%[[VAL_68]]] = %[[VAL_66]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_69]]{{\[}}%[[VAL_71]]] = %[[VAL_39]] : <3,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_69]]{{\[}}%[[VAL_73]]] = %[[VAL_49]] : <3,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_69]]{{\[}}%[[VAL_75]]] = %[[VAL_59]] : <3,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_77]], %[[VAL_78]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_77]], %[[VAL_78]]] = %[[VAL_79]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_80]], %[[VAL_81]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_80]], %[[VAL_81]]] = %[[VAL_82]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_83]], %[[VAL_84]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_83]], %[[VAL_84]]] = %[[VAL_85]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_86]], %[[VAL_87]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_86]], %[[VAL_87]]] = %[[VAL_88]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_89]], %[[VAL_90]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_89]], %[[VAL_90]]] = %[[VAL_91]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_92]], %[[VAL_93]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_92]], %[[VAL_93]]] = %[[VAL_94]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_95]], %[[VAL_96]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_95]], %[[VAL_96]]] = %[[VAL_97]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_98]], %[[VAL_99]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_98]], %[[VAL_99]]] = %[[VAL_100]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_101]], %[[VAL_102]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_76]]{{\[}}%[[VAL_101]], %[[VAL_102]]] = %[[VAL_103]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_76]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_104]]{{\[}}%[[VAL_107]]] = %[[VAL_105]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_108]]{{\[}}%[[VAL_110]]] = %[[VAL_104]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_112]], %[[VAL_113]]] : <1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_111]]{{\[}}%[[VAL_112]], %[[VAL_113]]] = %[[VAL_114]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_111]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_116]], %[[VAL_117]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_116]], %[[VAL_117]]] = %[[VAL_118]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_119]], %[[VAL_120]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_119]], %[[VAL_120]]] = %[[VAL_121]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_122]], %[[VAL_123]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_122]], %[[VAL_123]]] = %[[VAL_124]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_125]], %[[VAL_126]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_125]], %[[VAL_126]]] = %[[VAL_127]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_128]], %[[VAL_129]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_128]], %[[VAL_129]]] = %[[VAL_130]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_131]], %[[VAL_132]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_131]], %[[VAL_132]]] = %[[VAL_133]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_134]], %[[VAL_135]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_134]], %[[VAL_135]]] = %[[VAL_136]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_137]], %[[VAL_138]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_137]], %[[VAL_138]]] = %[[VAL_139]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_140]], %[[VAL_141]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_115]]{{\[}}%[[VAL_140]], %[[VAL_141]]] = %[[VAL_142]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_115]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_3]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Poseidon_0 {
// CHECK-NEXT:      struct.def @Poseidon_0 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_143:[0-9a-zA-Z_\.]+]]: !array.type<1 x !felt.type<"bn128">> {function.arg_name = "inputs"}) -> !struct.type<@Poseidon_0::@Poseidon_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = struct.new : <@Poseidon_0::@Poseidon_0<[]>>
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_150]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_148]]{{\[}}%[[VAL_151]]] = %[[VAL_149]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_148]]{{\[}}%[[VAL_154]]] = %[[VAL_152]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_147]]{{\[}}%[[VAL_156]]] = %[[VAL_148]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_147]]{{\[}}%[[VAL_158]]] = %[[VAL_148]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_159]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_165:[0-9a-zA-Z_\.]+]] = %[[VAL_163]] to %[[VAL_161]] step %[[VAL_164]] {
// CHECK-NEXT:            scf.for %[[VAL_166:[0-9a-zA-Z_\.]+]] = %[[VAL_163]] to %[[VAL_162]] step %[[VAL_164]] {
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_160]]{{\[}}%[[VAL_165]], %[[VAL_166]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_147]]{{\[}}%[[VAL_165]], %[[VAL_166]]] = %[[VAL_167]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_144]] : !struct.type<@Poseidon_0::@Poseidon_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_168:[0-9a-zA-Z_\.]+]]: !struct.type<@Poseidon_0::@Poseidon_0<[]>>, %[[VAL_169:[0-9a-zA-Z_\.]+]]: !array.type<1 x !felt.type<"bn128">> {function.arg_name = "inputs"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_168]][@out] : <@Poseidon_0::@Poseidon_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_174]]{{\[}}%[[VAL_177]]] = %[[VAL_175]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_179]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_174]]{{\[}}%[[VAL_180]]] = %[[VAL_178]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_173]]{{\[}}%[[VAL_182]]] = %[[VAL_174]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_183]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_173]]{{\[}}%[[VAL_184]]] = %[[VAL_174]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = function.call @POSEIDON_M_0::@POSEIDON_M_0(%[[VAL_185]]) : (!felt.type<"bn128">) -> !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_191:[0-9a-zA-Z_\.]+]] = %[[VAL_189]] to %[[VAL_187]] step %[[VAL_190]] {
// CHECK-NEXT:            scf.for %[[VAL_192:[0-9a-zA-Z_\.]+]] = %[[VAL_189]] to %[[VAL_188]] step %[[VAL_190]] {
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_186]]{{\[}}%[[VAL_191]], %[[VAL_192]]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_173]]{{\[}}%[[VAL_191]], %[[VAL_192]]] = %[[VAL_193]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
