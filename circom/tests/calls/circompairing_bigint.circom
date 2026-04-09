// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// COM: Adapted from `bigint.circom` in https://github.com/yi-sun/circom-pairing
// XFAIL:.*

pragma circom 2.0.0;

function long_sub(k, a, b) {
    var d[9];
    for (var i = 1; i < k; i++) { // 3 iterations b/c k=4
        if (a[i] >= b[i]) {
            d[i] = a[i] - b[i];
        }
    }
    return d;
}

function long_div(k, in) {
    var out[9];
    for (var i = k; i >= 0; i--) { // 5 iterations b/c k=4
        var sub[9] = in;
        var mul[9] = out;
        for (var j = 0; j <= k; j++) { // 5 iterations b/c k=4
            sub[i + j] = mul[j];
        }
        out = long_sub(k, out, sub);
    }
    return out;
}

template BigMod() {
  signal input in[9];
  signal output out[9];
  out <-- long_div(4, in);
}

component main = BigMod();

// CHECK-LABEL: module attributes {
