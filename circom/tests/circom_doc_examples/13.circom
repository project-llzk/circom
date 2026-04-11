// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template right(N){
    signal input in;
    var x = 2;
    var t = 5;
    if(in > N){
      t = 2;
    }
}

component main = right(10);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@right<[10]>>} {
// CHECK-NEXT:    poly.template @right {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @right {
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@right::@right<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@right::@right<[@N]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_0]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_5]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            scf.yield %[[VAL_7]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_4]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@right::@right<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@right::@right<[@N]>>, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_9]], %[[VAL_10]]) : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_13]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            scf.yield %[[VAL_15]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_12]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
