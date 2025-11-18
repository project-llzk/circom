// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f(a) {
  if (a < 0) {
    return -a;
  }
  return a;
}

template Foo() {
  signal input inp;

  _ <-- f(inp);
}

component main = Foo();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
