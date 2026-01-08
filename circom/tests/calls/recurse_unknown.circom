// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*
// COM: error: 'bool.or' op only valid within a 'function.def' with 'function.allow_witness' attribute
// COM: This op comes from "||" and is not legal in "@constrain" but is legal in "@compute".
//      See `circom/tests/type_conversions/bool_2.circom` for more details.

pragma circom 2.0.0;

function factorial(x) {
    if (x == 0 || x == 1) return 1;
    return x * factorial(x - 1);
}

template Caller() {
    signal input inp;
    signal output outp;
    outp <-- factorial(inp);
}

component main = Caller();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
