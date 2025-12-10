// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// This test demonstrates that variables defined outside a block can be overwritten
// inside blocks because no "error[T3001]: False assert reached" is raised but if any
// of the asserts are changed, the error will be raised.
template B() {
  var x = 5;
  {
    assert(x == 5);
    x = 10; // overwrites value of x
    assert(x == 10);
  }
  assert(x == 10);
}

component main = B();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @B<[]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@B<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_2]])
// CHECK-NEXT:        bool.assert %[[VAL_3]], "assertion failed"
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_4]], %[[VAL_5]])
// CHECK-NEXT:        bool.assert %[[VAL_6]], "assertion failed"
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_4]], %[[VAL_7]])
// CHECK-NEXT:        bool.assert %[[VAL_8]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_9:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_10]], %[[VAL_11]])
// CHECK-NEXT:        bool.assert %[[VAL_12]], "assertion failed"
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_13]], %[[VAL_14]])
// CHECK-NEXT:        bool.assert %[[VAL_15]], "assertion failed"
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_13]], %[[VAL_16]])
// CHECK-NEXT:        bool.assert %[[VAL_17]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
