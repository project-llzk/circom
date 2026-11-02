// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

// Simple case, array of buses as inputs, different sizes in the arrays
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(){
    signal a;
    signal b;
}

template A(n){
    Simple input in[n];
    Simple output out[n];

    if (n % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < n; i++){
            out[i].a <== in[i].b;
            out[i].b <== in[i].a;
        }
    }
}

template B(n1, n2, n3){
    Simple input in1[n1];
    Simple input in2[n2];
    Simple input in3[n3];
    Simple output out[3];

    var sizes[3] = [n1, n2, n3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i]);
        for (var j = 0; j < sizes[i]; j++){
            if (i == 0){
                aux[i].in[j] <== in1[j];
            } else if (i == 1){
                aux[i].in[j] <== in2[j];
            } else{
                aux[i].in[j] <== in3[j];
            }
        }
        out[i] <== aux[i].out[0];
    }
}

component main = B(2, 3, 2);
