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
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_22]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_23]]) %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_26]], @params = %[[VAL_25]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_28]]] = %[[VAL_27]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_32]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_35]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_36]][@in1] = %[[VAL_33]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_17]]{{\[}}%[[VAL_38]]] = %[[VAL_36]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_40]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:          pod.write %[[VAL_41]][@count] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:          scf.if %[[VAL_46]] {
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_48]], %[[VAL_49]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_41]][@comp] = %[[VAL_50]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_52]]] = %[[VAL_41]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_54]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_57]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_58]][@in2] = %[[VAL_55]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_17]]{{\[}}%[[VAL_60]]] = %[[VAL_58]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_62]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_64]], %[[VAL_65]] : index
// CHECK-NEXT:          pod.write %[[VAL_63]][@count] = %[[VAL_66]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_66]], %[[VAL_67]] : index
// CHECK-NEXT:          scf.if %[[VAL_68]] {
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_70]], %[[VAL_71]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_63]][@comp] = %[[VAL_72]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_74]]] = %[[VAL_63]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_17]], %[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_75]]) : (!array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_78]], %[[VAL_80]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_81]]) %[[VAL_77]], %[[VAL_78]] : !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_82:[0-9a-zA-Z_\.]+]]: !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, %[[VAL_83:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_84]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_86]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_90]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_91]][@in1] = %[[VAL_87]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_82]]{{\[}}%[[VAL_94]]] = %[[VAL_91]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_97]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_99]], %[[VAL_100]] : index
// CHECK-NEXT:            pod.write %[[VAL_98]][@count] = %[[VAL_101]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_101]], %[[VAL_102]] : index
// CHECK-NEXT:            scf.if %[[VAL_103]] {
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_105]], %[[VAL_106]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              pod.write %[[VAL_98]][@comp] = %[[VAL_107]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_16]]{{\[}}%[[VAL_110]]] = %[[VAL_98]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_113]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_116]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_117]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_118]][@in2] = %[[VAL_114]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_119]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_82]]{{\[}}%[[VAL_121]]] = %[[VAL_118]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_124]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_126]], %[[VAL_127]] : index
// CHECK-NEXT:            pod.write %[[VAL_125]][@count] = %[[VAL_128]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_128]], %[[VAL_129]] : index
// CHECK-NEXT:            scf.if %[[VAL_130]] {
// CHECK-NEXT:              %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_134:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_132]], %[[VAL_133]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              pod.write %[[VAL_125]][@comp] = %[[VAL_134]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_136]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_16]]{{\[}}%[[VAL_137]]] = %[[VAL_125]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_82]], %[[VAL_139]] : !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_142]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_144]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@out] = %[[VAL_145]] : <@MultiplierN::@MultiplierN<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@comp$inputs] = %[[VAL_76]]#0 : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_147]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_151:[0-9a-zA-Z_\.]+]] = %[[VAL_149]] to %[[VAL_148]] step %[[VAL_150]] {
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_151]]] : <@"N_Sub_1@859" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_152]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            array.write %[[VAL_146]]{{\[}}%[[VAL_151]]] = %[[VAL_153]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_13]][@comp] = %[[VAL_146]] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@MultiplierN::@MultiplierN<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_154:[0-9a-zA-Z_\.]+]]: !struct.type<@MultiplierN::@MultiplierN<[@N]>>, %[[VAL_155:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_154]][@out] : <@MultiplierN::@MultiplierN<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_154]][@comp] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_154]][@comp$inputs] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_163:[0-9a-zA-Z_\.]+]] = %[[VAL_161]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_156]], %[[VAL_164]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_163]], %[[VAL_165]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_166]]) %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_167:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_169]], @params = %[[VAL_168]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_167]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_172]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_173]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_155]]{{\[}}%[[VAL_174]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_160]]{{\[}}%[[VAL_177]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_179]], %[[VAL_175]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_180]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_155]]{{\[}}%[[VAL_181]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_183]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_160]]{{\[}}%[[VAL_184]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_186]], %[[VAL_182]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_189:[0-9a-zA-Z_\.]+]] = %[[VAL_187]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_156]], %[[VAL_190]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_189]], %[[VAL_191]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_192]]) %[[VAL_189]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_193:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_193]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_194]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_195]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_198]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_160]]{{\[}}%[[VAL_199]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_201]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_202]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_203]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_155]]{{\[}}%[[VAL_204]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_206]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_207]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_160]]{{\[}}%[[VAL_208]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_210]], %[[VAL_205]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_211]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_212]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_156]], %[[VAL_213]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_215]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_216]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_158]], %[[VAL_217]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@859" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_222:[0-9a-zA-Z_\.]+]] = %[[VAL_220]] to %[[VAL_219]] step %[[VAL_221]] {
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_222]]] : <@"N_Sub_1@859" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_160]]{{\[}}%[[VAL_222]]] : <@"N_Sub_1@859" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_224]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_224]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Multiplier2::@Multiplier2::@constrain(%[[VAL_223]], %[[VAL_225]], %[[VAL_226]]) : (!struct.type<@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
