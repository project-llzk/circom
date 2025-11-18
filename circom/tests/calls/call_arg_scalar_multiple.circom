// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f(a, b, c) {
  var x = a;
  var y = b;
  var z = c;
  return y;
}

template A() {
  _ = f(5, 10, 15);
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
