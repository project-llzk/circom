// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.6;

bus A(){
    signal {a} x;
}

template error(){
    input A() x;
    input signal b;
    if(x.x.a > 0){
        x.x === b;
        log("adds constraint");
    }
}

template B(){
    input signal b;
    A() aux;
    aux.x.a = 0;
    aux.x <== 9;
    error()(aux, b);

    A() aux1;
    aux1.x.a = aux.x.a + 4;
    aux1.x <== b;
    error()(aux1, b);
}

component main = B();
