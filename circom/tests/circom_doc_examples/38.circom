// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@MultiplierN::@MultiplierN<[3]>>} {
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
// CHECK-NEXT:    poly.template @MultiplierN {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.expr @"N_Sub_1@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_10]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_11]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_13]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @MultiplierN {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @comp : !array.type<@"N_Sub_1@[[OFFSET0]]" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:        struct.member @comp$inputs : !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "in", llzk.pub}) -> !struct.type<@MultiplierN::@MultiplierN<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.new : <@MultiplierN::@MultiplierN<[@N]>>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_16]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_18]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_23]] to %[[VAL_22]] step %[[VAL_24]] {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_26]], @params = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_20]]{{\[}}%[[VAL_25]]] = %[[VAL_27]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_29]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_17]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_31]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_34]]) %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_37]], @params = %[[VAL_36]] }  : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_20]]{{\[}}%[[VAL_39]]] = %[[VAL_38]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_43]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_46]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_47]][@in1] = %[[VAL_44]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_28]]{{\[}}%[[VAL_49]]] = %[[VAL_47]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_51]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_54]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_56]], %[[VAL_57]] : index
// CHECK-NEXT:          pod.write %[[VAL_52]][@count] = %[[VAL_58]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_58]], %[[VAL_59]] : index
// CHECK-NEXT:          scf.if %[[VAL_60]] {
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_62]], %[[VAL_63]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_52]][@comp] = %[[VAL_64]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_20]]{{\[}}%[[VAL_66]]] = %[[VAL_52]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_68]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_71]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_72]][@in2] = %[[VAL_69]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_28]]{{\[}}%[[VAL_74]]] = %[[VAL_72]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_76]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_79]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_81]], %[[VAL_82]] : index
// CHECK-NEXT:          pod.write %[[VAL_77]][@count] = %[[VAL_83]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_83]], %[[VAL_84]] : index
// CHECK-NEXT:          scf.if %[[VAL_85]] {
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_87]], %[[VAL_88]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            pod.write %[[VAL_77]][@comp] = %[[VAL_89]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_20]]{{\[}}%[[VAL_91]]] = %[[VAL_77]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_20_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_94:[0-9a-zA-Z_\.]+]] = %[[VAL_28]], %[[VAL_95:[0-9a-zA-Z_\.]+]] = %[[VAL_92]]) : (!array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_17]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_95]], %[[VAL_97]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_98]]) %[[VAL_20_IN]], %[[VAL_94]], %[[VAL_95]] : !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_20_LCV:[0-9a-zA-Z_\.]+]]: !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, %[[VAL_99:[0-9a-zA-Z_\.]+]]: !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, %[[VAL_100:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20_LCV]]{{\[}}%[[VAL_101]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_107]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_108]][@in1] = %[[VAL_104]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_109]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_99]]{{\[}}%[[VAL_111]]] = %[[VAL_108]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20_LCV]]{{\[}}%[[VAL_114]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_118]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_120]], %[[VAL_121]] : index
// CHECK-NEXT:            pod.write %[[VAL_115]][@count] = %[[VAL_122]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_122]], %[[VAL_123]] : index
// CHECK-NEXT:            scf.if %[[VAL_124]] {
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_126]], %[[VAL_127]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              pod.write %[[VAL_115]][@comp] = %[[VAL_128]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_130]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_20_LCV]]{{\[}}%[[VAL_131]]] = %[[VAL_115]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_134]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_137]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_138]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_139]][@in2] = %[[VAL_135]] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_99]]{{\[}}%[[VAL_142]]] = %[[VAL_139]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_143]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_144]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20_LCV]]{{\[}}%[[VAL_145]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_149]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@count] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_151]], %[[VAL_152]] : index
// CHECK-NEXT:            pod.write %[[VAL_146]][@count] = %[[VAL_153]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_153]], %[[VAL_154]] : index
// CHECK-NEXT:            scf.if %[[VAL_155]] {
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@params] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_150]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_150]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = function.call @Multiplier2::@Multiplier2::@compute(%[[VAL_157]], %[[VAL_158]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:              pod.write %[[VAL_146]][@comp] = %[[VAL_159]] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_20_LCV]]{{\[}}%[[VAL_162]]] = %[[VAL_146]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_163]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_20_LCV]], %[[VAL_99]], %[[VAL_164]] : !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_17]], %[[VAL_165]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_166]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]#0{{\[}}%[[VAL_167]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_169]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_15]][@out] = %[[VAL_170]] : <@MultiplierN::@MultiplierN<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_15]][@comp$inputs] = %[[VAL_93]]#1 : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = array.new  : <@"N_Sub_1@[[OFFSET0]]" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_175:[0-9a-zA-Z_\.]+]] = %[[VAL_173]] to %[[VAL_172]] step %[[VAL_174]] {
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]#0{{\[}}%[[VAL_175]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@comp] : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            array.write %[[VAL_171]]{{\[}}%[[VAL_175]]] = %[[VAL_177]] : <@"N_Sub_1@[[OFFSET0]]" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_15]][@comp] = %[[VAL_171]] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@[[OFFSET0]]" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          function.return %[[VAL_15]] : !struct.type<@MultiplierN::@MultiplierN<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_178:[0-9a-zA-Z_\.]+]]: !struct.type<@MultiplierN::@MultiplierN<[@N]>>, %[[VAL_179:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "in", llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_180]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_182]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_178]][@out] : <@MultiplierN::@MultiplierN<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_178]][@comp] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@[[OFFSET0]]" x !struct.type<@Multiplier2::@Multiplier2<[]>>>
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_178]][@comp$inputs] : <@MultiplierN::@MultiplierN<[@N]>>, !array.type<@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_189:[0-9a-zA-Z_\.]+]] = %[[VAL_187]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_181]], %[[VAL_190]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_189]], %[[VAL_191]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_192]]) %[[VAL_189]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_193:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Multiplier2::@Multiplier2<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_197]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_198]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_199]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_201]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_186]]{{\[}}%[[VAL_202]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_203]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_204]], %[[VAL_200]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_205]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_206]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_208]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_186]]{{\[}}%[[VAL_209]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_211]], %[[VAL_207]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_214:[0-9a-zA-Z_\.]+]] = %[[VAL_212]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_181]], %[[VAL_215]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_214]], %[[VAL_216]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_217]]) %[[VAL_214]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_218:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_185]]{{\[}}%[[VAL_219]]] : <@"N_Sub_1@[[OFFSET0]]" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_220]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_218]], %[[VAL_222]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_223]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_186]]{{\[}}%[[VAL_224]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_226]], %[[VAL_221]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_218]], %[[VAL_227]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_229:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_228]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_230:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_229]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_218]], %[[VAL_231]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_233:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_234:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_186]]{{\[}}%[[VAL_233]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_234]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_235]], %[[VAL_230]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_218]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_181]], %[[VAL_238]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_239]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_185]]{{\[}}%[[VAL_240]]] : <@"N_Sub_1@[[OFFSET0]]" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_241]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_184]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = poly.read_const @"N_Sub_1@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_246:[0-9a-zA-Z_\.]+]] = %[[VAL_244]] to %[[VAL_243]] step %[[VAL_245]] {
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_185]]{{\[}}%[[VAL_246]]] : <@"N_Sub_1@[[OFFSET0]]" x !struct.type<@Multiplier2::@Multiplier2<[]>>>, !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_186]]{{\[}}%[[VAL_246]]] : <@"N_Sub_1@[[OFFSET0]]" x !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>>, !pod.type<[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_248]][@in1] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_250:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_248]][@in2] : <[@in1: !felt.type<"bn128">, @in2: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Multiplier2::@Multiplier2::@constrain(%[[VAL_247]], %[[VAL_249]], %[[VAL_250]]) : (!struct.type<@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
