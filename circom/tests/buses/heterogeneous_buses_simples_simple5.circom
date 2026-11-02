// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(n){
    signal a[n][2];
    signal b[n][2];
}

template A(n){
    Simple(n) input in;
    Simple(n) output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.b;
        out.b <== in.a;
    }
}

template B(n1, n2, n3){
    Simple(n1) input in1;
    Simple(n2) input in2;
    Simple(n3) input in3;
    signal output out[3];

    var sizes[3] = [n1, n2, n3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i]);
        for (var j = 0; j < sizes[i]; j++){
            if (i == 0){
                aux[i].in.a[j] <== in1.a[j];
                aux[i].in.b[j] <== in1.b[j];
            } else if (i == 1){
                aux[i].in.a[j] <== in2.a[j];
                aux[i].in.b[j] <== in2.b[j];
            } else{
                aux[i].in.a[j] <== in3.a[j];
                aux[i].in.b[j] <== in3.b[j];
            }
        }
        out[i] <== aux[i].out.b[0][1];
    }
}

component main = B(2, 3, 2);
