// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f() {
  var s = -6;
  var x[-s];
  return x;
}

template A() {
  _ = f();
}

component main = A();

// CHECK-LABEL: module attributes {
