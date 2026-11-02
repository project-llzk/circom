// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

bus Bus1(){
    signal a[5];
    signal {binary} b;
}

template B(){
    Bus1 input in;
    Bus1 output out <== in;

    in.b.binary === 19;
}

template A(){
    signal input a[5];
    signal output b[5];

    Bus1 aux;
    aux.b.binary = 19;
    aux.a <== a;
    aux.b <== 0;

    aux.b.binary === 19;

    Bus1 output out <== B()(aux);

    b <== a;
}

component main = A();
