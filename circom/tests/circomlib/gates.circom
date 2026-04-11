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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Main<[]>>} {
// CHECK-NEXT:    poly.template @AND {
// CHECK-NEXT:      struct.def @AND {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@AND::@AND<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@AND::@AND<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@AND::@AND<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@AND::@AND<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@AND::@AND<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @and1 : !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:        struct.member @and1$inputs : !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        struct.member @nand1 : !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:        struct.member @nand1$inputs : !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        struct.member @nor1 : !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:        struct.member @nor1$inputs : !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        struct.member @not1 : !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:        struct.member @not1$inputs : !pod.type<[@in: !felt.type]>
// CHECK-NEXT:        struct.member @or1 : !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:        struct.member @or1$inputs : !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        struct.member @xor1 : !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:        struct.member @xor1$inputs : !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_10]] }  : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_13]] }  : <[@count: index, @comp: !struct.type<@NAND::@NAND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_16]] }  : <[@count: index, @comp: !struct.type<@NOR::@NOR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@NOT::@NOT<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_25]] }  : <[@count: index, @comp: !struct.type<@XOR::@XOR<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@and1$inputs] = %[[VAL_12]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@comp] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@and1] = %[[VAL_28]] : <@Main::@Main<[]>>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@nand1$inputs] = %[[VAL_15]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@comp] : <[@count: index, @comp: !struct.type<@NAND::@NAND<[]>>, @params: !pod.type<[]>]>, !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@nand1] = %[[VAL_29]] : <@Main::@Main<[]>>, !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@nor1$inputs] = %[[VAL_18]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@NOR::@NOR<[]>>, @params: !pod.type<[]>]>, !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@nor1] = %[[VAL_30]] : <@Main::@Main<[]>>, !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@not1$inputs] = %[[VAL_21]] : <@Main::@Main<[]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@comp] : <[@count: index, @comp: !struct.type<@NOT::@NOT<[]>>, @params: !pod.type<[]>]>, !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@not1] = %[[VAL_31]] : <@Main::@Main<[]>>, !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@or1$inputs] = %[[VAL_24]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@comp] : <[@count: index, @comp: !struct.type<@OR::@OR<[]>>, @params: !pod.type<[]>]>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@or1] = %[[VAL_32]] : <@Main::@Main<[]>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@xor1$inputs] = %[[VAL_27]] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@comp] : <[@count: index, @comp: !struct.type<@XOR::@XOR<[]>>, @params: !pod.type<[]>]>, !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@xor1] = %[[VAL_33]] : <@Main::@Main<[]>>, !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@and1] : <@Main::@Main<[]>>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@and1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@nand1] : <@Main::@Main<[]>>, !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@nand1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@nor1] : <@Main::@Main<[]>>, !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@nor1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@not1] : <@Main::@Main<[]>>, !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@not1$inputs] : <@Main::@Main<[]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@or1] : <@Main::@Main<[]>>, !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@or1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@xor1] : <@Main::@Main<[]>>, !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@xor1$inputs] : <@Main::@Main<[]>>, !pod.type<[@a: !felt.type, @b: !felt.type]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @AND::@AND::@constrain(%[[VAL_35]], %[[VAL_47]], %[[VAL_48]]) : (!struct.type<@AND::@AND<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @NAND::@NAND::@constrain(%[[VAL_37]], %[[VAL_49]], %[[VAL_50]]) : (!struct.type<@NAND::@NAND<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @NOR::@NOR::@constrain(%[[VAL_39]], %[[VAL_51]], %[[VAL_52]]) : (!struct.type<@NOR::@NOR<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @NOT::@NOT::@constrain(%[[VAL_41]], %[[VAL_53]]) : (!struct.type<@NOT::@NOT<[]>>, !felt.type) -> ()
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @OR::@OR::@constrain(%[[VAL_43]], %[[VAL_54]], %[[VAL_55]]) : (!struct.type<@OR::@OR<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@a] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@b] : <[@a: !felt.type, @b: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @XOR::@XOR::@constrain(%[[VAL_45]], %[[VAL_56]], %[[VAL_57]]) : (!struct.type<@XOR::@XOR<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @NAND {
// CHECK-NEXT:      struct.def @NAND {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_58:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_59:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@NAND::@NAND<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.new : <@NAND::@NAND<[]>>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_58]], %[[VAL_59]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_61]], %[[VAL_62]] : !felt.type, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_60]][@out] = %[[VAL_63]] : <@NAND::@NAND<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_60]] : !struct.type<@NAND::@NAND<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !struct.type<@NAND::@NAND<[]>>, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_66:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@out] : <@NAND::@NAND<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_65]], %[[VAL_66]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_68]], %[[VAL_69]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_67]], %[[VAL_70]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @NOR {
// CHECK-NEXT:      struct.def @NOR {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_72:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@NOR::@NOR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.new : <@NOR::@NOR<[]>>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_71]], %[[VAL_72]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_74]], %[[VAL_75]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_76]], %[[VAL_71]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_77]], %[[VAL_72]] : !felt.type, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_73]][@out] = %[[VAL_78]] : <@NOR::@NOR<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_73]] : !struct.type<@NOR::@NOR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !struct.type<@NOR::@NOR<[]>>, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_79]][@out] : <@NOR::@NOR<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_80]], %[[VAL_81]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_84]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_85]], %[[VAL_80]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_86]], %[[VAL_81]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_82]], %[[VAL_87]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @NOT {
// CHECK-NEXT:      struct.def @NOT {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_88:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@NOT::@NOT<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.new : <@NOT::@NOT<[]>>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_90]], %[[VAL_88]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_92]], %[[VAL_88]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_91]], %[[VAL_93]] : !felt.type, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_89]][@out] = %[[VAL_94]] : <@NOT::@NOT<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_89]] : !struct.type<@NOT::@NOT<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_95:[0-9a-zA-Z_\.]+]]: !struct.type<@NOT::@NOT<[]>>, %[[VAL_96:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_95]][@out] : <@NOT::@NOT<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_98]], %[[VAL_96]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_100]], %[[VAL_96]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_99]], %[[VAL_101]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_97]], %[[VAL_102]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @OR {
// CHECK-NEXT:      struct.def @OR {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_103:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_104:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@OR::@OR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.new : <@OR::@OR<[]>>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_103]], %[[VAL_104]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_103]], %[[VAL_104]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_106]], %[[VAL_107]] : !felt.type, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_105]][@out] = %[[VAL_108]] : <@OR::@OR<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_105]] : !struct.type<@OR::@OR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_109:[0-9a-zA-Z_\.]+]]: !struct.type<@OR::@OR<[]>>, %[[VAL_110:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_111:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_109]][@out] : <@OR::@OR<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_110]], %[[VAL_111]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_110]], %[[VAL_111]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_113]], %[[VAL_114]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_112]], %[[VAL_115]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @XOR {
// CHECK-NEXT:      struct.def @XOR {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_116:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_117:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@XOR::@XOR<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = struct.new : <@XOR::@XOR<[]>>
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_116]], %[[VAL_117]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_120]], %[[VAL_116]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_121]], %[[VAL_117]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_119]], %[[VAL_122]] : !felt.type, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_118]][@out] = %[[VAL_123]] : <@XOR::@XOR<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_118]] : !struct.type<@XOR::@XOR<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_124:[0-9a-zA-Z_\.]+]]: !struct.type<@XOR::@XOR<[]>>, %[[VAL_125:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_126:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_124]][@out] : <@XOR::@XOR<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_125]], %[[VAL_126]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_129]], %[[VAL_125]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_130]], %[[VAL_126]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_128]], %[[VAL_131]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_127]], %[[VAL_132]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
