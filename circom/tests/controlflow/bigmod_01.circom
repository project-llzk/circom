// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function short_div(k) {
    if (k == 0) {
		return k;
    } else {
        return -k;
    }
}

function long_div(){
    var out[1];
    out[0] = short_div(2);
    return out;
}

template BigModOld() {
    var out[1] = long_div();
}

component main = BigModOld();

// CHECK-LABEL: module attributes {
