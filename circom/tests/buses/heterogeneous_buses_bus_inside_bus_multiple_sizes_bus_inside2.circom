// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// The bus contains other buses
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(n){
    signal a[n];
    signal b[n];
}

bus Simple1(n){
    signal a[n];
}

bus Compuesto(n,m){
    signal a[m];
    Simple1(n) b[m];
    Simple(n) c;
}

template A(n,m){
    Compuesto(n,m) input in;
    Compuesto(n,m) output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.a;
        out.b <== in.b;
        out.c.a <== in.c.b;
        out.c.b <== in.c.a;
    }
}

template B(n1, m1, n2, m2, n3, m3){
    Compuesto(n1,m1) input in1;
    Compuesto(n2,m2) input in2;
    Compuesto(n3,m3) input in3;
    signal output out[3];

    var sizes_n[3] = [n1, n2, n3];
    var sizes_m[3] = [m1, m2, m3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes_n[i], sizes_m[i]);
        if (i == 0){
            aux[i].in.a <== in1.a;
            for (var j_m = 0; j_m < sizes_m[i]; j_m++){
                aux[i].in.b[j_m].a <== in1.b[j_m].a;
            }
        } else if (i == 1){
            aux[i].in.a <== in2.a;
            aux[i].in.b <== in2.b;
        } else{
            aux[i].in.a <== in3.a;
            aux[i].in.b <== in3.b;
        }
        for (var j_n = 0; j_n < sizes_n[i]; j_n++){
            aux[i].in.c.a[j_n] <== in3.c.a[j_n];
            aux[i].in.c.b[j_n] <== in3.c.b[j_n];
        }
        out[i] <== aux[i].out.c.b[0];
    }
}

component main = B(3, 4,5, 6,9,3);
