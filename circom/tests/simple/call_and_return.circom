// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template C() {
  signal input in;
  signal output out;
  out <-- negative(in);
}

function negative(n){
  if (n < 0) {
    return 1;
  } else {
    return 0;
  }
}

component main = C();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
