// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// This test demonstrates that an inner block can both overwrite and shadow variables
// defined outside a block because no "error[T3001]: False assert reached" is raised
// but if any of the asserts are changed, the error will be raised.
template B() {
  var x = 5;
  {
    assert(x == 5);
    x = 15; // overwrites value of outer x
    assert(x == 15);
    var x = 10; // shadows outer x
    assert(x == 10);
  }
  assert(x == 15);
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
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_4]], %[[VAL_5]])
// CHECK-NEXT:        bool.assert %[[VAL_6]], "assertion failed"
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_7]], %[[VAL_8]])
// CHECK-NEXT:        bool.assert %[[VAL_9]], "assertion failed"
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_4]], %[[VAL_10]])
// CHECK-NEXT:        bool.assert %[[VAL_11]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_12:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_13]], %[[VAL_14]])
// CHECK-NEXT:        bool.assert %[[VAL_15]], "assertion failed"
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_16]], %[[VAL_17]])
// CHECK-NEXT:        bool.assert %[[VAL_18]], "assertion failed"
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_19]], %[[VAL_20]])
// CHECK-NEXT:        bool.assert %[[VAL_21]], "assertion failed"
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_16]], %[[VAL_22]])
// CHECK-NEXT:        bool.assert %[[VAL_23]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
