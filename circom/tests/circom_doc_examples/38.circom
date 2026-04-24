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
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Multiplier2::@Multiplier2<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
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
// CHECK-NEXT:        function.def @compute(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {llzk.pub}) -> !struct.type<@MultiplierN::@MultiplierN<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.new : <@MultiplierN::@MultiplierN<[@N]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_19]] to %[[VAL_18]] step %[[VAL_20]] {
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_21]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            pod.write %[[VAL_22]][@count] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_21]]] = %[[VAL_22]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_25]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_27]], %[[VAL_29]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_30]]) %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_32]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_34]]] = %[[VAL_33]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_38]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_41]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_42]][@in1] = %[[VAL_39]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_24]]{{\[}}%[[VAL_44]]] = %[[VAL_42]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_46]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_48]], %[[VAL_49]] : index
// CHECK-NEXT:          pod.write %[[VAL_47]][@count] = %[[VAL_50]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_50]], %[[VAL_51]] : index
// CHECK-NEXT:          scf.if %[[VAL_52]] {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_53]], %[[VAL_54]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_47]][@comp] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_57]]] = %[[VAL_47]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_59]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_62]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_63]][@in2] = %[[VAL_60]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_24]]{{\[}}%[[VAL_65]]] = %[[VAL_63]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_67]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_69]], %[[VAL_70]] : index
// CHECK-NEXT:          pod.write %[[VAL_68]][@count] = %[[VAL_71]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_71]], %[[VAL_72]] : index
// CHECK-NEXT:          scf.if %[[VAL_73]] {
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_74]], %[[VAL_75]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_68]][@comp] = %[[VAL_76]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_78]]] = %[[VAL_68]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_24]], %[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_79]]) : (!array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_84]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_85]]) %[[VAL_81]], %[[VAL_82]] : !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_88]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_90]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_94]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_95]][@in1] = %[[VAL_91]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_86]]{{\[}}%[[VAL_98]]] = %[[VAL_95]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_101]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_103]], %[[VAL_104]] : index
// CHECK-NEXT:            pod.write %[[VAL_102]][@count] = %[[VAL_105]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_105]], %[[VAL_106]] : index
// CHECK-NEXT:            scf.if %[[VAL_107]] {
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_108]], %[[VAL_109]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              pod.write %[[VAL_102]][@comp] = %[[VAL_110]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_16]]{{\[}}%[[VAL_113]]] = %[[VAL_102]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_116]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_120]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_121]][@in2] = %[[VAL_117]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_86]]{{\[}}%[[VAL_124]]] = %[[VAL_121]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_127]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_129]], %[[VAL_130]] : index
// CHECK-NEXT:            pod.write %[[VAL_128]][@count] = %[[VAL_131]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_131]], %[[VAL_132]] : index
// CHECK-NEXT:            scf.if %[[VAL_133]] {
// CHECK-NEXT:              %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_134]], %[[VAL_135]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              pod.write %[[VAL_128]][@comp] = %[[VAL_136]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_16]]{{\[}}%[[VAL_139]]] = %[[VAL_128]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_86]], %[[VAL_141]] : !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_143]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_144]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_146]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@out] = %[[VAL_147]] : <@MultiplierN::@MultiplierN<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@comp$inputs] = %[[VAL_80]]#0 : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_153:[0-9a-zA-Z_\.]+]] = %[[VAL_151]] to %[[VAL_150]] step %[[VAL_152]] {
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_153]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            array.write %[[VAL_148]]{{\[}}%[[VAL_153]]] = %[[VAL_155]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_13]][@comp] = %[[VAL_148]] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@MultiplierN::@MultiplierN<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_156:[0-9a-zA-Z_\.]+]]: !struct.type<@MultiplierN::@MultiplierN<[@N]>>, %[[VAL_157:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_156]][@out] : <@MultiplierN::@MultiplierN<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_156]][@comp] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_156]][@comp$inputs] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_165:[0-9a-zA-Z_\.]+]] = %[[VAL_163]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_158]], %[[VAL_166]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_165]], %[[VAL_167]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_168]]) %[[VAL_165]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_169:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_170]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_169]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_173]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_174]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_157]]{{\[}}%[[VAL_175]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_177]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_162]]{{\[}}%[[VAL_178]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_180]], %[[VAL_176]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_157]]{{\[}}%[[VAL_182]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_184]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_162]]{{\[}}%[[VAL_185]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_187]], %[[VAL_183]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_190:[0-9a-zA-Z_\.]+]] = %[[VAL_188]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_158]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_190]], %[[VAL_192]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_193]]) %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_194:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_195]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_196]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_194]], %[[VAL_198]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_162]]{{\[}}%[[VAL_200]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_201]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_202]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_194]], %[[VAL_203]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_157]]{{\[}}%[[VAL_205]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_194]], %[[VAL_207]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_208]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_162]]{{\[}}%[[VAL_209]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_211]], %[[VAL_206]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_194]], %[[VAL_212]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_213]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_158]], %[[VAL_214]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_215]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_216]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_217]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_160]], %[[VAL_218]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_219]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_223:[0-9a-zA-Z_\.]+]] = %[[VAL_221]] to %[[VAL_220]] step %[[VAL_222]] {
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_223]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_162]]{{\[}}%[[VAL_223]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Multiplier2::@Multiplier2::@constrain(%[[VAL_224]], %[[VAL_226]], %[[VAL_227]]) : (!struct.type<@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
