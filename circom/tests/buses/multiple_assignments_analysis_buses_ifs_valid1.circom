// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

bus MiBusPeque{
    signal a[2];
}

bus MiBus{
    signal b;
    MiBusPeque a[2];
}

template A(){
    MiBus input in;
    MiBus output out;

    if (in.b > 10){
        out <-- in;
    } else{
        out <-- in;
    }
}

component main = A();
