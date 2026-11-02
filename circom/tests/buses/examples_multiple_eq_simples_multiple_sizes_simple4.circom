// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// Array of buses with different sizes as inputs
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(n){
    signal a[n];
    signal b[n];
}

template A(n, m){
    Simple(n) input in[m];
    Simple(n) output out[m];

    if (n % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < n; i++){
            out[i].a <== in[i].b;
            out[i].b <== in[i].a;
        }
    }
}

template B(n1, m1, n2, m2, n3, m3){
    Simple(n1) input in1[m1];
    Simple(n2) input in2[m2];
    Simple(n3) input in3[m3];
    signal output out[3];

    var sizes[3] = [n1, n2, n3];
    var sizes_m[3] = [m1, m2, m3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i], sizes_m[i]);
        for (var j_m = 0; j_m < sizes_m[i]; j_m++){
            if (i == 0){
                aux[i].in[j_m].a <-- in1[j_m].a;
                aux[i].in[j_m].b <-- in1[j_m].b;
                in1[j_m].a === aux[i].in[j_m].a;
                aux[i].in[j_m].b === in1[j_m].b;
            } else if (i == 1){
                aux[i].in[j_m].a <-- in2[j_m].a;
                aux[i].in[j_m].b <-- in2[j_m].b;
                aux[i].in[j_m].a === in2[j_m].a;
                in2[j_m].b === aux[i].in[j_m].b;
            } else{
                aux[i].in[j_m].a <-- in3[j_m].a;
                aux[i].in[j_m].b <-- in3[j_m].b;
                in3[j_m].a === aux[i].in[j_m].a;
                in3[j_m].b === aux[i].in[j_m].b;
            }
        }

        out[i] <-- aux[i].out[0].b[0];
        out[i] === aux[i].out[0].b[0];
    }
}

component main = B(2, 5, 6,3,8,3);
