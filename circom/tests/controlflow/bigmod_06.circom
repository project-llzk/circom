// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function identity(n) {
   return n;
}

function short_div(n) {
    var ret;
    if (n != 0) {
	    ret = identity(n);
    }
    return ret;
}

function long_div(n) {
    var out[1];
    out[0] = short_div(n);
    return out;
}

template BigModOld(n) {
    var r[1] = long_div(n);
}

component main = BigModOld(2);

// CHECK-LABEL: module attributes {
