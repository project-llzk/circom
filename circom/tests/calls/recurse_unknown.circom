// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function factorial(x) {
    if (x == 0 || x == 1) return 1;
    return x * factorial(x - 1);
}

template Caller() {
    signal input inp;
    signal output outp;
    // Cannot use `<==` here because it creates a non quadratic constraint
    // due to `||` in the function.
    outp <-- factorial(inp);
}

component main = Caller();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Caller::@Caller<[]>>} {
// CHECK-NEXT:    function.def @factorial(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !felt.type<"bn128"> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_4]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_3]], %[[VAL_5]] : i1, i1
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_6]] -> (i1, !felt.type<"bn128">) {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[VAL_9]], %[[VAL_8]] : i1, !felt.type<"bn128">
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:        scf.yield %[[VAL_10]], %[[VAL_1]] : i1, !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_7]]#0 -> (!felt.type<"bn128">) {
// CHECK-NEXT:        scf.yield %[[VAL_7]]#1 : !felt.type<"bn128">
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_0]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @factorial(%[[VAL_13]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Caller {
// CHECK-NEXT:      struct.def @Caller {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Caller::@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller::@Caller<[]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = function.call @factorial(%[[VAL_16]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_17]][@outp] = %[[VAL_18]] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_17]] : !struct.type<@Caller::@Caller<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller::@Caller<[]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@outp] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
