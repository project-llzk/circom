// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk --implicit-check-not=scf.while
// END.

pragma circom 2.2.3;

// Nested iterations carry outer writes forward and restore their local shadows.
template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0][0];
    } else {
        component child[2];
        var count = 0;
        for (var i = 0; i < 2; i++) {
            var previous[i + 1];
            previous[i] = n;
            var n = 0;
            n++;
            for (var j = i; j < i + 1; j++) {
                child[i] = R(previous[i] - i + j - 1, [a[j]]);
                count++;
            }
        }
        component tail = R(n - count + 1, [a[0]]);
        out <== child[0].out + child[1].out + tail.out;
    }
}

component main = R(1, [[7, 8], [9, 10]]);

// CHECK-LABEL: poly.template @R$arrays$1_2_2$values$0_1 {
// CHECK: struct.member @child : !array.type<2 x !struct.type<@R$arrays$1_1_2$values$0_0::
// CHECK: struct.member @tail : !struct.type<@R$arrays$1_1_2$values$0_0::
