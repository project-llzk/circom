// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*
// COM: error: 'bool.or' op only valid within a 'function.def' with 'function.allow_witness' attribute
// COM: This op comes from "||" and is not legal in "@constrain" but is legal in "@compute". Since it's
//      used in a pure function here, we either generate two separate functions for compute and constrain
//      or just replace it with something that works in both contexts. See bool_3.circom for more details.

pragma circom 2.0.0;

function binop_bool(a, b) {
  return a || b;
}

template A(x) {
  signal input in;
  signal output out;

  var temp;
  if (binop_bool(in, x)) {
    temp = 1;
  } else {
    temp = 0;
  }
  out <-- temp;

  //Essentially equivalent code:
  // out <-- binop_bool(in, x);
}

component main = A(555);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
