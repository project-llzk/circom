// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function negative(n){
  var x;
  if (n < 0) {
    x = 1;
  } else {
    x = 0;
  }
  return x;
}

template C() {
  signal input in;
  signal output out;
  out <-- negative(in);
}

component main = C();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
