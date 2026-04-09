// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function InlineSwitch(cond, a, b) {
    return cond ? a : b;
}

template CallInlineSwitch() {
    signal input in;
    signal output out <-- InlineSwitch(in != 0, 1 / in, 0);
}

component main = CallInlineSwitch();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@CallInlineSwitch<[]>>} {
// CHECK-LABEL:   function.def @InlineSwitch
// CHECK-SAME:    (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_99:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_0]], %[[VAL_3]])
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_99]] -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[VAL_1]] : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        scf.yield %[[VAL_2]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_4]] : !felt.type
// CHECK-NEXT:    }
// CHECK-LABEL:   struct.def @CallInlineSwitch<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@CallInlineSwitch<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.new : <@CallInlineSwitch<[]>>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_5]], %[[VAL_7]])
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_8]] : i1
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_10]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = function.call @InlineSwitch(%[[VAL_9]], %[[VAL_11]], %[[VAL_12]]) : (!felt.type, !felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_6]][@out] = %[[VAL_13]] : <@CallInlineSwitch<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_6]] : !struct.type<@CallInlineSwitch<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@CallInlineSwitch<[]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@out] : <@CallInlineSwitch<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
