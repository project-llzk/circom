// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Foo() {
  signal input a;
  signal output b;

  b <== a;
}

template Array1() {
    signal output out[5];
    component foo[5];

    for (var i = 0; i < 5; i++) {
      foo[i] = Foo();
      foo[i].a <== i;
      out[i] <== foo[i].b;
    }
}

component main = Array1();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
