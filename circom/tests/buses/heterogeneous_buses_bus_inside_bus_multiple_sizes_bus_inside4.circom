// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// Array of buses with different sizes as inputs
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
    signal a[m]; //3
    Simple1(n) b[m]; //6
    Simple(n) c; //4
}

template A(n1, n2, m){
    Compuesto(n1, n2) input in[m];
    Compuesto(n1, n2) output out[m];

    if (n1 % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < m; i++){
            out[i].a <== in[i].a;
            out[i].b <== in[i].b;
            out[i].c.a <== in[i].c.b;
            out[i].c.b <== in[i].c.a;
        }
    }
}

template B(n1,n1a, m1, n2,n2a, m2, n3,n3a, m3){
    Compuesto(n1,n1a) input in1[m1];// 26
    Compuesto(n2,n2a) input in2[m2];// 26
    Compuesto(n3,n3a) input in3[m3];// 26
    signal output out[3];

    var sizes_n[3] = [n1, n2, n3];
    var sizes_a[3] = [n1a, n2a, n3a];
    var sizes_m[3] = [m1, m2, m3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes_n[i], sizes_a[i], sizes_m[i]);

        for (var l = 0; l < sizes_m[i]; l++){
            if (i == 0){
                for (var j_m = 0; j_m < sizes_a[i]; j_m++){
                    aux[i].in[l].a[j_m] <== in1[l].a[j_m];
                    for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                        aux[i].in[l].b[j_m].a[j_n] <== in1[l].b[j_m].a[j_n];
                    }
                }
            } else if (i == 1){
                for (var j_m = 0; j_m < sizes_a[i]; j_m++){
                    aux[i].in[l].a[j_m] <== in2[l].a[j_m];
                    aux[i].in[l].b[j_m].a <== in2[l].b[j_m].a;
                }
            } else{
                aux[i].in[l].a <== in3[l].a;
                aux[i].in[l].b <== in3[l].b;
            }
            for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                aux[i].in[l].c.a[j_n] <== in3[l].c.a[j_n];
                aux[i].in[l].c.b[j_n] <== in3[l].c.b[j_n];
            }
        }
        out[i] <== aux[i].out[0].b[0].a[0];
    }
}

component main = B(2, 6, 6, 2,7,8,32,5,21);
