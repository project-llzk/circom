// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function nbits(a) {
    var n = 1;
    var r = 0;
    while (n-1<a) {
        r++;
        n *= 2;
    }
    return r;
}

template Call2() {
    signal input m;
    signal output y;

    y <-- nbits(m);
}

component main = Call2();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Call2::@Call2<[]>>} {
// CHECK-NEXT:    function.def @nbits(%[[V_A:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_N0:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[V_R0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_3:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_N1:[0-9a-zA-Z_\.]+]] = %[[V_N0]], %[[V_R1:[0-9a-zA-Z_\.]+]] = %[[V_R0]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:        %[[V_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_7:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_N1]], %[[V_6]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_7]], %[[V_A]])
// CHECK-NEXT:        scf.condition(%[[V_8]]) %[[V_N1]], %[[V_R1]] : !felt.type, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[V_N2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_R2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[V_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_R3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_R2]], %[[V_11]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_13:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[V_N3:[0-9a-zA-Z_\.]+]] = felt.mul %[[V_N2]], %[[V_13]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[V_N3]], %[[V_R3]] : !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_3]]#1 : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Call2 {
// CHECK-NEXT:      struct.def @Call2 {
// CHECK-NEXT:        struct.member @y : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Call2::@Call2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.new : <@Call2::@Call2<[]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = function.call @nbits(%[[VAL_15]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_16]][@y] = %[[VAL_17]] : <@Call2::@Call2<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_16]] : !struct.type<@Call2::@Call2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@Call2::@Call2<[]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@y] : <@Call2::@Call2<[]>>, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
