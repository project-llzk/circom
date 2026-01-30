// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A() {
  var s = 6;
  signal input in[2*s];
  var x[2*s] = in;
}

component main = A();

// CHECK-LABEL: module attributes {
