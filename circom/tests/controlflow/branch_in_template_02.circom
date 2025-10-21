// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template B() {
  signal input in1;
  signal input in2;
  signal output out;

  var x;
  if (in1 > 0) {
    x = in1;
  } else {
    x = in2;
  }
  out <-- x;
}

component main = B();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
