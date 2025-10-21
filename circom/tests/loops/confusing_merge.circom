// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template Foo(N) {
  signal input inp[N];
  signal output outp[N];

  signal internal[N];

  for (var i = 0; i < N; i++) {
    internal[i] <== inp[i];
  }

  for (var i = 0; i < N; i++) {
    internal[i] ==> outp[i];
  }
}

component main = Foo(3);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
