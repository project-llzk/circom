// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A() {
  var s = -6;
  signal input in[-s];
  s = -12;
  var x[-s] = in;
}

component main = A();

// CHECK-LABEL: module attributes {
