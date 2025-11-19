// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Inner(i,j) {
    signal input in;
    signal output out;
    
    out <-- (in >> i) & j;
}

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    
    component c[n];
    for (var i = 0; i < n; i++) {
    	c[i] = Inner(i, i+1);
    	c[i].in <-- in;
    	out[i] <-- c[i].out;
    }
}

component main = Num2Bits(3);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
