// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// XFAIL:.*
// Upstream Circom: bus tag propagation panics with "attempt to subtract with overflow" in debug builds.

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
        out.a[0].a[0] <-- 3;
        out.a[0].a[1] <-- 3;
    } else{
        out.a[0].a[1] <-- 3;
    }
    out.a[1] <== in.a[0];
    out.b <== 3;
}

component main = A();

