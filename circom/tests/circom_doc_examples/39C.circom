// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.5;

template B() {
  signal input in;
  signal output out;
  out <== in + 1;
}

template A(n) {
  signal out;
  if(n == 2) {
    // this demonstrates declaration of signal within a scope other than the initial one
    signal aux <== 2;
    out <== B()(aux);
  } else {
    out <== 5;
  }
}

component main = A(3);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A::@A<[3]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @aux : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @B_18_478 : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        struct.member @B_18_478$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_7]] -> (!pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[@in: !felt.type<"bn128">]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_0]][@aux] = %[[VAL_9]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_11]], @params = %[[VAL_10]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            pod.write %[[VAL_5]][@in] = %[[VAL_9]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_13]], %[[VAL_14]] : index
// CHECK-NEXT:            pod.write %[[VAL_12]][@count] = %[[VAL_15]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_15]], %[[VAL_16]] : index
// CHECK-NEXT:            scf.if %[[VAL_17]] {
// CHECK-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_19]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:              pod.write %[[VAL_12]][@comp] = %[[VAL_20]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_0]][@out] = %[[VAL_22]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_12]], %[[VAL_5]], %[[VAL_22]] : !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_0]][@out] = %[[VAL_23]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_4]], %[[VAL_5]], %[[VAL_23]] : !pod.type<[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !pod.type<[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@B_18_478$inputs] = %[[VAL_8]]#1 : <@A::@A<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]]#0[@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@B_18_478] = %[[VAL_24]] : <@A::@A<[@n]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@out] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@aux] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@B_18_478] : <@A::@A<[@n]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@B_18_478$inputs] : <@A::@A<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_26]], %[[VAL_31]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_32]] {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_33]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_37]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_27]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_27]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_29]], %[[VAL_40]]) : (!struct.type<@B::@B<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_42]][@out] = %[[VAL_44]] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_42]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@out] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
