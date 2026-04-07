// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.6;

template Sum(n) {
    signal input inp[n];
    signal output outp;

    var s = 0;

    for (var i = 0; i < n; i++) {
        s += inp[i];
    }

    outp <== s;
}

function nop(i) {
    return i;
}

template Caller() {
    signal input inp[4];
    signal output outp;

    component s = Sum(4);

    for (var i = 0; i < 4; i++) {
        s.inp[i] <== nop(inp[i]);
    }

    outp <== s.outp;
}

component main = Caller();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Caller<[]>>} {
// CHECK-NEXT:    function.def @nop(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Caller<[]> {
// CHECK-NEXT:      struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.member @s : !struct.type<@Sum<[4]>>
// CHECK-NEXT:      struct.member @s$inputs : !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:      function.def @compute(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>) -> !struct.type<@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type, !pod.type<[@inp: !array.type<4 x !felt.type>]>) -> (!felt.type, !pod.type<[@inp: !array.type<4 x !felt.type>]>) {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_10]])
// CHECK-NEXT:          scf.condition(%[[VAL_11]]) %[[VAL_8]], %[[VAL_9]] : !felt.type, !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<4 x !felt.type>]>):
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]]
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_14]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = function.call @nop(%[[VAL_15]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@inp] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]]
// CHECK-NEXT:          array.write %[[VAL_17]]{{\[}}%[[VAL_18]]] = %[[VAL_16]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_13]][@inp] = %[[VAL_17]] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_19]], %[[VAL_20]] : index
// CHECK-NEXT:          pod.write %[[VAL_4]][@count] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:          scf.if %[[VAL_23]] {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@inp] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = function.call @Sum::@compute(%[[VAL_24]]) : (!array.type<4 x !felt.type>) -> !struct.type<@Sum<[4]>>
// CHECK-NEXT:            pod.write %[[VAL_4]][@comp] = %[[VAL_25]] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_27]], %[[VAL_13]] : !felt.type, !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@outp] : <@Sum<[4]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_2]][@outp] = %[[VAL_29]] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_2]][@s$inputs] = %[[VAL_7]]#1 : <@Caller<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:        struct.writem %[[VAL_2]][@s] = %[[VAL_30]] : <@Caller<[]>>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@Caller<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller<[]>>, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@outp] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@s] : <@Caller<[]>>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@s$inputs] : <@Caller<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_36]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_38]], %[[VAL_39]])
// CHECK-NEXT:          scf.condition(%[[VAL_40]]) %[[VAL_38]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]]
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_42]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @nop(%[[VAL_43]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@inp] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]]
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_46]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_44]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_48]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_49]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@outp] : <@Sum<[4]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_33]], %[[VAL_50]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@inp] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:        function.call @Sum::@constrain(%[[VAL_34]], %[[VAL_51]]) : (!struct.type<@Sum<[4]>>, !array.type<4 x !felt.type>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Sum<[@n]> {
// CHECK-NEXT:      struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_52:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum<[@n]>>
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_56]], %[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_55]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_58]], %[[VAL_54]])
// CHECK-NEXT:          scf.condition(%[[VAL_60]]) %[[VAL_58]], %[[VAL_59]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]]
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_63]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_64]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_61]], %[[VAL_66]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_67]], %[[VAL_65]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_53]][@outp] = %[[VAL_57]]#1 : <@Sum<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_53]] : !struct.type<@Sum<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum<[@n]>>, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@outp] : <@Sum<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_75:[0-9a-zA-Z_\.]+]] = %[[VAL_73]], %[[VAL_76:[0-9a-zA-Z_\.]+]] = %[[VAL_72]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_75]], %[[VAL_70]])
// CHECK-NEXT:          scf.condition(%[[VAL_77]]) %[[VAL_75]], %[[VAL_76]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_79:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]]
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_80]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_79]], %[[VAL_81]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_78]], %[[VAL_83]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_84]], %[[VAL_82]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_71]], %[[VAL_74]]#1 : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
