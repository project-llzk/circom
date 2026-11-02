// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

bus Bus1(){
    signal a[5];
    signal {value} b[2];
}

template B(){
    Bus1 input in;
    Bus1 output out <== in;

    in.b.value === 77;
}

template A(){
    signal input a[5];
    signal output b[5];

    signal {value} s;
    s.value = 77;
    s<== 4;

    signal {value} s1;
    s1.value = 77;
    s1 <== 2;

    Bus1 aux;
    aux.a <== a;
    aux.b[0] <== s1;
    aux.b[1] <== s;

    aux.b.value === 77;

    Bus1 output out <== B()(aux);

    b <== a;
}

component main = A();
