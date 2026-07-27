// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function id(x) {
    return x;
}

function f() {
  var s = 3;
  var x[id(s)];
  return x;
}

template A() {
  _ = f();
}

component main = A();

// CHECK-LABEL: module attributes {
