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

template UnknownLoopOOB() {
    signal input m; // Could be out of bounds
    signal input n[2];
    signal output y;

    component a = accumulate();
    a.i <-- m;
    y <-- n[a.o];
}

component main = UnknownLoopOOB();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@UnknownLoopOOB::@UnknownLoopOOB<[]>>} {
// CHECK-NEXT:    poly.template @UnknownLoopOOB {
// CHECK-NEXT:      struct.def @UnknownLoopOOB {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @a : !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "m"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "n"}) -> !struct.type<@UnknownLoopOOB::@UnknownLoopOOB<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownLoopOOB::@UnknownLoopOOB<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_8]], @params = %[[VAL_7]] }  : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          pod.write %[[VAL_6]][@i] = %[[VAL_0]] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@count] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_10]], %[[VAL_11]] : index
// CHECK-NEXT:          pod.write %[[VAL_9]][@count] = %[[VAL_12]] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_12]], %[[VAL_13]] : index
// CHECK-NEXT:          scf.if %[[VAL_14]] {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@params] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = function.call @accumulate::@accumulate::@compute(%[[VAL_16]]) : (!felt.type<"bn128">) -> !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:            pod.write %[[VAL_9]][@comp] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@comp] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@o] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_20]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@y] = %[[VAL_21]] : <@UnknownLoopOOB::@UnknownLoopOOB<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@a$inputs] = %[[VAL_6]] : <@UnknownLoopOOB::@UnknownLoopOOB<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@comp] : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@a] = %[[VAL_22]] : <@UnknownLoopOOB::@UnknownLoopOOB<[]>>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@UnknownLoopOOB::@UnknownLoopOOB<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownLoopOOB::@UnknownLoopOOB<[]>>, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "m"}, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "n"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@y] : <@UnknownLoopOOB::@UnknownLoopOOB<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@a] : <@UnknownLoopOOB::@UnknownLoopOOB<[]>>, !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@a$inputs] : <@UnknownLoopOOB::@UnknownLoopOOB<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@accumulate::@accumulate<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @accumulate::@accumulate::@constrain(%[[VAL_27]], %[[VAL_31]]) : (!struct.type<@accumulate::@accumulate<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @accumulate {
// CHECK-NEXT:      struct.def @accumulate {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) -> !struct.type<@accumulate::@accumulate<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.new : <@accumulate::@accumulate<[]>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_34]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_36]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_37]]) %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_33]][@o] = %[[VAL_35]] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_33]] : !struct.type<@accumulate::@accumulate<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !struct.type<@accumulate::@accumulate<[]>>, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@o] : <@accumulate::@accumulate<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_46:[0-9a-zA-Z_\.]+]] = %[[VAL_44]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_46]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_47]]) %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_48]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
