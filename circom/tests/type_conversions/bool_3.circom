// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*
// COM: error: 'bool.or' op only valid within a 'function.def' with 'function.allow_witness' attribute
// COM: This op comes from "||" and is not legal in "@constrain" but is legal in "@compute".
//      In "@constrain", we could replace with OR from `circomlib/circuits/gates.circom` or implement
//      directly like OR or like `bool_or` from `circom_algebra/src/modular_arithmetic.rs`.

pragma circom 2.0.0;

template A(x) {
  signal input in;
  signal output out;

  var z = 0;
  if (in || x) {
    z = 1;
  }
  out <-- z;
}

component main = A(99);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
