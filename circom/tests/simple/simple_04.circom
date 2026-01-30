// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B() {
    signal input a;
    signal input b;
    signal output c;

    c <== a * b;
}

template A() {
    signal input a;
    signal input b;
    signal input d;
    signal output c;
    signal x;

    component cb = B();
    cb.a <== a;
    cb.b <== b;

    x <== cb.c;
    c <== x * d;
}

component main {public [a, b]} = A();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      struct.field @c : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @x : !felt.type
// CHECK-NEXT:      struct.field @cb : !struct.type<@B<[]>>
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[V_0:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[V_1:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[V_2:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_3:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[V_5:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[V_0]], %[[V_1]]) : (!felt.type, !felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:        %[[V_6:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_5]][@c] : <@B<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[V_3]][@x] = %[[V_6]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[V_7:[0-9a-zA-Z_\.]+]] = felt.mul %[[V_6]], %[[V_2]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[V_3]][@c] = %[[V_7]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[V_3]][@cb] = %[[V_5]] : <@A<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[V_3]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_8:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>, %[[V_9:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[V_10:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[V_11:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_17:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_8]][@c] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[V_15:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_8]][@x] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[V_12:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_8]][@cb] : <@A<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.call @B::@constrain(%[[V_12]], %[[V_9]], %[[V_10]]) : (!struct.type<@B<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        %[[V_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_12]][@c] : <@B<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_15]], %[[V_14]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_16:[0-9a-zA-Z_\.]+]] = felt.mul %[[V_15]], %[[V_11]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_17]], %[[V_16]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @B<[]> {
// CHECK-NEXT:      struct.field @c : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[V_18:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[V_19:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_20:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[V_21:[0-9a-zA-Z_\.]+]] = felt.mul %[[V_18]], %[[V_19]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[V_20]][@c] = %[[V_21]] : <@B<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[V_20]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_22:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[V_23:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}, %[[V_24:[0-9a-zA-Z_\.]+]]: !felt.type {llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:         %[[V_25:[0-9a-zA-Z_\.]+]] = felt.mul %[[V_23]], %[[V_24]] : !felt.type, !felt.type
// CHECK-DAG:         %[[V_26:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_22]][@c] : <@B<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_26]], %[[V_25]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
