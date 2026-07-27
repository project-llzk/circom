// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A(n) {
  signal output x;
  x <== n;
}

template B(N) {
  component comp[N][N];
  for(var i = 1; i < N; i++) {
    for(var j = 0; j < N; j++) {
        comp[i][j] = A(i * 4 + j);
    }
  }
}

component main = B(2);

// CHECK-LABEL: module attributes {
