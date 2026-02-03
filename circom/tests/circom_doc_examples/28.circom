// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

template A() {
    signal input {binary} in;
    signal intermediate;
    signal output {binary} out;
    intermediate <== in;
    out <== intermediate;
}

template Caller(){
    signal input inp;
    signal output out;
    component a = A();
    a.in <== inp;
    out <== a.out;
}

component main = Caller();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Caller<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      struct.field @intermediate : !felt.type
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_1]][@intermediate] = %[[VAL_0]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_0]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_2]][@intermediate] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_2]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_5]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Caller<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @a : !struct.type<@A<[]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller<[]>>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = function.call @A::@compute(%[[VAL_6]]) : (!felt.type) -> !struct.type<@A<[]>>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_8]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_7]][@out] = %[[VAL_9]] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_7]][@a] = %[[VAL_8]] : <@Caller<[]>>, !struct.type<@A<[]>>
// CHECK-NEXT:        function.return %[[VAL_7]] : !struct.type<@Caller<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller<[]>>, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_10]][@out] : <@Caller<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_10]][@a] : <@Caller<[]>>, !struct.type<@A<[]>>
// CHECK-NEXT:        function.call @A::@constrain(%[[VAL_12]], %[[VAL_11]]) : (!struct.type<@A<[]>>, !felt.type) -> ()
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_12]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_14]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }

