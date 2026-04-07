// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function binop_bool_array(a, b) {
  var arr[10];
  for (var i = 0; i < 10; i++) {
    arr[i] = a[i] || b[i];
  }
  return arr;
}

template A() {
  signal input in1[10];
  signal input in2[10];
  signal output out[10];

  out <-- binop_bool_array(in1, in2);
}

component main = A();

// CHECK-LABEL: module attributes {
