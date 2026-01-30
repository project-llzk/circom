// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @A<[@n]> {
// CHECK-DAG:       struct.field @aux : !felt.type
// CHECK-DAG:       struct.field @out : !felt.type
// CHECK-DAG:       struct.field @[[B:[0-9a-zA-Z_\.]+]] : !struct.type<@B<[]>>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = undef.undef : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = undef.undef : !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_4]])
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_5]] -> (!struct.type<@B<[]>>, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[VAL_7]]) : (!felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:          struct.writef %[[VAL_0]][@aux] = %[[VAL_7]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_8]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:          struct.writef %[[VAL_0]][@out] = %[[VAL_9]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_8]], %[[VAL_7]], %[[VAL_9]] : !struct.type<@B<[]>>, !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          struct.writef %[[VAL_0]][@out] = %[[VAL_10]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_3]], %[[VAL_2]], %[[VAL_10]] : !struct.type<@B<[]>>, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_0]][@[[B]]] = %[[VAL_6]]#0 : <@A<[@n]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_11]][@aux] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_11]][@out] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_11]][@[[B]]] : <@A<[@n]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_12]], %[[VAL_15]])
// CHECK-NEXT:        scf.if %[[VAL_16]] {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          constrain.eq %[[VAL_19]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:          function.call @B::@constrain(%[[VAL_14]], %[[VAL_19]]) : (!struct.type<@B<[]>>, !felt.type) -> ()
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_14]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_21]], %[[VAL_20]] : !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          constrain.eq %[[VAL_21]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-LABEL:   struct.def @B<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_25]][@out] = %[[VAL_27]] : <@B<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_25]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[VAL_29:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_28]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_29]], %[[VAL_30]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_32]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
