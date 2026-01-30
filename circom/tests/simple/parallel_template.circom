// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template parallel Foo() {}

template Parallel() {
    component foo = Foo();
}

component main = Parallel();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Parallel<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Foo<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Foo<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@Foo<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Parallel<[]> {
// CHECK-NEXT:      struct.field @foo : !struct.type<@Foo<[]>>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Parallel<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Parallel<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @Foo::@compute() : () -> !struct.type<@Foo<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_2]][@foo] = %[[VAL_3]] : <@Parallel<[]>>, !struct.type<@Foo<[]>>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@Parallel<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Parallel<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@foo] : <@Parallel<[]>>, !struct.type<@Foo<[]>>
// CHECK-NEXT:        function.call @Foo::@constrain(%[[VAL_5]]) : (!struct.type<@Foo<[]>>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
