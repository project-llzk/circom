// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Poseidon_0::@Poseidon_0<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2,2 x !felt.type<"bn128">> = [ 2910766817845651019878574839501801340070030115151021261302834310722729507541 : <"bn128">,  19727366863391167538122140361473584127147630672623100827934084310230022599144 : <"bn128">,  5776684794125549462448597414050232243778680302179439492664047328281728356345 : <"bn128">,  8348174920934122550483593999453880006756108121341067172388445916328941978568 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<3,3 x !felt.type<"bn128">> = [ 7511745149465107256748700652201246547602992235352608707588321460060273774987 : <"bn128">,  10370080108974718697676803824769673834027675643658433702224577712625900127200 : <"bn128">,  19705173408229649878903981084052839426532978878058043055305024233888854471533 : <"bn128">,  18732019378264290557468133440468564866454307626475683536618613112504878618481 : <"bn128">,  20870176810702568768751421378473869562658540583882454726129544628203806653987 : <"bn128">,  7266061498423634438633389053804536045105766754026813321943009179476902321146 : <"bn128">,  9131299761947733513298312097611845208338517739621853568979632113419485819303 : <"bn128">,  10595341252162738537912664445405114076324478519622938027420701542910180337937 : <"bn128">,  11597556804922396090267472882856054602429588299176362916247939723151043581408 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<1,1 x !felt.type<"bn128">> = [ 0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_3 : !array.type<2,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @POSEIDON_M_0 {
// CHECK-NEXT:      function.def @POSEIDON_M_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "t"}) -> !array.type<3,3 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!array.type<3,3 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
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
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_37]] -> (!array.type<3,3 x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            scf.yield %[[VAL_76]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.new  : <3,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_112]], %[[VAL_113]]] : <1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_111]]{{\[}}%[[VAL_112]], %[[VAL_113]]] = %[[VAL_114]] : <3,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_111]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_115]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_3]] : !array.type<3,3 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Poseidon_0 {
// CHECK-NEXT:      struct.def @Poseidon_0 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_143:[0-9a-zA-Z_\.]+]]: !array.type<1 x !felt.type<"bn128">> {function.arg_name = "inputs"}) -> !struct.type<@Poseidon_0::@Poseidon_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = struct.new : <@Poseidon_0::@Poseidon_0<[]>>
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<2,2 x !felt.type<"bn128">>
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
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<2,2 x !felt.type<"bn128">>
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
