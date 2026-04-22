// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

// This test is for #355, which may not be the target for this PR. Remember to remove me is that's the case!!

pragma circom 2.0.0;

template A(n) {
  signal output x;
  x <== n;
}

template B() {
  component a[2];
  a[0] = A(1);
  a[1] = A(2);
}

component main = B();
