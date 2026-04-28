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
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          pod.write %[[VAL_1]][@i] = %[[VAL_5]] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_6]], %[[VAL_7]] : index
// CHECK-NEXT:          pod.write %[[VAL_4]][@count] = %[[VAL_8]] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_8]], %[[VAL_9]] : index
// CHECK-NEXT:          scf.if %[[VAL_10]] {
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@params] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = function.call @accumulate::@accumulate::@compute(%[[VAL_12]]) : (!felt.type<"bn128">) -> !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:            pod.write %[[VAL_4]][@comp] = %[[VAL_13]] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@o] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@y] = %[[VAL_15]] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@a$inputs] = %[[VAL_1]] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@a] = %[[VAL_16]] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@y] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@a] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@a$inputs] : <@KnownLoopViaSignal::@KnownLoopViaSignal<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_20]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @accumulate::@accumulate::@constrain(%[[VAL_19]], %[[VAL_23]]) : (!struct.type<@accumulate::@accumulate<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @accumulate {
// CHECK-NEXT:      struct.def @accumulate {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@accumulate::@accumulate<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.new : <@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_26]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_28]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_29]]) %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_25]][@o] = %[[VAL_27]] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_25]] : !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !struct.type<@accumulate::@accumulate<[]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@o] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_36]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_38]], %[[VAL_34]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_39]]) %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
