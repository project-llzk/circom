// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.5;

template B() {
  signal input in;
  signal output out;
  out <== in + 1;
}

template A(n) {
  signal out;
  if(n == 2) {
    // this demonstrates declaration of signal within a scope other than the initial one
    signal aux <== 2;
    out <== B()(aux);
  } else {
    out <== 5;
  }
}

component main = A(3);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
