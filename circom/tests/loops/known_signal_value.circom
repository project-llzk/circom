// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template accumulate() {
    signal input i;
    signal output o;
    var r = 0;
    while (r < i) {
        r++;
    }
    o <-- r;
}

template KnownLoopViaSignal() {
    signal output y;

    component a = accumulate();
    a.i <-- 5;
    y <-- a.o;
}

component main = KnownLoopViaSignal();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @KnownLoopViaSignal<[]> {
// CHECK-NEXT:      struct.field @y : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @a : !struct.type<@accumulate<[]>>
// CHECK-NEXT:      function.def @compute() -> !struct.type<@KnownLoopViaSignal<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@KnownLoopViaSignal<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @accumulate::@compute(%[[VAL_1]]) : (!felt.type) -> !struct.type<@accumulate<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_2]][@o] : <@accumulate<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_0]][@y] = %[[VAL_3]] : <@KnownLoopViaSignal<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_0]][@a] = %[[VAL_2]] : <@KnownLoopViaSignal<[]>>, !struct.type<@accumulate<[]>>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@KnownLoopViaSignal<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@KnownLoopViaSignal<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@a] : <@KnownLoopViaSignal<[]>>, !struct.type<@accumulate<[]>>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = undef.undef : !felt.type
// CHECK-NEXT:        function.call @accumulate::@constrain(%[[VAL_5]], %[[VAL_6]]) : (!struct.type<@accumulate<[]>>, !felt.type) -> ()
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@y] : <@KnownLoopViaSignal<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @accumulate<[]> {
// CHECK-NEXT:      struct.field @o : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@accumulate<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@accumulate<[]>>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_8]])
// CHECK-NEXT:          scf.condition(%[[VAL_13]]) %[[VAL_12]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_15]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_16]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_9]][@o] = %[[VAL_11]] : <@accumulate<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_9]] : !struct.type<@accumulate<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@accumulate<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_21]], %[[VAL_18]])
// CHECK-NEXT:          scf.condition(%[[VAL_22]]) %[[VAL_21]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_25]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_17]][@o] : <@accumulate<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }

