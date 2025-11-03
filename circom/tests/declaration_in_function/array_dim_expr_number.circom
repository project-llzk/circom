// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f() {
  var x[6];
  return x;
}

template A() {
  _ = f();
}

component main = A();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {

