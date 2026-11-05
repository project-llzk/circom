// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template AND() {
    signal input a;
    signal input b;
    signal output out;

    out <== a*b;
}

template MultiAND(n) {
    signal input in[n];
    signal output out;
    component and;
    component ands[2];
    var i;
    if (n==1) {
        out <== in[0];
    } else if (n==2) {
          and = AND();
        and.a <== in[0];
        and.b <== in[1];
        out <== and.out;
    } else {
        and = AND();
        var n1 = n\2;
        var n2 = n-n\2;
        ands[0] = MultiAND(n1);
        ands[1] = MultiAND(n2);
        for (i=0; i<n1; i++) ands[0].in[i] <== in[i];
        for (i=0; i<n2; i++) ands[1].in[i] <== in[n1+i];
        and.a <== ands[0].out;
        and.b <== ands[1].out;
        out <== and.out;
    }
}

component main = MultiAND(5);

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@MultiAND::@MultiAND<[5]>>} {
// CHECK-NEXT:    poly.template @AND {
// CHECK-NEXT:      struct.def @AND {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) -> !struct.type<@AND::@AND<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@AND::@AND<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@AND::@AND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@AND::@AND<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@AND::@AND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @MultiAND {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.expr @"n1@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_11]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_12]], %[[VAL_9]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_13]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_12]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_16]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_12]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        poly.yield %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"n2@[[OFFSET1:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_22]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_23]], %[[VAL_20]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_24]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_23]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_27]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_23]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_23]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        poly.yield %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @MultiAND {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @and : !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:        struct.member @and$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        struct.member @ands : !array.type<2 x !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @ands$inputs : !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@MultiAND::@MultiAND<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.new : <@MultiAND::@MultiAND<[@n]>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_34]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = poly.read_const @"n1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.read_const @"n2@[[OFFSET1]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_39]], @params = %[[VAL_38]] }  : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_35]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]]:6 = scf.if %[[VAL_46]] -> (!pod.type<[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_49]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_33]][@out] = %[[VAL_50]] : <@MultiAND::@MultiAND<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_40]], %[[VAL_41]], %[[VAL_42]], %[[VAL_43]], %[[VAL_44]], %[[VAL_50]] : !pod.type<[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_35]], %[[VAL_51]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]]:6 = scf.if %[[VAL_52]] -> (!pod.type<[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_55]], @params = %[[VAL_54]] }  : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_58]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_41]][@a] = %[[VAL_59]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@count] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_60]], %[[VAL_61]] : index
// CHECK-NEXT:              pod.write %[[VAL_56]][@count] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_62]], %[[VAL_63]] : index
// CHECK-NEXT:              scf.if %[[VAL_64]] {
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@params] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_68:[0-9a-zA-Z_\.]+]] = function.call @AND::@AND::@compute(%[[VAL_66]], %[[VAL_67]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:                pod.write %[[VAL_56]][@comp] = %[[VAL_68]] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_70]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_41]][@b] = %[[VAL_71]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@count] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_72]], %[[VAL_73]] : index
// CHECK-NEXT:              pod.write %[[VAL_56]][@count] = %[[VAL_74]] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_74]], %[[VAL_75]] : index
// CHECK-NEXT:              scf.if %[[VAL_76]] {
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@params] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = function.call @AND::@AND::@compute(%[[VAL_78]], %[[VAL_79]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:                pod.write %[[VAL_56]][@comp] = %[[VAL_80]] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@comp] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_81]][@out] : <@AND::@AND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              struct.writem %[[VAL_33]][@out] = %[[VAL_82]] : <@MultiAND::@MultiAND<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_56]], %[[VAL_41]], %[[VAL_42]], %[[VAL_43]], %[[VAL_44]], %[[VAL_82]] : !pod.type<[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_84]], @params = %[[VAL_83]] }  : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_35]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_35]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_35]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = poly.read_const @"n1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_91]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_93]], @params = %[[VAL_92]] }  : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[@"n1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_94]] : (!pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[@"n1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              array.write %[[VAL_42]]{{\[}}%[[VAL_96]]] = %[[VAL_97]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = poly.read_const @"n2@[[OFFSET1]]" : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_98]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_100]], @params = %[[VAL_99]] }  : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[@"n2@[[OFFSET1]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_101]] : (!pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[@"n2@[[OFFSET1]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              array.write %[[VAL_42]]{{\[}}%[[VAL_103]]] = %[[VAL_104]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_107:[0-9a-zA-Z_\.]+]] = %[[VAL_42]], %[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_43]], %[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_105]]) : (!array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_110:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_109]], %[[VAL_87]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_110]]) %[[VAL_107]], %[[VAL_108]], %[[VAL_109]] : !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_111:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_112:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_113:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_114]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_116]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]{{\[}}%[[VAL_117]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_119]]{{\[}}%[[VAL_120]]] = %[[VAL_115]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_122:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]{{\[}}%[[VAL_122]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_123]][@in] = %[[VAL_119]] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_112]]{{\[}}%[[VAL_125]]] = %[[VAL_123]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_127]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:                %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]{{\[}}%[[VAL_130]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@count] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:                %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_132]], %[[VAL_133]] : index
// CHECK-NEXT:                pod.write %[[VAL_128]][@count] = %[[VAL_134]] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:                %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_134]], %[[VAL_135]] : index
// CHECK-NEXT:                scf.if %[[VAL_136]] {
// CHECK-NEXT:                  %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@params] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                  %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_139]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_141:[0-9a-zA-Z_\.]+]] = function.call @MultiAND::@MultiAND::@compute(%[[VAL_138]]) {(%[[VAL_140]])} : (!array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                  pod.write %[[VAL_128]][@comp] = %[[VAL_141]] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_111]]{{\[}}%[[VAL_143]]] = %[[VAL_128]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:                %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_113]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_111]], %[[VAL_112]], %[[VAL_145]] : !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_147:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_148:[0-9a-zA-Z_\.]+]] = %[[VAL_106]]#0, %[[VAL_149:[0-9a-zA-Z_\.]+]] = %[[VAL_106]]#1, %[[VAL_150:[0-9a-zA-Z_\.]+]] = %[[VAL_146]]) : (!array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_151:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_150]], %[[VAL_90]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_151]]) %[[VAL_148]], %[[VAL_149]], %[[VAL_150]] : !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_152:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_153:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_154:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_154]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_156]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_160:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_153]]{{\[}}%[[VAL_159]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_160]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_154]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_161]]{{\[}}%[[VAL_162]]] = %[[VAL_157]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_153]]{{\[}}%[[VAL_164]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_165]][@in] = %[[VAL_161]] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_166]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_153]]{{\[}}%[[VAL_167]]] = %[[VAL_165]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_168]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_170:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_169]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:                %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_172:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_171]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_173:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_153]]{{\[}}%[[VAL_172]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@count] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:                %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_174]], %[[VAL_175]] : index
// CHECK-NEXT:                pod.write %[[VAL_170]][@count] = %[[VAL_176]] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:                %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_176]], %[[VAL_177]] : index
// CHECK-NEXT:                scf.if %[[VAL_178]] {
// CHECK-NEXT:                  %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@params] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                  %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_183:[0-9a-zA-Z_\.]+]] = function.call @MultiAND::@MultiAND::@compute(%[[VAL_180]]) {(%[[VAL_182]])} : (!array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                  pod.write %[[VAL_170]][@comp] = %[[VAL_183]] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_185:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_184]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_152]]{{\[}}%[[VAL_185]]] = %[[VAL_170]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:                %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_154]], %[[VAL_186]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_152]], %[[VAL_153]], %[[VAL_187]] : !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_188]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_147]]#0{{\[}}%[[VAL_189]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@comp] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_191]][@out] : <@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_41]][@a] = %[[VAL_192]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@count] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_193]], %[[VAL_194]] : index
// CHECK-NEXT:              pod.write %[[VAL_85]][@count] = %[[VAL_195]] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_197:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_195]], %[[VAL_196]] : index
// CHECK-NEXT:              scf.if %[[VAL_197]] {
// CHECK-NEXT:                %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@params] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_201:[0-9a-zA-Z_\.]+]] = function.call @AND::@AND::@compute(%[[VAL_199]], %[[VAL_200]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:                pod.write %[[VAL_85]][@comp] = %[[VAL_201]] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_147]]#0{{\[}}%[[VAL_203]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@comp] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@out] : <@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_41]][@b] = %[[VAL_206]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@count] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_207]], %[[VAL_208]] : index
// CHECK-NEXT:              pod.write %[[VAL_85]][@count] = %[[VAL_209]] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_209]], %[[VAL_210]] : index
// CHECK-NEXT:              scf.if %[[VAL_211]] {
// CHECK-NEXT:                %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@params] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_213:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_215:[0-9a-zA-Z_\.]+]] = function.call @AND::@AND::@compute(%[[VAL_213]], %[[VAL_214]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:                pod.write %[[VAL_85]][@comp] = %[[VAL_215]] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@comp] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:              %[[VAL_217:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_216]][@out] : <@AND::@AND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              struct.writem %[[VAL_33]][@out] = %[[VAL_217]] : <@MultiAND::@MultiAND<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_85]], %[[VAL_41]], %[[VAL_147]]#0, %[[VAL_147]]#1, %[[VAL_147]]#2, %[[VAL_217]] : !pod.type<[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_53]]#0, %[[VAL_53]]#1, %[[VAL_53]]#2, %[[VAL_53]]#3, %[[VAL_53]]#4, %[[VAL_53]]#5 : !pod.type<[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_33]][@and$inputs] = %[[VAL_47]]#1 : <@MultiAND::@MultiAND<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]]#0[@comp] : <[@count: index, @comp: !struct.type<@AND::@AND<[]>>, @params: !pod.type<[]>]>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_33]][@and] = %[[VAL_218]] : <@MultiAND::@MultiAND<[@n]>>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_33]][@ands$inputs] = %[[VAL_47]]#3 : <@MultiAND::@MultiAND<[@n]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_223:[0-9a-zA-Z_\.]+]] = %[[VAL_221]] to %[[VAL_220]] step %[[VAL_222]] {
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]#2{{\[}}%[[VAL_223]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_224]][@comp] : <[@count: index, @comp: !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_219]]{{\[}}%[[VAL_223]]] = %[[VAL_225]] : <2 x !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_33]][@ands] = %[[VAL_219]] : <@MultiAND::@MultiAND<[@n]>>, !array.type<2 x !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          function.return %[[VAL_33]] : !struct.type<@MultiAND::@MultiAND<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_226:[0-9a-zA-Z_\.]+]]: !struct.type<@MultiAND::@MultiAND<[@n]>>, %[[VAL_227:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_228]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = poly.read_const @"n1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = poly.read_const @"n2@[[OFFSET1]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@out] : <@MultiAND::@MultiAND<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@and] : <@MultiAND::@MultiAND<[@n]>>, !struct.type<@AND::@AND<[]>>
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@and$inputs] : <@MultiAND::@MultiAND<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@ands] : <@MultiAND::@MultiAND<[@n]>>, !array.type<2 x !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_226]][@ands$inputs] : <@MultiAND::@MultiAND<[@n]>>, !array.type<2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_229]], %[[VAL_238]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_239]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_241]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_243:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_227]]{{\[}}%[[VAL_242]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_232]], %[[VAL_243]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_229]], %[[VAL_244]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_245]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_248:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_247]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_249:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_227]]{{\[}}%[[VAL_248]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_250]], %[[VAL_249]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_251]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_227]]{{\[}}%[[VAL_252]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_254]], %[[VAL_253]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_233]][@out] : <@AND::@AND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_232]], %[[VAL_255]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_229]], %[[VAL_256]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_229]], %[[VAL_258]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_260:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_229]], %[[VAL_259]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_261:[0-9a-zA-Z_\.]+]] = poly.read_const @"n1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_262:[0-9a-zA-Z_\.]+]] = poly.read_const @"n2@[[OFFSET1]]" : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_264:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_265:[0-9a-zA-Z_\.]+]] = %[[VAL_263]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_266:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_265]], %[[VAL_257]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_266]]) %[[VAL_265]] : !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_267:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_268:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_267]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_269:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_227]]{{\[}}%[[VAL_268]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_270]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_272:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_236]]{{\[}}%[[VAL_271]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_273:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_272]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_274:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_267]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_275:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_273]]{{\[}}%[[VAL_274]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_275]], %[[VAL_269]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_276:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_267]], %[[VAL_276]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_278:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_279:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_280:[0-9a-zA-Z_\.]+]] = %[[VAL_278]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_281:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_280]], %[[VAL_260]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_281]]) %[[VAL_280]] : !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_282:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_257]], %[[VAL_282]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_284:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_283]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_285:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_227]]{{\[}}%[[VAL_284]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_287:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_288:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_236]]{{\[}}%[[VAL_287]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_288]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_290:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_282]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_291:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_289]]{{\[}}%[[VAL_290]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_291]], %[[VAL_285]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_282]], %[[VAL_292]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_293]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_294]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_296:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_235]]{{\[}}%[[VAL_295]]] : <2 x !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_296]][@out] : <@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_298]], %[[VAL_297]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_300:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_299]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_301:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_235]]{{\[}}%[[VAL_300]]] : <2 x !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_302:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_301]][@out] : <@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_303:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_303]], %[[VAL_302]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_304:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_233]][@out] : <@AND::@AND<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_232]], %[[VAL_304]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_279]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_246]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_305:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_306:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @AND::@AND::@constrain(%[[VAL_233]], %[[VAL_305]], %[[VAL_306]]) : (!struct.type<@AND::@AND<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_308:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_309:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_310:[0-9a-zA-Z_\.]+]] = %[[VAL_308]] to %[[VAL_307]] step %[[VAL_309]] {
// CHECK-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_235]]{{\[}}%[[VAL_310]]] : <2 x !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>>, !struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_236]]{{\[}}%[[VAL_310]]] : <2 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_312]][@in] : <[@in: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @MultiAND::@MultiAND::@constrain(%[[VAL_311]], %[[VAL_313]]) : (!struct.type<@MultiAND::@MultiAND<[#[[$ATTR_0]]]>>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
