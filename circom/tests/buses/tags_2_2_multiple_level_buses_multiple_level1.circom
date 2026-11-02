// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

bus Bus1(){
    signal a[5];
    signal {tag1} b;
}

bus Bus2(){
    signal {tag2} a;
    Bus1() {tag3} b;
}

template C(){
    input Bus1() {tag3} in;

    in.b.tag1 === 3;
}

template B(){
    Bus2() input {tag4} in;
    Bus1() output out <== in.b;

    in.b.tag3 === 5;
    C()(in.b);

    in.tag4 === 99;
}

template A(){
    signal input a[5];

    Bus1() {tag3} aux1;
    aux1.tag3 = 5;
    aux1.a <== a;

    signal {tag1} s;
    s.tag1 = 3;
    s <== 44;
    aux1.b <== s;

    Bus2() {tag4} aux;
    aux.tag4 = 99;

    signal {tag2} s1;
    s1.tag2 = 7;
    s1 <== 99;

    aux.a <== s1;
    aux.b <== aux1;

    Bus1 output out <== B()(aux);
}

component main = A();
