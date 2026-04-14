// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// This function calculates the number of extra bits
// in the output to do the full sum.
function nbits(a) {
    var n = 1;
    var r = 0;
    while (n-1<a) {
        r++;
        n *= 2;
    }
    return r;
}

function example(N){
    if (N >= 0) { return 1; }
    else { return 0; }
}

template Caller() {
    signal input in;
    signal output out;

    out <== example(nbits(in));
}

component main = Caller();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Caller::@Caller<[]>>} {
// CHECK-NEXT:    function.def @example(%[[V_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_2:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[V_0]], %[[V_1]])
// CHECK-NEXT:      %[[V_3:[0-9a-zA-Z_\.]+]] = scf.if %[[V_2]] -> (!felt.type) {
// CHECK-NEXT:        %[[V_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        scf.yield %[[V_4]] : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[V_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        scf.yield %[[V_5]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_3]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    function.def @nbits(%[[V_6:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_N0:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[V_R0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_9:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_N1:[0-9a-zA-Z_\.]+]] = %[[V_N0]], %[[V_R1:[0-9a-zA-Z_\.]+]] = %[[V_R0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:        %[[V_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_13:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_N1]], %[[V_12]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_13]], %[[V_6]])
// CHECK-NEXT:        scf.condition(%[[V_14]]) %[[V_N1]], %[[V_R1]] : !felt.type, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[V_N2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_R2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[V_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_R3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_R2]], %[[V_17]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_19:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[V_N3:[0-9a-zA-Z_\.]+]] = felt.mul %[[V_N2]], %[[V_19]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[V_N3]], %[[V_R3]] : !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_9]]#1 : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Caller {
// CHECK-NEXT:      struct.def @Caller {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Caller::@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller::@Caller<[]>>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @nbits(%[[VAL_21]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = function.call @example(%[[VAL_23]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_22]][@out] = %[[VAL_24]] : <@Caller::@Caller<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_22]] : !struct.type<@Caller::@Caller<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller::@Caller<[]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@out] : <@Caller::@Caller<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @nbits(%[[VAL_26]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = function.call @example(%[[VAL_28]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_27]], %[[VAL_29]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
