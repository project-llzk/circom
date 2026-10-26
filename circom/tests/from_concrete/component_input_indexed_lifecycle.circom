// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// A function call keeps row assignments intact instead of expanding array literals
// into separate scalar writes before LLZK generation.
function make_row(x) {
    return [x, x + 1, x + 2];
}

template Grid(n) {
    signal input in[n][3];
    signal input bias;
    signal output out;
    out <== in[0][0] + bias;
}

template Main() {
    component direct = Grid(2);
    direct.in[0] <-- make_row(1);
    direct.in[1][0] <-- 4;
    direct.in[1][1] <-- 5;
    direct.in[1][2] <-- 6;
    direct.bias <-- 7;
    direct.out === 8;

    component mixed[2];
    mixed[0] = Grid(1);
    mixed[1] = Grid(2);
    for (var i = 0; i < 2; i++) {
        for (var row = 0; row <= i; row++) {
            mixed[i].in[row] <-- make_row(1);
        }
        mixed[i].bias <-- 7;
        mixed[i].out === 8;
    }
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_2::@Main_2<[]>>} {
// CHECK-NEXT:    poly.template @make_row_0 {
// CHECK-NEXT:      function.def @make_row_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x"}) -> !array.type<3 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_3]]] = %[[VAL_0]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_11]]] = %[[VAL_9]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        function.return %[[VAL_1]] : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Grid_0 {
// CHECK-NEXT:      struct.def @Grid_0 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">> {function.arg_name = "in"}, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "bias"}) -> !struct.type<@Grid_0::@Grid_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.new : <@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_16]], %[[VAL_18]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_14]][@out] = %[[VAL_20]] : <@Grid_0::@Grid_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_14]] : !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !struct.type<@Grid_0::@Grid_0<[]>>, %[[VAL_22:[0-9a-zA-Z_\.]+]]: !array.type<2,3 x !felt.type<"bn128">> {function.arg_name = "in"}, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "bias"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@Grid_0::@Grid_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_26]], %[[VAL_28]]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_29]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Grid_1 {
// CHECK-NEXT:      struct.def @Grid_1 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type<"bn128">> {function.arg_name = "in"}, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "bias"}) -> !struct.type<@Grid_1::@Grid_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.new : <@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_35]], %[[VAL_37]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_33]][@out] = %[[VAL_39]] : <@Grid_1::@Grid_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_33]] : !struct.type<@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !struct.type<@Grid_1::@Grid_1<[]>>, %[[VAL_41:[0-9a-zA-Z_\.]+]]: !array.type<1,3 x !felt.type<"bn128">> {function.arg_name = "in"}, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "bias"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_40]][@out] : <@Grid_1::@Grid_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_45]], %[[VAL_47]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_48]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main_2 {
// CHECK-NEXT:      struct.def @Main_2 {
// CHECK-NEXT:        struct.member @direct : !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:        struct.member @direct$inputs : !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        struct.member @mixed : !pod.type<[@idx_0: !struct.type<@Grid_1::@Grid_1<[]>>, @idx_1: !struct.type<@Grid_0::@Grid_0<[]>>]>
// CHECK-NEXT:        struct.member @mixed$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main_2::@Main_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_2::@Main_2<[]>>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_52]], @params = %[[VAL_51]] }  : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_56]], @params = %[[VAL_55]] }  : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_58]], @params = %[[VAL_55]] }  : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_57]], @idx_1 = %[[VAL_59]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = function.call @make_row_0::@make_row_0(%[[VAL_62]]) : (!felt.type<"bn128">) -> !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_64]]{{\[}}%[[VAL_66]]] = %[[VAL_63]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          pod.write %[[VAL_54]][@in] = %[[VAL_64]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@count] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_67]], %[[VAL_68]] : index
// CHECK-NEXT:          pod.write %[[VAL_53]][@count] = %[[VAL_69]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_69]], %[[VAL_70]] : index
// CHECK-NEXT:          scf.if %[[VAL_71]] {
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@params] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = function.call @Grid_0::@Grid_0::@compute(%[[VAL_73]], %[[VAL_74]]) : (!array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_53]][@comp] = %[[VAL_75]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_77]]{{\[}}%[[VAL_79]], %[[VAL_81]]] = %[[VAL_76]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_54]][@in] = %[[VAL_77]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@count] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_82]], %[[VAL_83]] : index
// CHECK-NEXT:          pod.write %[[VAL_53]][@count] = %[[VAL_84]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_84]], %[[VAL_85]] : index
// CHECK-NEXT:          scf.if %[[VAL_86]] {
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@params] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = function.call @Grid_0::@Grid_0::@compute(%[[VAL_88]], %[[VAL_89]]) : (!array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_53]][@comp] = %[[VAL_90]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_92]]{{\[}}%[[VAL_94]], %[[VAL_96]]] = %[[VAL_91]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_54]][@in] = %[[VAL_92]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@count] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_97]], %[[VAL_98]] : index
// CHECK-NEXT:          pod.write %[[VAL_53]][@count] = %[[VAL_99]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_99]], %[[VAL_100]] : index
// CHECK-NEXT:          scf.if %[[VAL_101]] {
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@params] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = function.call @Grid_0::@Grid_0::@compute(%[[VAL_103]], %[[VAL_104]]) : (!array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_53]][@comp] = %[[VAL_105]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_107]]{{\[}}%[[VAL_109]], %[[VAL_111]]] = %[[VAL_106]] : <2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_54]][@in] = %[[VAL_107]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@count] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_112]], %[[VAL_113]] : index
// CHECK-NEXT:          pod.write %[[VAL_53]][@count] = %[[VAL_114]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_114]], %[[VAL_115]] : index
// CHECK-NEXT:          scf.if %[[VAL_116]] {
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@params] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = function.call @Grid_0::@Grid_0::@compute(%[[VAL_118]], %[[VAL_119]]) : (!array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_53]][@comp] = %[[VAL_120]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          pod.write %[[VAL_54]][@bias] = %[[VAL_121]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@count] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_122]], %[[VAL_123]] : index
// CHECK-NEXT:          pod.write %[[VAL_53]][@count] = %[[VAL_124]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_124]], %[[VAL_125]] : index
// CHECK-NEXT:          scf.if %[[VAL_126]] {
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@params] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = function.call @Grid_0::@Grid_0::@compute(%[[VAL_128]], %[[VAL_129]]) : (!array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:            pod.write %[[VAL_53]][@comp] = %[[VAL_130]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_131]], %[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_60]], %[[VAL_135:[0-9a-zA-Z_\.]+]] = %[[VAL_61]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>) {
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_133]], %[[VAL_136]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_137]]) %[[VAL_133]], %[[VAL_134]], %[[VAL_135]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_139:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_140:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>):
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_143:[0-9a-zA-Z_\.]+]] = %[[VAL_139]], %[[VAL_144:[0-9a-zA-Z_\.]+]] = %[[VAL_140]], %[[VAL_145:[0-9a-zA-Z_\.]+]] = %[[VAL_141]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_146:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_145]], %[[VAL_138]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_146]]) %[[VAL_143]], %[[VAL_144]], %[[VAL_145]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_147:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_148:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, %[[VAL_149:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_151:[0-9a-zA-Z_\.]+]] = function.call @make_row_0::@make_row_0(%[[VAL_150]]) : (!felt.type<"bn128">) -> !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_152:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_152]], %[[VAL_154]] : index
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_153]], %[[VAL_155]] : i1, i1
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_152]], %[[VAL_157]] : index
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_153]], %[[VAL_158]] : i1, i1
// CHECK-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>) {
// CHECK-NEXT:                %[[VAL_161:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_159]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>) {
// CHECK-NEXT:                  %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_147]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:                  %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.insert %[[VAL_164]]{{\[}}%[[VAL_165]]] = %[[VAL_151]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_163]][@in] = %[[VAL_164]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_148]][@idx_1] = %[[VAL_163]] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:                  %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@count] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:                  %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_166]], %[[VAL_167]] : index
// CHECK-NEXT:                  pod.write %[[VAL_162]][@count] = %[[VAL_168]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_168]], %[[VAL_169]] : index
// CHECK-NEXT:                  scf.if %[[VAL_170]] {
// CHECK-NEXT:                    %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@params] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_174:[0-9a-zA-Z_\.]+]] = function.call @Grid_0::@Grid_0::@compute(%[[VAL_172]], %[[VAL_173]]) : (!array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_162]][@comp] = %[[VAL_174]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_147]][@idx_1] = %[[VAL_162]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_147]], %[[VAL_148]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_175:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_156]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>) {
// CHECK-NEXT:                    %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_147]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:                    %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@in] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:                    array.insert %[[VAL_178]]{{\[}}%[[VAL_179]]] = %[[VAL_151]] : <1,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_177]][@in] = %[[VAL_178]] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_148]][@idx_0] = %[[VAL_177]] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:                    %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@count] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:                    %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_180]], %[[VAL_181]] : index
// CHECK-NEXT:                    pod.write %[[VAL_176]][@count] = %[[VAL_182]] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_182]], %[[VAL_183]] : index
// CHECK-NEXT:                    scf.if %[[VAL_184]] {
// CHECK-NEXT:                      %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@params] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@in] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@bias] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                      %[[VAL_188:[0-9a-zA-Z_\.]+]] = function.call @Grid_1::@Grid_1::@compute(%[[VAL_186]], %[[VAL_187]]) : (!array.type<1,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_176]][@comp] = %[[VAL_188]] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_147]][@idx_0] = %[[VAL_176]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_147]], %[[VAL_148]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_189:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_190:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_189]], %[[VAL_190]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_175]]#0, %[[VAL_175]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_161]]#0, %[[VAL_161]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_149]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_160]]#0, %[[VAL_160]]#1, %[[VAL_192]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_194]], %[[VAL_196]] : index
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_195]], %[[VAL_197]] : i1, i1
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_194]], %[[VAL_199]] : index
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_195]], %[[VAL_200]] : i1, i1
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>) {
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_201]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>) {
// CHECK-NEXT:                %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]]#1[@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_205]][@bias] = %[[VAL_193]] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                pod.write %[[VAL_142]]#1[@idx_1] = %[[VAL_205]] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@count] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_207:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_208:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_206]], %[[VAL_207]] : index
// CHECK-NEXT:                pod.write %[[VAL_204]][@count] = %[[VAL_208]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_208]], %[[VAL_209]] : index
// CHECK-NEXT:                scf.if %[[VAL_210]] {
// CHECK-NEXT:                  %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@params] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_213:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_214:[0-9a-zA-Z_\.]+]] = function.call @Grid_0::@Grid_0::@compute(%[[VAL_212]], %[[VAL_213]]) : (!array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_204]][@comp] = %[[VAL_214]] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:                }
// CHECK-NEXT:                pod.write %[[VAL_142]]#0[@idx_1] = %[[VAL_204]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                scf.yield %[[VAL_142]]#0, %[[VAL_142]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_215:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_198]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>) {
// CHECK-NEXT:                  %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]]#1[@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:                  pod.write %[[VAL_217]][@bias] = %[[VAL_193]] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  pod.write %[[VAL_142]]#1[@idx_0] = %[[VAL_217]] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:                  %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@count] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_219:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_220:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_218]], %[[VAL_219]] : index
// CHECK-NEXT:                  pod.write %[[VAL_216]][@count] = %[[VAL_220]] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_220]], %[[VAL_221]] : index
// CHECK-NEXT:                  scf.if %[[VAL_222]] {
// CHECK-NEXT:                    %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@params] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_224:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@in] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@bias] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_226:[0-9a-zA-Z_\.]+]] = function.call @Grid_1::@Grid_1::@compute(%[[VAL_224]], %[[VAL_225]]) : (!array.type<1,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !struct.type<@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_216]][@comp] = %[[VAL_226]] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_142]]#0[@idx_0] = %[[VAL_216]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_142]]#0, %[[VAL_142]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_227:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                  %[[VAL_228:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_227]], %[[VAL_228]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_215]]#0, %[[VAL_215]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_203]]#0, %[[VAL_203]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_138]], %[[VAL_229]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_230]], %[[VAL_202]]#0, %[[VAL_202]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_50]][@direct$inputs] = %[[VAL_54]] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@comp] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_50]][@direct] = %[[VAL_231]] : <@Main_2::@Main_2<[]>>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_50]][@mixed$inputs] = %[[VAL_132]]#2 : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@comp] : <[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Grid_1::@Grid_1<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@comp] : <[@count: index, @comp: !struct.type<@Grid_0::@Grid_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_233]], @idx_1 = %[[VAL_235]] }  : <[@idx_0: !struct.type<@Grid_1::@Grid_1<[]>>, @idx_1: !struct.type<@Grid_0::@Grid_0<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_50]][@mixed] = %[[VAL_236]] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !struct.type<@Grid_1::@Grid_1<[]>>, @idx_1: !struct.type<@Grid_0::@Grid_0<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_50]] : !struct.type<@Main_2::@Main_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_237:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_2::@Main_2<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@direct] : <@Main_2::@Main_2<[]>>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@direct$inputs] : <@Main_2::@Main_2<[]>>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@mixed] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !struct.type<@Grid_1::@Grid_1<[]>>, @idx_1: !struct.type<@Grid_0::@Grid_0<[]>>]>
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@mixed$inputs] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_238]][@out] : <@Grid_0::@Grid_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_242]], %[[VAL_243]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_246:[0-9a-zA-Z_\.]+]] = %[[VAL_244]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_246]], %[[VAL_247]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_248]]) %[[VAL_246]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_249:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_251:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_252:[0-9a-zA-Z_\.]+]] = %[[VAL_250]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_252]], %[[VAL_249]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_253]]) %[[VAL_252]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_254:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_254]], %[[VAL_255]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_256]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_249]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_260:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_257]], %[[VAL_259]] : index
// CHECK-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_258]], %[[VAL_260]] : i1, i1
// CHECK-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_263:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_257]], %[[VAL_262]] : index
// CHECK-NEXT:            %[[VAL_264:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_258]], %[[VAL_263]] : i1, i1
// CHECK-NEXT:            %[[VAL_265:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_266:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_264]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_267:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_240]][@idx_1] : <[@idx_0: !struct.type<@Grid_1::@Grid_1<[]>>, @idx_1: !struct.type<@Grid_0::@Grid_0<[]>>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:                %[[VAL_268:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_267]][@out] : <@Grid_0::@Grid_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_268]] : !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_269:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_261]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_240]][@idx_0] : <[@idx_0: !struct.type<@Grid_1::@Grid_1<[]>>, @idx_1: !struct.type<@Grid_0::@Grid_0<[]>>]>, !struct.type<@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:                  %[[VAL_271:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_270]][@out] : <@Grid_1::@Grid_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_271]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_272:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_272]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_269]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_266]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_265]], %[[VAL_273]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_275:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_249]], %[[VAL_274]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_275]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Grid_0::@Grid_0::@constrain(%[[VAL_238]], %[[VAL_276]], %[[VAL_277]]) : (!struct.type<@Grid_0::@Grid_0<[]>>, !array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_240]][@idx_0] : <[@idx_0: !struct.type<@Grid_1::@Grid_1<[]>>, @idx_1: !struct.type<@Grid_0::@Grid_0<[]>>]>, !struct.type<@Grid_1::@Grid_1<[]>>
// CHECK-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_241]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_279]][@in] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_279]][@bias] : <[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Grid_1::@Grid_1::@constrain(%[[VAL_278]], %[[VAL_280]], %[[VAL_281]]) : (!struct.type<@Grid_1::@Grid_1<[]>>, !array.type<1,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_240]][@idx_1] : <[@idx_0: !struct.type<@Grid_1::@Grid_1<[]>>, @idx_1: !struct.type<@Grid_0::@Grid_0<[]>>]>, !struct.type<@Grid_0::@Grid_0<[]>>
// CHECK-NEXT:          %[[VAL_283:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_241]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<1,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, @idx_1: !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>]>, !pod.type<[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_284:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_283]][@in] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_285:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_283]][@bias] : <[@in: !array.type<2,3 x !felt.type<"bn128">>, @bias: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Grid_0::@Grid_0::@constrain(%[[VAL_282]], %[[VAL_284]], %[[VAL_285]]) : (!struct.type<@Grid_0::@Grid_0<[]>>, !array.type<2,3 x !felt.type<"bn128">>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
