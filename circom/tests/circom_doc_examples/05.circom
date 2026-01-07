// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Example<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Example<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Example<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@Example<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !struct.type<@Example<[]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @UsingExample<[]> {
// CHECK-NEXT:      struct.field @example : !struct.type<@Example<[]>>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@UsingExample<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@UsingExample<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @Example::@compute() : () -> !struct.type<@Example<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_2]][@example] = %[[VAL_3]] : <@UsingExample<[]>>, !struct.type<@Example<[]>>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@UsingExample<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@UsingExample<[]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@example] : <@UsingExample<[]>>, !struct.type<@Example<[]>>
// CHECK-NEXT:        function.call @Example::@constrain(%[[VAL_5]]) : (!struct.type<@Example<[]>>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
