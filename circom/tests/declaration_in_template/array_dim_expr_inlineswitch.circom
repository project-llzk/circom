// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A() {
  var s = -23;
  signal input in[s > 0 ? s : -s];
  var x[s > 0 ? s : -s] = in;
}

component main = A();

// CHECK-LABEL: module attributes {
