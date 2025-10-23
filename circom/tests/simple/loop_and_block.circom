// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A(n) {
  signal input inp[n];
  signal output out[n];

  for ( var i = 0; i < n; i++ ) {
    out[i] <-- inp[i];
  }
}

component main = A(3);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
