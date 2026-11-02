// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

bus miBus(n){
    signal a;
    signal b;
}

bus otroBus(n){
    miBus(n) a[2];
}

template A(){
    otroBus(3) input in;
    miBus(3) input in1;

    miBus(3) output out[2] <== [in.a[0], in1];

    out[0].b === in.a[0].b;
}

component main = A();
