// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template A(n){
   signal input a, b, c;
   signal output d;
   d <== a*b+c;
   a * b === c;
}
template B(n){
   signal input in[n];
   _ <== A(n)(in[0],in[1],in[2]);
}
component main = B(3);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@B::@B<[3]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @d : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_5]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@d] = %[[VAL_6]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_7]][@d] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_12]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_15]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @A_15_375 : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        struct.member @A_15_375$inputs : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@B::@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_23]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_21]][@a] = %[[VAL_24]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_25]], %[[VAL_26]] : index
// CHECK-NEXT:          pod.write %[[VAL_20]][@count] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:          scf.if %[[VAL_29]] {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@c] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_30]], %[[VAL_31]], %[[VAL_32]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_20]][@comp] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_35]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_21]][@b] = %[[VAL_36]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:          pod.write %[[VAL_20]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:          scf.if %[[VAL_41]] {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@c] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_42]], %[[VAL_43]], %[[VAL_44]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_20]][@comp] = %[[VAL_45]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_47]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_21]][@c] = %[[VAL_48]] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_49]], %[[VAL_50]] : index
// CHECK-NEXT:          pod.write %[[VAL_20]][@count] = %[[VAL_51]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_51]], %[[VAL_52]] : index
// CHECK-NEXT:          scf.if %[[VAL_53]] {
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@c] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_54]], %[[VAL_55]], %[[VAL_56]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_20]][@comp] = %[[VAL_57]] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@d] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_17]][@A_15_375$inputs] = %[[VAL_21]] : <@B::@B<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_17]][@A_15_375] = %[[VAL_60]] : <@B::@B<[@n]>>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_17]] : !struct.type<@B::@B<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n]>>, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@A_15_375] : <@B::@B<[@n]>>, !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@A_15_375$inputs] : <@B::@B<[@n]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_67]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_69]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_71]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_73]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_75]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@c] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_77]], %[[VAL_76]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@d] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@a] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@b] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@c] : <[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">, @c: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @A::@A::@constrain(%[[VAL_64]], %[[VAL_79]], %[[VAL_80]], %[[VAL_81]]) : (!struct.type<@A::@A<[@n]>>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
