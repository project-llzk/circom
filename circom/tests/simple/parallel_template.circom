// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:      struct.field @foo$inputs : !pod.type<[]>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Parallel<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Parallel<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:        struct.writef %[[VAL_2]][@foo$inputs] = %[[VAL_5]] : <@Parallel<[]>>, !pod.type<[]>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_2]][@foo] = %[[VAL_6]] : <@Parallel<[]>>, !struct.type<@Foo<[]>>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@Parallel<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@Parallel<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_7]][@foo] : <@Parallel<[]>>, !struct.type<@Foo<[]>>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_7]][@foo$inputs] : <@Parallel<[]>>, !pod.type<[]>
// CHECK-NEXT:        function.call @Foo::@constrain(%[[VAL_8]]) : (!struct.type<@Foo<[]>>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
