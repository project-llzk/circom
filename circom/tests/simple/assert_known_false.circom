// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template UCO() {
	for(var i = 0; i < 100; i++) {
		1 === 0;
	}
}

component main = UCO();

//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
