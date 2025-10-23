// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

template NeedsStackContext(max) {
    signal input in[max];
    signal output out[max];
    for (var i = 0; i < max; i++) {
    	out[i] <-- fun(in, i);
    }
}

component main = NeedsStackContext(3);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
