// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function complicated(n){
  var x = 0;
  var y = 0;
  var z = 0;
  if (n < 0) {
    x = 1;
    y = 2;
    z = 4;
  } else {
    return n;
  }
  return x + y + z;
}

template C() {
  signal input in;
  signal output out;
  out <-- complicated(in);
}

component main = C();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@C::@C<[]>>} {
// CHECK-NEXT:    function.def @complicated(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_0]], %[[VAL_5]]) : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]]:5 = scf.if %[[VAL_6]] -> (i1, !felt.type, !felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:        scf.yield %[[VAL_11]], %[[VAL_1]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]] : i1, !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[VAL_12]], %[[VAL_0]], %[[VAL_2]], %[[VAL_3]], %[[VAL_4]] : i1, !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_7]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[VAL_7]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_7]]#2, %[[VAL_7]]#3 : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_7]]#4 : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_15]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_13]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C {
// CHECK-NEXT:      struct.def @C {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@C::@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = function.call @complicated(%[[VAL_16]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_17]][@out] = %[[VAL_18]] : <@C::@C<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_17]] : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@out] : <@C::@C<[]>>, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
