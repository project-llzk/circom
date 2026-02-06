// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@UsingExample<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Example<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Example<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Example<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@Example<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !struct.type<@Example<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @UsingExample<[]> {
// CHECK-NEXT:      struct.field @example : !struct.type<@Example<[]>>
// CHECK-NEXT:      struct.field @example$inputs : !pod.type<[]>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@UsingExample<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@UsingExample<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = function.call @Example::@compute() : () -> !struct.type<@Example<[]>>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@Example<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:        struct.writef %[[VAL_2]][@example$inputs] = %[[VAL_6]] : <@UsingExample<[]>>, !pod.type<[]>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@Example<[]>>, @params: !pod.type<[]>]>, !struct.type<@Example<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_2]][@example] = %[[VAL_7]] : <@UsingExample<[]>>, !struct.type<@Example<[]>>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@UsingExample<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@UsingExample<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_8]][@example] : <@UsingExample<[]>>, !struct.type<@Example<[]>>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_8]][@example$inputs] : <@UsingExample<[]>>, !pod.type<[]>
// CHECK-NEXT:        function.call @Example::@constrain(%[[VAL_9]]) : (!struct.type<@Example<[]>>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
