// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

bus miBus(n){
    signal a;
    signal b;
}

template A(){
    miBus(3) input in[3];

    miBus(3) output out[3][3] <== [in, in, in];

    in[2].a === out[1][2].a;
}

component main = A();
