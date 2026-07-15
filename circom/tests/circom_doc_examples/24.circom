// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template Ex(n, m){
   signal input in[n];
   signal output out[m];
   var i = 0;
   while(i < n) {
      out[i] <== in[i];
      i += 1;
   }
}

template A{
   signal input inp[4];
   signal output out[4];
   component anon = Ex(4,4);
   var i = 0;
   while(i < 4){
      anon.in[i] <== inp[i];
      i += 1;
   }
   i = 0;
   while(i < 4){
      out[i] <== anon.out[i];
      i += 1;
   }
}
component main = A();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @anon : !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:        struct.member @anon$inputs : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_4]], @m = %[[VAL_5]] }  : <[@n: index, @m: index]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_7]], @params = %[[VAL_6]] }  : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_13]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_14]]) %[[VAL_11]], %[[VAL_12]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_17]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_20]]] = %[[VAL_18]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_15]][@in] = %[[VAL_19]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@count] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:            pod.write %[[VAL_8]][@count] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_23]], %[[VAL_24]] : index
// CHECK-NEXT:            scf.if %[[VAL_25]] {
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@params] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, !pod.type<[@n: index, @m: index]>
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @Ex::@Ex::@compute(%[[VAL_27]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:              pod.write %[[VAL_8]][@comp] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_15]], %[[VAL_30]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_31]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_33]], %[[VAL_34]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_35]]) %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@out] : <@Ex::@Ex<[4, 4]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_39]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_41]]] = %[[VAL_40]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@anon$inputs] = %[[VAL_10]]#0 : <@A::@A<[]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@anon] = %[[VAL_44]] : <@A::@A<[]>>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@A::@A<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@out] : <@A::@A<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@anon] : <@A::@A<[]>>, !struct.type<@Ex::@Ex<[4, 4]>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@anon$inputs] : <@A::@A<[]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_50]], @m = %[[VAL_51]] }  : <[@n: index, @m: index]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Ex::@Ex<[4, 4]>>, @params: !pod.type<[@n: index, @m: index]>]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_54]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_56]], %[[VAL_57]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_58]]) %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_60]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_63]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_64]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_59]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_67]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_69]], %[[VAL_70]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_71]]) %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_72:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@out] : <@Ex::@Ex<[4, 4]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_74]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_76]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_77]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Ex::@Ex::@constrain(%[[VAL_48]], %[[VAL_80]]) : (!struct.type<@Ex::@Ex<[4, 4]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Ex {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.param @m : index
// CHECK-NEXT:      struct.def @Ex {
// CHECK-NEXT:        struct.member @out : !array.type<@m x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Ex::@Ex<[@n, @m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.new : <@Ex::@Ex<[@n, @m]>>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_83]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_85]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_88]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_90]], %[[VAL_86]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_91]]) %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_92:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_93]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_87]]{{\[}}%[[VAL_95]]] = %[[VAL_94]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_92]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_82]][@out] = %[[VAL_87]] : <@Ex::@Ex<[@n, @m]>>, !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_82]] : !struct.type<@Ex::@Ex<[@n, @m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_98:[0-9a-zA-Z_\.]+]]: !struct.type<@Ex::@Ex<[@n, @m]>>, %[[VAL_99:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_100]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_102]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_98]][@out] : <@Ex::@Ex<[@n, @m]>>, !array.type<@m x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_107:[0-9a-zA-Z_\.]+]] = %[[VAL_105]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_107]], %[[VAL_103]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_108]]) %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_109:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_110]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_112]]] : <@m x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_113]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_109]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
