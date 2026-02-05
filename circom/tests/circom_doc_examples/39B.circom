// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
    aux <== 0;
    _ <== aux;
    out <== 5;
  }
}

component main = A(3);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[3]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      struct.field @aux : !felt.type
// CHECK-NEXT:      struct.field @out : !felt.type
// CHECK-NEXT:      struct.field @[[ANON:[0-9a-zA-Z_\.]+]] : !struct.type<@B<[]>>
// CHECK-NEXT:      struct.field @[[ANON]]$inputs : !pod.type<[@in: !felt.type]>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type]>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_5]])
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_6]] -> (!pod.type<[@in: !felt.type]>, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          struct.writef %[[VAL_0]][@aux] = %[[VAL_8]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_8]] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@count] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_9]], %[[VAL_10]] : index
// CHECK-NEXT:          pod.write %[[VAL_3]][@count] = %[[VAL_11]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_11]], %[[VAL_12]] : index
// CHECK-NEXT:          scf.if %[[VAL_13]] {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[VAL_14]]) : (!felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:            pod.write %[[VAL_3]][@comp] = %[[VAL_15]] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_16]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:          struct.writef %[[VAL_0]][@out] = %[[VAL_17]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_4]], %[[VAL_8]], %[[VAL_17]] : !pod.type<[@in: !felt.type]>, !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          struct.writef %[[VAL_0]][@aux] = %[[VAL_18]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          struct.writef %[[VAL_0]][@out] = %[[VAL_19]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_4]], %[[VAL_18]], %[[VAL_19]] : !pod.type<[@in: !felt.type]>, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_0]][@[[ANON]]$inputs] = %[[VAL_7]]#0 : <@A<[@n]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@comp] : <[@count: index, @comp: !struct.type<@B<[]>>, @params: !pod.type<[]>]>, !struct.type<@B<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_0]][@[[ANON]]] = %[[VAL_20]] : <@A<[@n]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_21]][@aux] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_21]][@out] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_21]][@[[ANON]]] : <@A<[@n]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_21]][@[[ANON]]$inputs] : <@A<[@n]>>, !pod.type<[@in: !felt.type]>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_22]], %[[VAL_27]])
// CHECK-NEXT:        scf.if %[[VAL_28]] {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          constrain.eq %[[VAL_23]], %[[VAL_29]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_30]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_25]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          constrain.eq %[[VAL_23]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_33]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @B::@constrain(%[[VAL_25]], %[[VAL_34]]) : (!struct.type<@B<[]>>, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_37]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_36]][@out] = %[[VAL_38]] : <@B<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_36]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_39:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_39]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_41]], %[[VAL_43]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
