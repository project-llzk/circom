// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function Fn(a, b) {
  return a * b;
}

template Foo() {
  signal input inp[2];
  signal output outp[1];

  outp[0] <-- Fn(inp[0], inp[1]);
  outp[0] === Fn(inp[0], inp[1]);
}

component main = Foo();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Foo<[]>>} {
// CHECK-NEXT:    function.def @Fn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:      function.return %[[VAL_2]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Foo<[]> {
// CHECK-NEXT:      struct.member @outp : !array.type<1 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) -> !struct.type<@Foo<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo<[]>>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]]
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_7]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_10]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @Fn(%[[VAL_8]], %[[VAL_11]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:        array.write %[[VAL_5]]{{\[}}%[[VAL_14]]] = %[[VAL_12]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_4]][@outp] = %[[VAL_5]] : <@Foo<[]>>, !array.type<1 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_4]] : !struct.type<@Foo<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo<[]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@outp] : <@Foo<[]>>, !array.type<1 x !felt.type>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]]
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_19]]] : <1 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_22]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]]
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_25]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = function.call @Fn(%[[VAL_23]], %[[VAL_26]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_20]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
