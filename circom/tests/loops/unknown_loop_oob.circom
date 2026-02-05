// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@UnknownLoopOOB<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @UnknownLoopOOB<[]> {
// CHECK-NEXT:      struct.field @y : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @a : !struct.type<@accumulate<[]>>
// CHECK-NEXT:      struct.field @a$inputs : !pod.type<[@i: !felt.type]>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) -> !struct.type<@UnknownLoopOOB<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownLoopOOB<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@accumulate<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type]>
// CHECK-NEXT:        pod.write %[[VAL_5]][@i] = %[[VAL_0]] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@accumulate<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_6]], %[[VAL_7]] : index
// CHECK-NEXT:        pod.write %[[VAL_4]][@count] = %[[VAL_8]] : <[@count: index, @comp: !struct.type<@accumulate<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_8]], %[[VAL_9]] : index
// CHECK-NEXT:        scf.if %[[VAL_10]] {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@i] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @accumulate::@compute(%[[VAL_11]]) : (!felt.type) -> !struct.type<@accumulate<[]>>
// CHECK-NEXT:          pod.write %[[VAL_4]][@comp] = %[[VAL_12]] : <[@count: index, @comp: !struct.type<@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate<[]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate<[]>>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_13]][@o] : <@accumulate<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]]
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_15]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@y] = %[[VAL_16]] : <@UnknownLoopOOB<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@a$inputs] = %[[VAL_5]] : <@UnknownLoopOOB<[]>>, !pod.type<[@i: !felt.type]>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@accumulate<[]>>, @params: !pod.type<[]>]>, !struct.type<@accumulate<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_2]][@a] = %[[VAL_17]] : <@UnknownLoopOOB<[]>>, !struct.type<@accumulate<[]>>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@UnknownLoopOOB<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownLoopOOB<[]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_18]][@y] : <@UnknownLoopOOB<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_18]][@a] : <@UnknownLoopOOB<[]>>, !struct.type<@accumulate<[]>>
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_18]][@a$inputs] : <@UnknownLoopOOB<[]>>, !pod.type<[@i: !felt.type]>
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@i] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @accumulate::@constrain(%[[VAL_22]], %[[VAL_24]]) : (!struct.type<@accumulate<[]>>, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @accumulate<[]> {
// CHECK-NEXT:      struct.field @o : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@accumulate<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@accumulate<[]>>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_27]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_29]], %[[VAL_25]])
// CHECK-NEXT:          scf.condition(%[[VAL_30]]) %[[VAL_29]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_33]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_26]][@o] = %[[VAL_28]] : <@accumulate<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_26]] : !struct.type<@accumulate<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@accumulate<[]>>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_34]][@o] : <@accumulate<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_37]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_39]], %[[VAL_35]])
// CHECK-NEXT:          scf.condition(%[[VAL_40]]) %[[VAL_39]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_43]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
