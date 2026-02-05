// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template B() {
    signal input a;
    signal input b;
    signal output x;

    x <== a * b;
}

template Call1() {
    signal input m;
    signal input n;
    signal output y;

    component a = B();
    a.a <== m;
    a.b <== n;
    // Call to B::compute should happen here
    y <== a.x;
}

component main = Call1();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Call1<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @B<[]> {
// CHECK-NEXT:      struct.field @x : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[V_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@B<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_2:[0-9a-zA-Z_\.]+]] = struct.new : <@B<[]>>
// CHECK-NEXT:        %[[V_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[V_0]], %[[V_1]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[V_2]][@x] = %[[V_3]] : <@B<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[V_2]] : !struct.type<@B<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_4:[0-9a-zA-Z_\.]+]]: !struct.type<@B<[]>>, %[[V_5:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_6:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:         %[[V_7:[0-9a-zA-Z_\.]+]] = felt.mul %[[V_5]], %[[V_6]] : !felt.type, !felt.type
// CHECK-DAG:         %[[V_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_4]][@x] : <@B<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_8]], %[[V_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Call1<[]> {
// CHECK-NEXT:      struct.field @y : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @a : !struct.type<@B<[]>>
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[V_9:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_10:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Call1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_11:[0-9a-zA-Z_\.]+]] = struct.new : <@Call1<[]>>
// CHECK-NEXT:        %[[V_13:[0-9a-zA-Z_\.]+]] = function.call @B::@compute(%[[V_9]], %[[V_10]]) : (!felt.type, !felt.type) -> !struct.type<@B<[]>>
// CHECK-NEXT:        %[[V_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_13]][@x] : <@B<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[V_11]][@y] = %[[V_14]] : <@Call1<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[V_11]][@a] = %[[V_13]] : <@Call1<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.return %[[V_11]] : !struct.type<@Call1<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_15:[0-9a-zA-Z_\.]+]]: !struct.type<@Call1<[]>>, %[[V_16:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_17:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_21:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_15]][@y] : <@Call1<[]>>, !felt.type
// CHECK-NEXT:        %[[V_18:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_15]][@a] : <@Call1<[]>>, !struct.type<@B<[]>>
// CHECK-NEXT:        function.call @B::@constrain(%[[V_18]], %[[V_16]], %[[V_17]]) : (!struct.type<@B<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        %[[V_20:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_18]][@x] : <@B<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_21]], %[[V_20]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
