// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function earlyReturnFn(inp, n, m, k, a) {
    if (n == 0) {
        return inp;
        // Everything below is unreachable because of the return above
        var dividend[5];
        for (var i = m; i >= 0; i--) {
            if (i == m) {
                dividend[k] = 0;
                for (var j = 0; j < k; j++) {
                    dividend[j] = a[j + m];
                }
            } else {
                for (var j = k; j >= 0; j--) {
                    dividend[j] = a[j + i];
                }
            }
        }
    }
    return 0;
}

template EarlyReturn() {
    signal input inp;
    signal input a[10];
    signal output outp;

    outp <== earlyReturnFn(inp, 0, inp, inp, a);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {
