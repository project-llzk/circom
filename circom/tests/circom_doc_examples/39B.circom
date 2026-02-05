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
// CHECK-NEXT:      struct.field @[[B:[0-9a-zA-Z_\.]+]] : !struct.type<@B<[]>>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = undef.undef : !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_3]])
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_4]] -> (!struct.type<@B<[]>>, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[VAL_6]]) : (!felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:          struct.writef %[[VAL_0]][@aux] = %[[VAL_6]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_7]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:          struct.writef %[[VAL_0]][@out] = %[[VAL_8]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_7]], %[[VAL_6]], %[[VAL_8]] : !struct.type<@B<[]>>, !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          struct.writef %[[VAL_0]][@aux] = %[[VAL_9]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          struct.writef %[[VAL_0]][@out] = %[[VAL_10]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_2]], %[[VAL_9]], %[[VAL_10]] : !struct.type<@B<[]>>, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_0]][@[[B]]] = %[[VAL_5]]#0 : <@A<[@n]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_11]][@aux] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_11]][@out] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_11]][@[[B]]] : <@A<[@n]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_12]], %[[VAL_14]])
// CHECK-NEXT:        scf.if %[[VAL_15]] {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          constrain.eq %[[VAL_18]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:          function.call @B::@constrain(%[[VAL_13]], %[[VAL_18]]) : (!struct.type<@B<[]>>, !felt.type) -> ()
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_13]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          constrain.eq %[[VAL_18]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_26]][@out] = %[[VAL_28]] : <@B<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_26]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_29]][@out] : <@B<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_33]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
