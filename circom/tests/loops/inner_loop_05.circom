// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Num2Bits(n) {
    signal input in;
    signal output out[n*n];

    for (var i = 0; i < n; i++) {
    	for (var j = 0; j < n; j++) {
        	out[i*n + j] <-- in;
        }
    }
}

component main = Num2Bits(2);

// CHECK-LABEL: module attributes {
