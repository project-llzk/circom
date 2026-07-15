// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(N){
   signal input in;
   signal output out;
   out <== in;
}
template C(N){
   signal output out;
   out <== N;
}
template B(N){
  signal output out;
  signal output branch;
  component a;

  if(N > 0){
     a = A(N+2);
     branch <== 1;
  }
  else{
     a = A(N+1);
     branch <== 0;
  }
  a.in <== 1;
  a.out ==> out;
}
template D() {
  component b0 = B(0);
  component b1 = B(1);

  signal output outs[2];
  signal output branches[2];
  outs[0] <== b0.out;
  outs[1] <== b1.out;
  branches[0] <== b0.branch;
  branches[1] <== b1.branch;
}

component main = D();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@D::@D<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@A::@A<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@N]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@N]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@A::@A<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_8]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.expr @"N_Add_1@509" {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_11]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_12]], %[[VAL_9]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_13]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        poly.yield %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"N_Add_2@461" {
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_20]], %[[VAL_17]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_21]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        poly.yield %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @branch : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a : !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B::@B<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@N]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_26]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Add_1@509" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Add_2@461" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_27]], %[[VAL_31]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_32]] -> (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Add_2@461" : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_35]] }  : <[@N: index]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_37]], @params = %[[VAL_36]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@"N_Add_2@461"]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_38]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@"N_Add_2@461"]>>, @params: !pod.type<[@N: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_25]][@branch] = %[[VAL_40]] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_39]], %[[VAL_40]] : !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Add_1@509" : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_42]] }  : <[@N: index]>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_44]], @params = %[[VAL_43]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@"N_Add_1@509"]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_45]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@"N_Add_1@509"]>>, @params: !pod.type<[@N: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_25]][@branch] = %[[VAL_47]] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_46]], %[[VAL_47]] : !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          pod.write %[[VAL_30]][@in] = %[[VAL_48]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]]#0[@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_49]], %[[VAL_50]] : index
// CHECK-NEXT:          pod.write %[[VAL_33]]#0[@count] = %[[VAL_51]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_51]], %[[VAL_52]] : index
// CHECK-NEXT:          scf.if %[[VAL_53]] {
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]]#0[@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, !pod.type<[@N: index]>
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@N] : <[@N: index]>, index
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_55]]) {(%[[VAL_56]])} : (!felt.type<"bn128">) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            pod.write %[[VAL_33]]#0[@comp] = %[[VAL_57]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]]#0[@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@out] : <@A::@A<[#map]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_25]][@out] = %[[VAL_59]] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_25]][@a$inputs] = %[[VAL_30]] : <@B::@B<[@N]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]]#0[@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:          struct.writem %[[VAL_25]][@a] = %[[VAL_60]] : <@B::@B<[@N]>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:          function.return %[[VAL_25]] : !struct.type<@B::@B<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_62]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Add_1@509" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Add_2@461" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@out] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@branch] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@a] : <@B::@B<[@N]>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@a$inputs] : <@B::@B<[@N]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_63]], %[[VAL_70]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_71]] {
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Add_2@461" : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_73]] }  : <[@N: index]>
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@"N_Add_2@461"]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_67]], %[[VAL_76]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Add_1@509" : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_78]] }  : <[@N: index]>
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@"N_Add_1@509"]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_67]], %[[VAL_81]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_83]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@out] : <@A::@A<[#map]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_66]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @A::@A::@constrain(%[[VAL_68]], %[[VAL_85]]) : (!struct.type<@A::@A<[#map]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @D {
// CHECK-NEXT:      struct.def @D {
// CHECK-NEXT:        struct.member @outs : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @branches : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @b0 : !struct.type<@B::@B<[0]>>
// CHECK-NEXT:        struct.member @b0$inputs : !pod.type<[]>
// CHECK-NEXT:        struct.member @b1 : !struct.type<@B::@B<[1]>>
// CHECK-NEXT:        struct.member @b1$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@D::@D<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.new : <@D::@D<[]>>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_91]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute() : () -> !struct.type<@B::@B<[0]>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_94]] }  : <[@count: index, @comp: !struct.type<@B::@B<[0]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_96]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute() : () -> !struct.type<@B::@B<[1]>>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_99]] }  : <[@count: index, @comp: !struct.type<@B::@B<[1]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[0]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@B::@B<[0]>>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_101]][@out] : <@B::@B<[0]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_88]]{{\[}}%[[VAL_104]]] = %[[VAL_102]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[1]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@B::@B<[1]>>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@out] : <@B::@B<[1]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_88]]{{\[}}%[[VAL_108]]] = %[[VAL_106]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[0]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@B::@B<[0]>>
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_109]][@branch] : <@B::@B<[0]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_87]]{{\[}}%[[VAL_112]]] = %[[VAL_110]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[1]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@B::@B<[1]>>
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@branch] : <@B::@B<[1]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_87]]{{\[}}%[[VAL_116]]] = %[[VAL_114]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_86]][@b0$inputs] = %[[VAL_89]] : <@D::@D<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[0]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@B::@B<[0]>>
// CHECK-NEXT:          struct.writem %[[VAL_86]][@b0] = %[[VAL_117]] : <@D::@D<[]>>, !struct.type<@B::@B<[0]>>
// CHECK-NEXT:          struct.writem %[[VAL_86]][@b1$inputs] = %[[VAL_90]] : <@D::@D<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[1]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@B::@B<[1]>>
// CHECK-NEXT:          struct.writem %[[VAL_86]][@b1] = %[[VAL_118]] : <@D::@D<[]>>, !struct.type<@B::@B<[1]>>
// CHECK-NEXT:          struct.writem %[[VAL_86]][@outs] = %[[VAL_88]] : <@D::@D<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_86]][@branches] = %[[VAL_87]] : <@D::@D<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_86]] : !struct.type<@D::@D<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_119:[0-9a-zA-Z_\.]+]]: !struct.type<@D::@D<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@outs] : <@D::@D<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@branches] : <@D::@D<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@b0] : <@D::@D<[]>>, !struct.type<@B::@B<[0]>>
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@b0$inputs] : <@D::@D<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@b1] : <@D::@D<[]>>, !struct.type<@B::@B<[1]>>
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@b1$inputs] : <@D::@D<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_126]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[0]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_129]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[1]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_122]][@out] : <@B::@B<[0]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_134]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_135]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_124]][@out] : <@B::@B<[1]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_137]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_138]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_139]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_122]][@branch] : <@B::@B<[0]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_142]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_143]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_124]][@branch] : <@B::@B<[1]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_146]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_147]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_122]]) : (!struct.type<@B::@B<[0]>>) -> ()
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_124]]) : (!struct.type<@B::@B<[1]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
