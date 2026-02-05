// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function myAdd(x1,y1,x2,y2) {
    var res[2] = [0x1 + y1, x2 + y2];
    return res;
}

function myFun() {
    var out[1][1];
    var dbl[2] = [18446744073709551557,18446744073709551557];
    for (var i=0; i < 4; i++) {
        dbl = myAdd(dbl[0], dbl[1], dbl[0], dbl[1]);
    }
    return out;
}

template A() {
    var table[1][1];
    table = myFun();
}

component main = A();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[]>>, veridise.lang = "llzk"} {
