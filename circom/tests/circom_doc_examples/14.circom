// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template right(N1,N2){
    signal input in;
    var x = 2;
    var t = 5;
    if(N1 > N2){
      t = 2;
    }
    x === t;
}

component main = right(10, 5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@right<[10, 5]>>} {
// CHECK-NEXT:    struct.def @right<[@N1, @N2]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@right<[@N1, @N2]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@right<[@N1, @N2]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N1 : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N2 : !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_2]], %[[VAL_3]])
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_6]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          scf.yield %[[VAL_8]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_5]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@right<[@N1, @N2]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !struct.type<@right<[@N1, @N2]>>, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @N1 : !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.read_const @N2 : !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_11]], %[[VAL_12]])
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_15]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          scf.yield %[[VAL_17]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_14]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_13]], %[[VAL_16]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
