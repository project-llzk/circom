// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template UCO() {
	for(var i = 0; i < 100; i++) {
		1 === 0;
	}
}

component main = UCO();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@UCO<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @UCO<[]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@UCO<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@UCO<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_1]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  100
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_5]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_3]]) %[[VAL_5]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_6]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_8]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@UCO<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_9:[0-9a-zA-Z_\.]+]]: !struct.type<@UCO<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  100
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_11]])
// CHECK-NEXT:          scf.condition(%[[VAL_12]]) %[[VAL_14]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          constrain.eq %[[VAL_16]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_19]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
