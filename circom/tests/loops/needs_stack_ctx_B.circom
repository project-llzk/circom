// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function fun(in, len) {
	var sum = 0;
    for (var j = 0; j < len; j++) {
    	sum += in[j];
    }
	return sum;
}

template Ark(t) {
    signal input in[t];
    signal output out[t];

    for (var i = 0; i < t; i++) {
        out[i] <-- fun(in, i);
    }
}

template NeedsStackContext(a, b) {
    signal input in[a][b];
    signal output out[a][b];
    component arks[a];
    for (var j = 0; j < a; j++) {
        arks[j] = Ark(b);
        arks[j].in <-- in[j];
    }
    for (var k = 0; k < a; k++) {
    	out[k] <-- arks[k].out;
    }
}

component main = NeedsStackContext(3, 2);

// CHECK-LABEL: module attributes {
