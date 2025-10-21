// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.3;

function long_gt(a, b) {
    for (var i = 1; i >= 0; i--) {
        if (a[i] > b[i]) {
            return 1;
        }
        if (a[i] <= b[i]) {
            return 0;
        }
    }
    return 0;
}

function long_scalar_mult(in) {
    var out[2] = in;
    return out;
}

function long_div2(in){
    var norm[2] = long_scalar_mult(in);
    var out[1] = [long_gt(norm, norm)];
    return out;
}

template Test() {
    signal input in[2];
	var out[1] = long_div2(in);
}

component main = Test();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
