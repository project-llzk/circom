// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(i) {
    if (i < 10) {
        return i + 2;
    } else {
        return i + 3;
    }
}

template T() {
    signal input inp;
    signal output outp;

    // error[T3001]: Non quadratic constraints are not allowed!
    // This error does not occur when producing LLZK IR because it is only detected
    // during the execution phase, which occurs after emitting LLZK IR.
    outp <== f(inp);
}

component main = T();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@T<[]>>} {
// CHECK-NEXT:    function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_0]], %[[VAL_1]]) : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!felt.type) {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_5]] : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_7]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_3]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @T {
// CHECK-NEXT:      struct.def @T {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@T::@T<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@T::@T<[]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_8]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_9]][@outp] = %[[VAL_10]] : <@T::@T<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@T::@T<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !struct.type<@T::@T<[]>>, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_11]][@outp] : <@T::@T<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_12]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_13]], %[[VAL_14]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
