// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Vector() {
    signal input in[4];
    signal output out[4];
    out <== in;
}

template Main() {
    // Assigning a shorter array must preserve the previously assigned tail.
    // Both input fields should contain [11, 22, 33, 44] after the assignments.
    component witness = Vector();
    witness.in[2] <-- 33;
    witness.in[3] <-- 44;
    witness.in <-- [11, 22];

    component constrained = Vector();
    constrained.in[2] <== 33;
    constrained.in[3] <== 44;
    constrained.in <== [11, 22];
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 11 : <"bn128">,  22 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @constrained : !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:        struct.member @constrained$inputs : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        struct.member @witness : !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:        struct.member @witness$inputs : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_7]]{{\[}}%[[VAL_9]]] = %[[VAL_6]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_2]][@in] = %[[VAL_7]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_10]], %[[VAL_11]] : index
// CHECK-NEXT:          pod.write %[[VAL_5]][@count] = %[[VAL_12]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_12]], %[[VAL_13]] : index
// CHECK-NEXT:          scf.if %[[VAL_14]] {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = function.call @Vector::@Vector::@compute(%[[VAL_16]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:            pod.write %[[VAL_5]][@comp] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  44 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_19]]{{\[}}%[[VAL_21]]] = %[[VAL_18]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_2]][@in] = %[[VAL_19]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:          pod.write %[[VAL_5]][@count] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_24]], %[[VAL_25]] : index
// CHECK-NEXT:          scf.if %[[VAL_26]] {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = function.call @Vector::@Vector::@compute(%[[VAL_28]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:            pod.write %[[VAL_5]][@comp] = %[[VAL_29]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_31]][] : <4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_34]] to %[[VAL_33]] step %[[VAL_35]] {
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_36]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_32]]{{\[}}%[[VAL_36]]] = %[[VAL_37]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_2]][@in] = %[[VAL_32]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_38]], %[[VAL_39]] : index
// CHECK-NEXT:          pod.write %[[VAL_5]][@count] = %[[VAL_40]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_40]], %[[VAL_41]] : index
// CHECK-NEXT:          scf.if %[[VAL_42]] {
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @Vector::@Vector::@compute(%[[VAL_44]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:            pod.write %[[VAL_5]][@comp] = %[[VAL_45]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_47]], @params = %[[VAL_46]] }  : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_50]]{{\[}}%[[VAL_52]]] = %[[VAL_49]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_1]][@in] = %[[VAL_50]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@count] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// CHECK-NEXT:          pod.write %[[VAL_48]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:          scf.if %[[VAL_57]] {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@params] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = function.call @Vector::@Vector::@compute(%[[VAL_59]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:            pod.write %[[VAL_48]][@comp] = %[[VAL_60]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  44 : <"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_62]]{{\[}}%[[VAL_64]]] = %[[VAL_61]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_1]][@in] = %[[VAL_62]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@count] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_65]], %[[VAL_66]] : index
// CHECK-NEXT:          pod.write %[[VAL_48]][@count] = %[[VAL_67]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_67]], %[[VAL_68]] : index
// CHECK-NEXT:          scf.if %[[VAL_69]] {
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@params] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = function.call @Vector::@Vector::@compute(%[[VAL_71]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:            pod.write %[[VAL_48]][@comp] = %[[VAL_72]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_74]][] : <4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_79:[0-9a-zA-Z_\.]+]] = %[[VAL_77]] to %[[VAL_76]] step %[[VAL_78]] {
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_79]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_75]]{{\[}}%[[VAL_79]]] = %[[VAL_80]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_1]][@in] = %[[VAL_75]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@count] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_81]], %[[VAL_82]] : index
// CHECK-NEXT:          pod.write %[[VAL_48]][@count] = %[[VAL_83]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_83]], %[[VAL_84]] : index
// CHECK-NEXT:          scf.if %[[VAL_85]] {
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@params] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = function.call @Vector::@Vector::@compute(%[[VAL_87]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:            pod.write %[[VAL_48]][@comp] = %[[VAL_88]] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@constrained$inputs] = %[[VAL_1]] : <@Main::@Main<[]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@comp] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@constrained] = %[[VAL_89]] : <@Main::@Main<[]>>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@witness$inputs] = %[[VAL_2]] : <@Main::@Main<[]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@Vector::@Vector<[]>>, @params: !pod.type<[]>]>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@witness] = %[[VAL_90]] : <@Main::@Main<[]>>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_91:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_91]][@constrained] : <@Main::@Main<[]>>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_91]][@constrained$inputs] : <@Main::@Main<[]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_91]][@witness] : <@Main::@Main<[]>>, !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_91]][@witness$inputs] : <@Main::@Main<[]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  33 : <"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_98]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_97]]{{\[}}%[[VAL_99]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_100]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  44 : <"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_104]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_105]], %[[VAL_101]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_107]][] : <4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_112:[0-9a-zA-Z_\.]+]] = %[[VAL_110]] to %[[VAL_109]] step %[[VAL_111]] {
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_112]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_108]]{{\[}}%[[VAL_112]]] = %[[VAL_113]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_107]], %[[VAL_108]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector::@Vector::@constrain(%[[VAL_92]], %[[VAL_114]]) : (!struct.type<@Vector::@Vector<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Vector::@Vector::@constrain(%[[VAL_94]], %[[VAL_115]]) : (!struct.type<@Vector::@Vector<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Vector {
// CHECK-NEXT:      struct.def @Vector {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_116:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Vector::@Vector<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = struct.new : <@Vector::@Vector<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_117]][@out] = %[[VAL_116]] : <@Vector::@Vector<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_117]] : !struct.type<@Vector::@Vector<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_118:[0-9a-zA-Z_\.]+]]: !struct.type<@Vector::@Vector<[]>>, %[[VAL_119:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_118]][@out] : <@Vector::@Vector<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_120]], %[[VAL_119]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
