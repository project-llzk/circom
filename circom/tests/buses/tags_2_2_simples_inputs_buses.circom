// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.6;

bus A(){
    signal x;
    signal y;
}

template B(){
    A() input in;
    output A() {tag} out;
    out.tag = 2;
    out <== in;
}

component main = B();
