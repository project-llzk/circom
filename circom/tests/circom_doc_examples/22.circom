// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

template Ex(n, m){
   signal input in[n];
   signal output out[m];
   var i = 0;
   while(i < n) {
      out[i] <== in[i];
      i += 1;
   }
}

component main = Ex(3, 3);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Ex<[3, 3]>>} {
// CHECK-NEXT:    struct.def @Ex<[@n, @m]> {
// CHECK-NEXT:      struct.member @out : !array.type<@m x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Ex<[@n, @m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Ex<[@n, @m]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@m x !felt.type>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_12]]] = %[[VAL_11]] : <@m x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_14]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@Ex<[@n, @m]>>, !array.type<@m x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Ex<[@n, @m]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@Ex<[@n, @m]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@out] : <@Ex<[@n, @m]>>, !array.type<@m x !felt.type>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_21]], %[[VAL_17]])
// CHECK-NEXT:          scf.condition(%[[VAL_22]]) %[[VAL_21]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]]
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_24]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]]
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_27]]] : <@m x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_28]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_29]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_30]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
