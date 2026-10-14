// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function bounded(x) {
  assert(x < 100);
  return x;
}

template A(n) {
  signal input in;
  assert(in > 0 &&
         in < n);
  var y = bounded(n);
}

component main = A(5);
