// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(a) {
  return a;
  // Circom allows code after a return and includes it in the parsed AST but it doesn't
  // process it further or this statement would cause "error[T3001]: False assert reached."
  // Thus, any code after the first return in a block should be ignored when generating LLZK.
  assert(1 == 0);
  return a;
}

template Foo() {
  signal input inp;

  _ <-- f(inp);
}

component main = Foo();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Foo::@Foo<[]>>} {
// CHECK-NEXT:    function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Foo {
// CHECK-NEXT:      struct.def @Foo {
// CHECK-NEXT:        function.def @compute(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Foo::@Foo<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo::@Foo<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_1]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
