// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*
// related to the "TODO" in `cast_to_expected_type_if_needed()`

pragma circom 2.1.0;

template Ex(n,m){
   signal input in[n];
   signal output out[m];
   out <== in;
}

component main = Ex(3,3);

// CHECK-LABEL: module attributes {
