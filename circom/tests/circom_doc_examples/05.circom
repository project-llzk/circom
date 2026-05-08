// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.6; // note that custom templates are only allowed since version 2.0.6
pragma custom_templates;

template custom Example() {
   // custom template's code
}

template UsingExample() {
   component example = Example(); // instantiation of the custom template
}

component main = UsingExample();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@UsingExample::@UsingExample<[]>>} {
// CHECK-NEXT:    poly.template @Example {
// CHECK-NEXT:      struct.def @Example {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Example::@Example<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Example::@Example<[]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Example::@Example<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !struct.type<@Example::@Example<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @UsingExample {
// CHECK-NEXT:      struct.def @UsingExample {
// CHECK-NEXT:        struct.member @example : !struct.type<@Example::@Example<[]>>
// CHECK-NEXT:        struct.member @example$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@UsingExample::@UsingExample<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@UsingExample::@UsingExample<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = function.call @Example::@Example::@compute() : () -> !struct.type<@Example::@Example<[]>>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@Example::@Example<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = function.call @Example::@Example::@compute() : () -> !struct.type<@Example::@Example<[]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_10]] }  : <[@count: index, @comp: !struct.type<@Example::@Example<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@example$inputs] = %[[VAL_7]] : <@UsingExample::@UsingExample<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@comp] : <[@count: index, @comp: !struct.type<@Example::@Example<[]>>, @params: !pod.type<[]>]>, !struct.type<@Example::@Example<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@example] = %[[VAL_12]] : <@UsingExample::@UsingExample<[]>>, !struct.type<@Example::@Example<[]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@UsingExample::@UsingExample<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !struct.type<@UsingExample::@UsingExample<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@example] : <@UsingExample::@UsingExample<[]>>, !struct.type<@Example::@Example<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@example$inputs] : <@UsingExample::@UsingExample<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Example::@Example<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          function.call @Example::@Example::@constrain(%[[VAL_14]]) : (!struct.type<@Example::@Example<[]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
