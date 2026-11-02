// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

bus miBus(n){
    signal a;
    signal b;
}

template B(){
    miBus(3) input in;
    miBus(3) output out[3] <== [in, in, in];
}

template A(){
    miBus(3) input in[3];

    miBus(3) output out[3][3] <== [in, B()(in[1]), in];

    in[1].a === out[1][1].a;
}

component main = A();
