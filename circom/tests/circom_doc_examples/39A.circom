// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
  signal input in;
  signal output out;
  out <== in + 1;
}

template A(n) {
  signal aux;
  signal out;
  if(n == 2) {
    aux <== 2;
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
// CHECK-NEXT:        struct.member @aux : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128">
// CHECK-NEXT:        struct.member @[[ANON:[0-9a-zA-Z_\.]+]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        struct.member @[[ANON]]$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_7]] -> (!pod.type<[@in: !felt.type<"bn128">]>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            struct.writem %[[VAL_0]][@aux] = %[[VAL_9]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_5]][@in] = %[[VAL_9]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_10]], %[[VAL_11]] : index
// CHECK-NEXT:            pod.write %[[VAL_4]][@count] = %[[VAL_12]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_12]], %[[VAL_13]] : index
// CHECK-NEXT:            scf.if %[[VAL_14]] {
// CHECK-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_15]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[]>>
// CHECK-NEXT:              pod.write %[[VAL_4]][@comp] = %[[VAL_16]] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            struct.writem %[[VAL_0]][@out] = %[[VAL_18]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_5]], %[[VAL_9]], %[[VAL_18]] : !pod.type<[@in: !felt.type<"bn128">]>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:            struct.writem %[[VAL_0]][@out] = %[[VAL_19]] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_5]], %[[VAL_2]], %[[VAL_19]] : !pod.type<[@in: !felt.type<"bn128">]>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@[[ANON]]$inputs] = %[[VAL_8]]#0 : <@A::@A<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@[[ANON]]] = %[[VAL_20]] : <@A::@A<[@n]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@aux] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@out] : <@A::@A<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@[[ANON]]] : <@A::@A<[@n]>>, !struct.type<@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@[[ANON]]$inputs] : <@A::@A<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_22]], %[[VAL_27]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_28]] {
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            constrain.eq %[[VAL_23]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_30]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@out] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_24]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:            constrain.eq %[[VAL_24]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_25]], %[[VAL_33]]) : (!struct.type<@B::@B<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@B::@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_35]][@out] = %[[VAL_37]] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_35]] : !struct.type<@B::@B<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[]>>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@out] : <@B::@B<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_40]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
