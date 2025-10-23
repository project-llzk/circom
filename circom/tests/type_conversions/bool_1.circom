// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function binop_comp(a, b) {
  return a > b;
}

template A(x) {
  signal input in;
  signal output out;

  out <-- binop_comp(in, x);
}

component main = A(5);

//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
