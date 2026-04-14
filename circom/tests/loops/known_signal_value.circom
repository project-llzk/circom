// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>} {
// CHECK-NEXT:    poly.template @KnownLoopViaSignal {
// CHECK-NEXT:      struct.def @KnownLoopViaSignal {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @a : !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@KnownLoopViaSignal::@KnownLoopViaSignal<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_1]] }  : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          pod.write %[[VAL_3]][@i] = %[[VAL_4]] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@count] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_5]], %[[VAL_6]] : index
// CHECK-NEXT:          pod.write %[[VAL_2]][@count] = %[[VAL_7]] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_7]], %[[VAL_8]] : index
// CHECK-NEXT:          scf.if %[[VAL_9]] {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @accumulate::@accumulate::@compute(%[[VAL_10]]) : (!felt.type<"bn128">) -> !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:            pod.write %[[VAL_2]][@comp] = %[[VAL_11]] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@comp] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_12]][@o] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@y] = %[[VAL_13]] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@a$inputs] = %[[VAL_3]] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@comp] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@a] = %[[VAL_14]] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@y] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@a] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@a$inputs] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @accumulate::@accumulate::@constrain(%[[VAL_17]], %[[VAL_19]]) : (!struct.type<@accumulate::@accumulate<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @accumulate {
// CHECK-NEXT:      struct.def @accumulate {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@accumulate::@accumulate<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.new : <@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_20]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_21]][@o] = %[[VAL_23]] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_21]] : !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@accumulate::@accumulate<[]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@o] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_34]], %[[VAL_30]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_35]]) %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
