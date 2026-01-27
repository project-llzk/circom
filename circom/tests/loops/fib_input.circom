// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Fibonacci() {
    signal input nth_fib;
    signal output out;

    var a = 0;
    var b = 1;
    var next = 0;

    var counter = nth_fib;
    while (counter > 2) { // unknown iteration count
        next = a + b;
        a = b;
        b = next;

        counter--;
    }

    out <-- (nth_fib == 0) ? 0 : (nth_fib == 1 ? 1 : a + b);
}

component main = Fibonacci();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Fibonacci<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Fibonacci<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Fibonacci<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_0]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type, !felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_8]], %[[VAL_10]])
// CHECK-NEXT:          scf.condition(%[[VAL_11]]) %[[VAL_6]], %[[VAL_7]], %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_14]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_13]], %[[VAL_16]], %[[VAL_18]], %[[VAL_16]] : !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_19]])
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_20]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[VAL_22]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_23]])
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_24]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            scf.yield %[[VAL_26]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_5]]#0, %[[VAL_5]]#1 : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_27]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_25]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_21]] : <@Fibonacci<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Fibonacci<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@Fibonacci<[]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_31]], %[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_32]], %[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_30]], %[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!felt.type, !felt.type, !felt.type, !felt.type) -> (!felt.type, !felt.type, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_37]], %[[VAL_39]])
// CHECK-NEXT:          scf.condition(%[[VAL_40]]) %[[VAL_35]], %[[VAL_36]], %[[VAL_37]], %[[VAL_38]] : !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_43]], %[[VAL_46]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_42]], %[[VAL_45]], %[[VAL_47]], %[[VAL_45]] : !felt.type, !felt.type, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_29]][@out] : <@Fibonacci<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
