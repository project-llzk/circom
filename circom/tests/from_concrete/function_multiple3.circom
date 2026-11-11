// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk --enable-var-scope
// END.

// Source: COSTA incomplete_assignments/correct/function_multiple3/function_multiple3.circom


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

    component comp1[3];
    comp1[0] = B(sizes[0]);
    comp1[1] = B(sizes[1]);
    comp1[2] = B(sizes[2]);

    var var0[2] = [99,99];
    var var1[4] = [1, 1, 1, 1];
    var var2[6] = [2, 2, 2, 2, 2, 2];

    signal vale3 <== 3;

    for (var iter = 0; iter < 3; iter++){
        // assignment case multiple
        comp[iter].in <-- multiple_sizes(iter);

        comp1[iter].in <== comp[iter].out;

        //log("Real output:");
        for (var i = 0; i < sizes[iter]; i++){
            //log("Output[", i, "]", comp1[iter].out[i]);
        }

        if (iter == 0){
            var0 === comp1[iter].out;
        }
        if (iter == 1){
            var1 === comp1[iter].out;
        }
        if (iter == 2){
            var2 === comp1[iter].out;
        }
    }
}

component main = A();

// Whole-array reads must be consumed inside their component dispatch branch.
// CHECK-LABEL: struct.def @A_3 {
// CHECK: function.def @compute(
// CHECK: %[[SRC6:[0-9a-zA-Z_.-]+]] = struct.readm {{.*}}[@out] : <@B_2::@B_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK: pod.write {{.*}}[@in] = %[[SRC6]] : <[@in: !array.type<6 x !felt.type<"bn128">>]>, !array.type<6 x !felt.type<"bn128">>
// CHECK: function.call @B_2::@B_2::@compute({{.*}}) : (!array.type<6 x !felt.type<"bn128">>) -> !struct.type<@B_2::@B_2<[]>>
// CHECK: %[[SRC4:[0-9a-zA-Z_.-]+]] = struct.readm {{.*}}[@out] : <@B_1::@B_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK: pod.write {{.*}}[@in] = %[[SRC4]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK: function.call @B_1::@B_1::@compute({{.*}}) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@B_1::@B_1<[]>>
// CHECK: %[[SRC2:[0-9a-zA-Z_.-]+]] = struct.readm {{.*}}[@out] : <@B_0::@B_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK: pod.write {{.*}}[@in] = %[[SRC2]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK: function.call @B_0::@B_0::@compute({{.*}}) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@B_0::@B_0<[]>>
// CHECK: function.return
// CHECK: function.def @constrain(
// CHECK: %[[SRC6:[0-9a-zA-Z_.-]+]] = struct.readm {{.*}}[@out] : <@B_2::@B_2<[]>>, !array.type<6 x !felt.type<"bn128">>
// CHECK: constrain.eq {{.*}}, %[[SRC6]] : !array.type<6 x !felt.type<"bn128">>, !array.type<6 x !felt.type<"bn128">>
// CHECK: %[[SRC4:[0-9a-zA-Z_.-]+]] = struct.readm {{.*}}[@out] : <@B_1::@B_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK: constrain.eq {{.*}}, %[[SRC4]] : !array.type<4 x !felt.type<"bn128">>, !array.type<4 x !felt.type<"bn128">>
// CHECK: %[[SRC2:[0-9a-zA-Z_.-]+]] = struct.readm {{.*}}[@out] : <@B_0::@B_0<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK: constrain.eq {{.*}}, %[[SRC2]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK: function.return
