// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

bus miBus(n){
    signal a;
    signal b;
}

template A(){
    miBus(3) input in;

    miBus(3) output out[2] <== [in, in];

    out[1].b === in.b;
}

component main = A();
