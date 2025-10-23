// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A(n) {
  signal input in[3];
  signal output out;
  var idx[3] = [ 2, 1, 0 ];

  var x = in[idx[n]];
  out <-- x;
}

component main = A(1);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
