// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
    var c = 1 \ -1;
    assert(c == 0); // 0 quotient means circom uses unsigned division
}

component main = A();

// COM: TODO: This output will change once 'uintdiv' op is available in LLZK.
//
// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_2]] : !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toint %[[VAL_1]] : i254
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = cast.toint %[[VAL_3]] : i254
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.divui %[[VAL_4]], %[[VAL_5]] : i254
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : i254
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_7]], %[[VAL_8]])
// CHECK-NEXT:        bool.assert %[[VAL_9]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_12]] : !felt.type
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toint %[[VAL_11]] : i254
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toint %[[VAL_13]] : i254
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.divui %[[VAL_14]], %[[VAL_15]] : i254
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_16]] : i254
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_17]], %[[VAL_18]])
// CHECK-NEXT:        bool.assert %[[VAL_19]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
