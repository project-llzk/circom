// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Multiplier2() {
   signal input in1;
   signal input in2;
   signal output out <== in1 * in2;
}

//This circuit multiplies in1, in2, and in3.
template Multiplier3() {
   //Declaration of signals and components.
   signal input in1;
   signal input in2;
   signal input in3;
   signal output out;
   component mult1 = Multiplier2();
   component mult2 = Multiplier2();

   //Statements.
   mult1.in1 <== in1;
   mult1.in2 <== in2;
   mult2.in1 <== mult1.out;
   mult2.in2 <== in3;
   out <== mult2.out;
}

component main = Multiplier3();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Multiplier3::@Multiplier3<[]>>} {
// CHECK-NEXT:    poly.template @Multiplier2 {
// CHECK-NEXT:      struct.def @Multiplier2 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in2"}) -> !struct.type<@Multiplier2::@Multiplier2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Multiplier2::@Multiplier2<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1"}, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in2"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Multiplier3 {
// CHECK-NEXT:      struct.def @Multiplier3 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @mult1 : !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:        struct.member @mult1$inputs : !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        struct.member @mult2 : !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:        struct.member @mult2$inputs : !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1"}, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in2"}, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in3"}) -> !struct.type<@Multiplier3::@Multiplier3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@Multiplier3::@Multiplier3<[]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_14]], @params = %[[VAL_13]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]], @params = %[[VAL_17]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_22]], @params = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_25]], @params = %[[VAL_24]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          pod.write %[[VAL_16]][@in1] = %[[VAL_9]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:          pod.write %[[VAL_23]][@count] = %[[VAL_29]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_29]], %[[VAL_30]] : index
// CHECK-NEXT:          scf.if %[[VAL_31]] {
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_33]], %[[VAL_34]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_23]][@comp] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_16]][@in2] = %[[VAL_10]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_36]], %[[VAL_37]] : index
// CHECK-NEXT:          pod.write %[[VAL_23]][@count] = %[[VAL_38]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_38]], %[[VAL_39]] : index
// CHECK-NEXT:          scf.if %[[VAL_40]] {
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_42]], %[[VAL_43]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_23]][@comp] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_20]][@in1] = %[[VAL_46]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_47]], %[[VAL_48]] : index
// CHECK-NEXT:          pod.write %[[VAL_26]][@count] = %[[VAL_49]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_49]], %[[VAL_50]] : index
// CHECK-NEXT:          scf.if %[[VAL_51]] {
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_53]], %[[VAL_54]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_26]][@comp] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_20]][@in2] = %[[VAL_11]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_56]], %[[VAL_57]] : index
// CHECK-NEXT:          pod.write %[[VAL_26]][@count] = %[[VAL_58]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_58]], %[[VAL_59]] : index
// CHECK-NEXT:          scf.if %[[VAL_60]] {
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_62]], %[[VAL_63]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_26]][@comp] = %[[VAL_64]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_65]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_12]][@out] = %[[VAL_66]] : <@Multiplier3::@Multiplier3<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_12]][@mult1$inputs] = %[[VAL_16]] : <@Multiplier3::@Multiplier3<[]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_12]][@mult1] = %[[VAL_67]] : <@Multiplier3::@Multiplier3<[]>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_12]][@mult2$inputs] = %[[VAL_20]] : <@Multiplier3::@Multiplier3<[]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_12]][@mult2] = %[[VAL_68]] : <@Multiplier3::@Multiplier3<[]>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          function.return %[[VAL_12]] : !struct.type<@Multiplier3::@Multiplier3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !struct.type<@Multiplier3::@Multiplier3<[]>>, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1"}, %[[VAL_71:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in2"}, %[[VAL_72:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@out] : <@Multiplier3::@Multiplier3<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@mult1] : <@Multiplier3::@Multiplier3<[]>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@mult1$inputs] : <@Multiplier3::@Multiplier3<[]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@mult2] : <@Multiplier3::@Multiplier3<[]>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@mult2$inputs] : <@Multiplier3::@Multiplier3<[]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_82]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_83]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_85]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_86]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_73]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Multiplier2::@Multiplier2::@constrain(%[[VAL_74]], %[[VAL_88]], %[[VAL_89]]) : (!struct.type<@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Multiplier2::@Multiplier2::@constrain(%[[VAL_76]], %[[VAL_90]], %[[VAL_91]]) : (!struct.type<@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
