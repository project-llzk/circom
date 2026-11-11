// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk --enable-var-scope
// END.

// Source: COSTA incomplete_assignments/correct/function_multiple2/function_multiple2.circom

function multiple_sizes(x){
    if (x == 0){
        return [99,99];
    } else if(x == 1){
        return [1, 1, 1, 1];
    } else{
        return [2, 2, 2, 2, 2, 2];
    }
}

template B(n){
    signal input in[n];
    signal output out[n];

    out <== in;
}


template A(){
    signal x[3] <== [0, 1, 2];

    component comp[3];

    var sizes[3] = [2,4,6];
    comp[0] = B(sizes[0]);
    comp[1] = B(sizes[1]);
    comp[2] = B(sizes[2]);

    var aux[3][10];

    signal vale3 <== 3;

    var sol[3][10] = [
        [99,99,0,0,0,0,0,0,0,0],
        [1,1,1,1,0,0,0,0,0,0],
        [2,2,2,2,2,2,0,0,0,0]
    ];

    for (var iter = 0; iter < 3; iter++){
        // assignment case multiple
        comp[iter].in <-- multiple_sizes(iter);

        aux[iter] = comp[iter].in;

        //log("Real output:");
        for (var i = 0; i < 10; i++){
            //log("Output[", i, "]", aux[iter][i]);
        }
    }

    aux === sol;
}

component main = A();

// Whole-array reads must be consumed inside their component dispatch branch.
// CHECK-LABEL: struct.def @A_3 {
// CHECK: function.def @compute(
// CHECK: scf.execute_region -> !array.type<3,10 x !felt.type<"bn128">> {
// CHECK: %[[SRC6:[0-9a-zA-Z_.-]+]] = pod.read {{.*}}[@in] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK: %[[ROW6:[0-9a-zA-Z_.-]+]] = array.extract %[[AUX6:[0-9a-zA-Z_.-]+]][{{.*}}] : <3,10 x !felt.type<"bn128">>
// CHECK: %[[BOUND6:[0-9a-zA-Z_.-]+]] = arith.constant 6 : index
// CHECK: scf.for %[[J6:[0-9a-zA-Z_.-]+]] = {{.*}} to %[[BOUND6]] step
// CHECK: %[[V6:[0-9a-zA-Z_.-]+]] = array.read %[[SRC6]][%[[J6]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.write %[[ROW6]][%[[J6]]] = %[[V6]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.insert %[[AUX6]][{{.*}}] = %[[ROW6]] : <3,10 x !felt.type<"bn128">>, <10 x !felt.type<"bn128">>
// CHECK: %[[SRC4:[0-9a-zA-Z_.-]+]] = pod.read {{.*}}[@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK: %[[ROW4:[0-9a-zA-Z_.-]+]] = array.extract %[[AUX4:[0-9a-zA-Z_.-]+]][{{.*}}] : <3,10 x !felt.type<"bn128">>
// CHECK: %[[BOUND4:[0-9a-zA-Z_.-]+]] = arith.constant 4 : index
// CHECK: scf.for %[[J4:[0-9a-zA-Z_.-]+]] = {{.*}} to %[[BOUND4]] step
// CHECK: %[[V4:[0-9a-zA-Z_.-]+]] = array.read %[[SRC4]][%[[J4]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.write %[[ROW4]][%[[J4]]] = %[[V4]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.insert %[[AUX4]][{{.*}}] = %[[ROW4]] : <3,10 x !felt.type<"bn128">>, <10 x !felt.type<"bn128">>
// CHECK: %[[SRC2:[0-9a-zA-Z_.-]+]] = pod.read {{.*}}[@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK: %[[ROW2:[0-9a-zA-Z_.-]+]] = array.extract %[[AUX2:[0-9a-zA-Z_.-]+]][{{.*}}] : <3,10 x !felt.type<"bn128">>
// CHECK: %[[BOUND2:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CHECK: scf.for %[[J2:[0-9a-zA-Z_.-]+]] = {{.*}} to %[[BOUND2]] step
// CHECK: %[[V2:[0-9a-zA-Z_.-]+]] = array.read %[[SRC2]][%[[J2]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.write %[[ROW2]][%[[J2]]] = %[[V2]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.insert %[[AUX2]][{{.*}}] = %[[ROW2]] : <3,10 x !felt.type<"bn128">>, <10 x !felt.type<"bn128">>
// CHECK: function.return
// CHECK: function.def @constrain(
// CHECK: scf.execute_region -> !array.type<3,10 x !felt.type<"bn128">> {
// CHECK: %[[SRC6:[0-9a-zA-Z_.-]+]] = pod.read {{.*}}[@in] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK: %[[ROW6:[0-9a-zA-Z_.-]+]] = array.extract %[[AUX6:[0-9a-zA-Z_.-]+]][{{.*}}] : <3,10 x !felt.type<"bn128">>
// CHECK: %[[BOUND6:[0-9a-zA-Z_.-]+]] = arith.constant 6 : index
// CHECK: scf.for %[[J6:[0-9a-zA-Z_.-]+]] = {{.*}} to %[[BOUND6]] step
// CHECK: %[[V6:[0-9a-zA-Z_.-]+]] = array.read %[[SRC6]][%[[J6]]] : <6 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.write %[[ROW6]][%[[J6]]] = %[[V6]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.insert %[[AUX6]][{{.*}}] = %[[ROW6]] : <3,10 x !felt.type<"bn128">>, <10 x !felt.type<"bn128">>
// CHECK: %[[SRC4:[0-9a-zA-Z_.-]+]] = pod.read {{.*}}[@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK: %[[ROW4:[0-9a-zA-Z_.-]+]] = array.extract %[[AUX4:[0-9a-zA-Z_.-]+]][{{.*}}] : <3,10 x !felt.type<"bn128">>
// CHECK: %[[BOUND4:[0-9a-zA-Z_.-]+]] = arith.constant 4 : index
// CHECK: scf.for %[[J4:[0-9a-zA-Z_.-]+]] = {{.*}} to %[[BOUND4]] step
// CHECK: %[[V4:[0-9a-zA-Z_.-]+]] = array.read %[[SRC4]][%[[J4]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.write %[[ROW4]][%[[J4]]] = %[[V4]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.insert %[[AUX4]][{{.*}}] = %[[ROW4]] : <3,10 x !felt.type<"bn128">>, <10 x !felt.type<"bn128">>
// CHECK: %[[SRC2:[0-9a-zA-Z_.-]+]] = pod.read {{.*}}[@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK: %[[ROW2:[0-9a-zA-Z_.-]+]] = array.extract %[[AUX2:[0-9a-zA-Z_.-]+]][{{.*}}] : <3,10 x !felt.type<"bn128">>
// CHECK: %[[BOUND2:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CHECK: scf.for %[[J2:[0-9a-zA-Z_.-]+]] = {{.*}} to %[[BOUND2]] step
// CHECK: %[[V2:[0-9a-zA-Z_.-]+]] = array.read %[[SRC2]][%[[J2]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.write %[[ROW2]][%[[J2]]] = %[[V2]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK: array.insert %[[AUX2]][{{.*}}] = %[[ROW2]] : <3,10 x !felt.type<"bn128">>, <10 x !felt.type<"bn128">>
// CHECK: constrain.eq {{.*}} : !array.type<3,10 x !felt.type<"bn128">>, !array.type<3,10 x !felt.type<"bn128">>
// CHECK: function.return
