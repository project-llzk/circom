// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

function funWithLoop(n) {
	var acc = 0;
    for (var i = 1; i <= n; i++) {
        acc += i;
    }
    return acc;
}

template KnownFunctionArgs() {
    signal output out[3];

    out[0] <-- funWithLoop(4); // 0 + 1 + 2 + 3 + 4 = 10
    out[1] <-- funWithLoop(5); // 0 + 1 + 2 + 3 + 4 + 5 = 15
    
    var acc = 1;
    for (var i = 2; i <= funWithLoop(3); i++) { // 0 + 1 + 2 + 3 = 6
        acc *= i;
    }
    out[2] <-- acc; // 1 * 2 * 3 * 4 * 5 * 6 = 720
}

component main = KnownFunctionArgs();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
