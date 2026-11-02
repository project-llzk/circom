// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.2.0;
bus S2(){
    signal {a} aux[1];
}
bus S(){
    S2 {b} aux[1];
}

template A(){
    input S() {c} inter[1];
    //input signal {c} aux2;
    log(inter.c);
    inter.c === 3;
    log(inter.aux.b);
    inter.aux.b === 4;
    log(inter.aux.aux.a);
    inter.aux.aux.a === 5;
    signal output {c} out2[inter.c]; //using the value of inter.c to define the size of out2
    out2.c = inter.c + inter.aux.aux.a;
    for(var i = 0; i < inter.c; i++){
        out2[i] <== 0;
    }
    log(out2.c);
    out2.c === 8;
    output S() {c} out <== inter[0];
}

template B(){
    component a[1];
    a[0] = A();
    signal {a} anda; anda.a = 5; anda <== 3;
    S2() {b} prueba2; prueba2.b = 4;
    S() {c} prueba; prueba.c = 3;
    prueba2.aux[0] <== anda;
    prueba.aux[0] <== prueba2;

    a[0].inter[0] <== prueba;
    //log(a[0].out.aux[0].a); //First, it fails since a is not defined in S(). It should be b.
    //log(a[0].out.aux[0].b); //When used correctly, it fails since tags should not be used with array accesses but in the component array.
    //log(a[0].out.aux.b.a); //When used correctly, it fails since after a tag cannot be accessed anything else.
    log(a[0].out2.c); //When used correctly,
    a[0].out2.c === 8;
    log(a[0].out.aux.aux.a); //When used correctly,
    a[0].out.aux.aux.a === 5;
    log(a[0].out.aux.b); //When used correctly,
    a[0].out.aux.b === 4;
    log(a[0].out.c); //When used correctly,
    a[0].out.c === 3;
}

component main = B();
