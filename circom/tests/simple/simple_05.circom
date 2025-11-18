// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A() {
	signal input a, b, d;
	signal output out;

	out <== (a + b) * d;
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
