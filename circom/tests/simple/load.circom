// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
  signal input in[3];
  signal output out;
  var idx[3] = [ 2, 1, 0 ];

  var x = in[idx[n]];
  out <-- x;
}

component main = A(1);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[V_0:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type>) -> !struct.type<@A<[@n]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[SELF:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[V_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_4:[0-9a-zA-Z_\.]+]] = array.new %[[V_3]], %[[V_3]], %[[V_3]] : <3 x !felt.type>
// CHECK-NEXT:        %[[V_5:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[V_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_7:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_A:[0-9a-zA-Z_\.]+]] = array.new %[[V_5]], %[[V_6]], %[[V_7]] : <3 x !felt.type>
// CHECK-NEXT:        %[[V_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_N]]
// CHECK-NEXT:        %[[V_10:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_9]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_10]]
// CHECK-NEXT:        %[[V_12:[0-9a-zA-Z_\.]+]] = array.read %[[V_0]]{{\[}}%[[V_11]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writef %[[SELF]][@out] = %[[V_12]] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[SELF]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[SELF:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>, %[[V_14:[0-9a-zA-Z_\.]+]]: !array.type<3 x !felt.type>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[V_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_17:[0-9a-zA-Z_\.]+]] = array.new %[[V_16]], %[[V_16]], %[[V_16]] : <3 x !felt.type>
// CHECK-NEXT:        %[[V_18:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[V_19:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_A:[0-9a-zA-Z_\.]+]] = array.new %[[V_18]], %[[V_19]], %[[V_20]] : <3 x !felt.type>
// CHECK-NEXT:        %[[V_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_N]]
// CHECK-NEXT:        %[[V_23:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_22]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_23]]
// CHECK-NEXT:        %[[V_25:[0-9a-zA-Z_\.]+]] = array.read %[[V_14]]{{\[}}%[[V_24]]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[V_26:[0-9a-zA-Z_\.]+]] = struct.readf %[[SELF]][@out] : <@A<[@n]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
