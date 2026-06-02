// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Multiplier2(){
   //Declaration of signals.
   signal input in1;
   signal input in2;
   signal output out;

   //Statements.
   out <== in1 * in2;
}

template Multiplier3() {
   //Declaration of signals.
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

template MultiplierN(N){
   //Declaration of signals.
   signal input in[N];
   signal output out;
   component comp[N-1];

   //Statements.
   for(var i = 0; i < N-1; i++){
       comp[i] = Multiplier2();
   }
   comp[0].in1 <== in[0];
   comp[0].in2 <== in[1];
   for(var i = 0; i < N-2; i++){
       comp[i+1].in1 <== comp[i].out;
       comp[i+1].in2 <== in[i+2];

   }
   out <== comp[N-2].out;
}

component main {public [in]} = MultiplierN(3);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@MultiplierN::@MultiplierN<[3]>>} {
// CHECK-NEXT:    poly.template @Multiplier2 {
// CHECK-NEXT:      struct.def @Multiplier2 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
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
// CHECK-NEXT:    poly.template @MultiplierN {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.expr @"N_Sub_1@859" {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_10]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @MultiplierN {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @comp : !array.type<@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:        struct.member @comp$inputs : !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "in", llzk.pub}) -> !struct.type<@MultiplierN::@MultiplierN<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.new : <@MultiplierN::@MultiplierN<[@N]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]] to %[[VAL_19]] step %[[VAL_21]] {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_17]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_22]]] = %[[VAL_24]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_26]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_28]], %[[VAL_30]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_31]]) %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_34]], @params = %[[VAL_33]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_36]]] = %[[VAL_35]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_32]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_40]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_43]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_44]][@in1] = %[[VAL_41]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_25]]{{\[}}%[[VAL_46]]] = %[[VAL_44]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_48]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_51]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// CHECK-NEXT:          pod.write %[[VAL_49]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:          scf.if %[[VAL_57]] {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_59]], %[[VAL_60]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_49]][@comp] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_63]]] = %[[VAL_49]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_65]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_68]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_69]][@in2] = %[[VAL_66]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_25]]{{\[}}%[[VAL_71]]] = %[[VAL_69]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_73]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_76]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_78]], %[[VAL_79]] : index
// CHECK-NEXT:          pod.write %[[VAL_74]][@count] = %[[VAL_80]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_80]], %[[VAL_81]] : index
// CHECK-NEXT:          scf.if %[[VAL_82]] {
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_84]], %[[VAL_85]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_74]][@comp] = %[[VAL_86]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_88]]] = %[[VAL_74]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_91:[0-9a-zA-Z_\.]+]] = %[[VAL_25]], %[[VAL_92:[0-9a-zA-Z_\.]+]] = %[[VAL_89]]) : (!array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_92]], %[[VAL_94]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_95]]) %[[VAL_91]], %[[VAL_92]] : !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_96:[0-9a-zA-Z_\.]+]]: !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, %[[VAL_97:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_98]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_100]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_104]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_105]][@in1] = %[[VAL_101]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_96]]{{\[}}%[[VAL_108]]] = %[[VAL_105]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_109]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_111]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_115]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_117]], %[[VAL_118]] : index
// CHECK-NEXT:            pod.write %[[VAL_112]][@count] = %[[VAL_119]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_119]], %[[VAL_120]] : index
// CHECK-NEXT:            scf.if %[[VAL_121]] {
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_123]], %[[VAL_124]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              pod.write %[[VAL_112]][@comp] = %[[VAL_125]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_16]]{{\[}}%[[VAL_128]]] = %[[VAL_112]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_130]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_131]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_134]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_135]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_136]][@in2] = %[[VAL_132]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_96]]{{\[}}%[[VAL_139]]] = %[[VAL_136]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_142]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_146]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_148]], %[[VAL_149]] : index
// CHECK-NEXT:            pod.write %[[VAL_143]][@count] = %[[VAL_150]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_150]], %[[VAL_151]] : index
// CHECK-NEXT:            scf.if %[[VAL_152]] {
// CHECK-NEXT:              %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_147]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_147]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_154]], %[[VAL_155]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              pod.write %[[VAL_143]][@comp] = %[[VAL_156]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_157]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_16]]{{\[}}%[[VAL_159]]] = %[[VAL_143]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_96]], %[[VAL_161]] : !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_164]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_166]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@out] = %[[VAL_167]] : <@MultiplierN::@MultiplierN<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@comp$inputs] = %[[VAL_90]]#0 : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_173:[0-9a-zA-Z_\.]+]] = %[[VAL_171]] to %[[VAL_170]] step %[[VAL_172]] {
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_173]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            array.write %[[VAL_168]]{{\[}}%[[VAL_173]]] = %[[VAL_175]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_13]][@comp] = %[[VAL_168]] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@MultiplierN::@MultiplierN<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_176:[0-9a-zA-Z_\.]+]]: !struct.type<@MultiplierN::@MultiplierN<[@N]>>, %[[VAL_177:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "in", llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@out] : <@MultiplierN::@MultiplierN<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@comp] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@comp$inputs] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_185:[0-9a-zA-Z_\.]+]] = %[[VAL_183]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_178]], %[[VAL_186]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_185]], %[[VAL_187]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_188]]) %[[VAL_185]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_189:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_189]], %[[VAL_192]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_193]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_195]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_197]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_198]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_199]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_200]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_201]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_202]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_205]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_207]], %[[VAL_203]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_210:[0-9a-zA-Z_\.]+]] = %[[VAL_208]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_178]], %[[VAL_211]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_210]], %[[VAL_212]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_213]]) %[[VAL_210]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_214:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_181]]{{\[}}%[[VAL_215]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_216]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_214]], %[[VAL_218]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_219]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_220]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_222]], %[[VAL_217]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_214]], %[[VAL_223]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_224]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_225]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_214]], %[[VAL_227]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_229:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_228]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_230:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_229]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_230]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_231]], %[[VAL_226]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_214]], %[[VAL_232]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_233]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_178]], %[[VAL_234]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_181]]{{\[}}%[[VAL_236]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_180]], %[[VAL_238]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_239]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_243:[0-9a-zA-Z_\.]+]] = %[[VAL_241]] to %[[VAL_240]] step %[[VAL_242]] {
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_181]]{{\[}}%[[VAL_243]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_243]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Multiplier2::@Multiplier2::@constrain(%[[VAL_244]], %[[VAL_246]], %[[VAL_247]]) : (!struct.type<@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
