// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template B(n) {
  signal input inB;
}

template A(n) {
  signal input inA;
  component x = B(n * n);
  x.inB <-- inA;
}

component main = A(5);

// CHECK-LABEL: module attributes {
