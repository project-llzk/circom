// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function copy(inp) {
    var ret[3] = inp;
    return ret;
}

template ArrayCopyTemplate() {
    var inp[3];
    var outp[3] = copy(inp);
}

component main = ArrayCopyTemplate();

// CHECK-LABEL: module attributes {
