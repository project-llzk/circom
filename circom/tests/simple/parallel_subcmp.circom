// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Foo() {}

template Parallel() {
    component foo = parallel Foo();
}

component main = Parallel();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Parallel::@Parallel<[]>>} {
// CHECK-NEXT:    poly.template @Foo {
// CHECK-NEXT:      struct.def @Foo {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Foo::@Foo<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo::@Foo<[]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Parallel {
// CHECK-NEXT:      struct.def @Parallel {
// CHECK-NEXT:        struct.member @foo : !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:        struct.member @foo$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Parallel::@Parallel<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Parallel::@Parallel<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = function.call @Foo::@Foo::@compute() : () -> !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = function.call @Foo::@Foo::@compute() : () -> !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_10]] }  : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@foo$inputs] = %[[VAL_7]] : <@Parallel::@Parallel<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@comp] : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@foo] = %[[VAL_12]] : <@Parallel::@Parallel<[]>>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Parallel::@Parallel<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !struct.type<@Parallel::@Parallel<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@foo] : <@Parallel::@Parallel<[]>>, !struct.type<@Foo::@Foo<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@foo$inputs] : <@Parallel::@Parallel<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Foo::@Foo<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          function.call @Foo::@Foo::@constrain(%[[VAL_14]]) : (!struct.type<@Foo::@Foo<[]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
