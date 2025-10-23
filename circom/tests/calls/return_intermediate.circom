// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function Fn(a, b) {
  return a * b;
}

template Foo() {
  signal input inp[2];
  signal output outp[1];

  outp[0] <-- Fn(inp[0], inp[1]);
  outp[0] === Fn(inp[0], inp[1]);
}

component main = Foo();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
