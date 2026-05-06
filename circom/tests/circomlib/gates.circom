// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

/*
    Copyright 2018 0KIMS association.

    This file is part of circom (Zero Knowledge Circuit Compiler).

    circom is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    circom is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with circom. If not, see <https://www.gnu.org/licenses/>.
*/

pragma circom 2.0.0;

template XOR() {
    signal input a;
    signal input b;
    signal output out;

    out <== a + b - 2*a*b;
}

template AND() {
    signal input a;
    signal input b;
    signal output out;

    out <== a*b;
}

template OR() {
    signal input a;
    signal input b;
    signal output out;

    out <== a + b - a*b;
}

template NOT() {
    signal input in;
    signal output out;

    out <== 1 + in - 2*in;
}

template NAND() {
    signal input a;
    signal input b;
    signal output out;

    out <== 1 - a*b;
}

template NOR() {
    signal input a;
    signal input b;
    signal output out;

    out <== a*b + 1 - a - b;
}

template MultiAND(n) {
    signal input in[n];
    signal output out;
    component and1;
    component and2;
    component ands[2];
    if (n==1) {
        out <== in[0];
    } else if (n==2) {
        and1 = AND();
        and1.a <== in[0];
        and1.b <== in[1];
        out <== and1.out;
    } else {
        and2 = AND();
        var n1 = n\2;
        var n2 = n-n\2;
        ands[0] = MultiAND(n1);
        ands[1] = MultiAND(n2);
        var i;
        for (i=0; i<n1; i++) ands[0].in[i] <== in[i];
        for (i=0; i<n2; i++) ands[1].in[i] <== in[n1+i];
        and2.a <== ands[0].out;
        and2.b <== ands[1].out;
        out <== and2.out;
    }
}


template Main() {
    component xor1 = XOR();
    component and1 = AND();
    component or1 = OR();
    component not1 = NOT();
    component nand1 = NAND();
    component nor1 = NOR();
    // TODO: not yet supported
    // component multiand1 = MultiAND(3);
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Main::@Main<[]>>} {
// CHECK-NEXT:    poly.template @AND {
// CHECK-NEXT:      struct.def @AND {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@AND::@AND<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@AND::@AND<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@AND::@AND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@AND::@AND<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@AND::@AND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @and1 : !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:        struct.member @and1$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        struct.member @nand1 : !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:        struct.member @nand1$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        struct.member @nor1 : !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:        struct.member @nor1$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        struct.member @not1 : !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:        struct.member @not1$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        struct.member @or1 : !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:        struct.member @or1$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        struct.member @xor1 : !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:        struct.member @xor1$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_11]], @params = %[[VAL_10]] }  : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_15]], @params = %[[VAL_14]] }  : <[@count: index, @comp: !struct.type<@NAND::@NAND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_19]], @params = %[[VAL_18]] }  : <[@count: index, @comp: !struct.type<@NOR::@NOR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@NOT::@NOT<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_27]], @params = %[[VAL_26]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_31]], @params = %[[VAL_30]] }  : <[@count: index, @comp: !struct.type<@XOR::@XOR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@XOR::@XOR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@NOT::@NOT<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@NAND::@NAND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@NOR::@NOR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@and1$inputs] = %[[VAL_13]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@comp] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@and1] = %[[VAL_52]] : <@Main::@Main<[]>>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@nand1$inputs] = %[[VAL_17]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@comp] : <[@count: index, @comp: !struct.type<@NAND::@NAND<[]>>, @params: !pod.type<[]>]>, !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@nand1] = %[[VAL_53]] : <@Main::@Main<[]>>, !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@nor1$inputs] = %[[VAL_21]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@comp] : <[@count: index, @comp: !struct.type<@NOR::@NOR<[]>>, @params: !pod.type<[]>]>, !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@nor1] = %[[VAL_54]] : <@Main::@Main<[]>>, !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@not1$inputs] = %[[VAL_25]] : <@Main::@Main<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@comp] : <[@count: index, @comp: !struct.type<@NOT::@NOT<[]>>, @params: !pod.type<[]>]>, !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@not1] = %[[VAL_55]] : <@Main::@Main<[]>>, !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@or1$inputs] = %[[VAL_29]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@comp] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@or1] = %[[VAL_56]] : <@Main::@Main<[]>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@xor1$inputs] = %[[VAL_33]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@comp] : <[@count: index, @comp: !struct.type<@XOR::@XOR<[]>>, @params: !pod.type<[]>]>, !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@xor1] = %[[VAL_57]] : <@Main::@Main<[]>>, !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_58:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@and1] : <@Main::@Main<[]>>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@and1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@nand1] : <@Main::@Main<[]>>, !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@nand1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@nor1] : <@Main::@Main<[]>>, !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@nor1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@not1] : <@Main::@Main<[]>>, !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@not1$inputs] : <@Main::@Main<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@or1] : <@Main::@Main<[]>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@or1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@xor1] : <@Main::@Main<[]>>, !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@xor1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@XOR::@XOR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@NOT::@NOT<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@NAND::@NAND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@NOR::@NOR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @AND::@AND::@constrain(%[[VAL_59]], %[[VAL_83]], %[[VAL_84]]) : (!struct.type<@AND::@AND<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @NAND::@NAND::@constrain(%[[VAL_61]], %[[VAL_85]], %[[VAL_86]]) : (!struct.type<@NAND::@NAND<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @NOR::@NOR::@constrain(%[[VAL_63]], %[[VAL_87]], %[[VAL_88]]) : (!struct.type<@NOR::@NOR<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @NOT::@NOT::@constrain(%[[VAL_65]], %[[VAL_89]]) : (!struct.type<@NOT::@NOT<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @OR::@OR::@constrain(%[[VAL_67]], %[[VAL_90]], %[[VAL_91]]) : (!struct.type<@OR::@OR<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @XOR::@XOR::@constrain(%[[VAL_69]], %[[VAL_92]], %[[VAL_93]]) : (!struct.type<@XOR::@XOR<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @NAND {
// CHECK-NEXT:      struct.def @NAND {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_94:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_95:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@NAND::@NAND<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = struct.new : <@NAND::@NAND<[]>>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_94]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_97]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_96]][@out] = %[[VAL_99]] : <@NAND::@NAND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_96]] : !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_100:[0-9a-zA-Z_\.]+]]: !struct.type<@NAND::@NAND<[]>>, %[[VAL_101:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_102:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_100]][@out] : <@NAND::@NAND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_101]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_104]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_103]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @NOR {
// CHECK-NEXT:      struct.def @NOR {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_107:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_108:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@NOR::@NOR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.new : <@NOR::@NOR<[]>>
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_107]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_110]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_112]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_113]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_109]][@out] = %[[VAL_114]] : <@NOR::@NOR<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_109]] : !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_115:[0-9a-zA-Z_\.]+]]: !struct.type<@NOR::@NOR<[]>>, %[[VAL_116:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_117:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_115]][@out] : <@NOR::@NOR<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_116]], %[[VAL_117]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_119]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_121]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_122]], %[[VAL_117]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_118]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @NOT {
// CHECK-NEXT:      struct.def @NOT {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_124:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@NOT::@NOT<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = struct.new : <@NOT::@NOT<[]>>
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_126]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_128]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_127]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_125]][@out] = %[[VAL_130]] : <@NOT::@NOT<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_125]] : !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_131:[0-9a-zA-Z_\.]+]]: !struct.type<@NOT::@NOT<[]>>, %[[VAL_132:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_131]][@out] : <@NOT::@NOT<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_134]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_136]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_135]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_133]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @OR {
// CHECK-NEXT:      struct.def @OR {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_139:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_140:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@OR::@OR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = struct.new : <@OR::@OR<[]>>
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_139]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_139]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_142]], %[[VAL_143]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_141]][@out] = %[[VAL_144]] : <@OR::@OR<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_141]] : !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_145:[0-9a-zA-Z_\.]+]]: !struct.type<@OR::@OR<[]>>, %[[VAL_146:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_147:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_145]][@out] : <@OR::@OR<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_146]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_146]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_149]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_148]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @XOR {
// CHECK-NEXT:      struct.def @XOR {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_152:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_153:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@XOR::@XOR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = struct.new : <@XOR::@XOR<[]>>
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_152]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_156]], %[[VAL_152]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_157]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_155]], %[[VAL_158]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_154]][@out] = %[[VAL_159]] : <@XOR::@XOR<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_154]] : !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_160:[0-9a-zA-Z_\.]+]]: !struct.type<@XOR::@XOR<[]>>, %[[VAL_161:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_162:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_160]][@out] : <@XOR::@XOR<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_161]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_165]], %[[VAL_161]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_166]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_164]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_163]], %[[VAL_168]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
