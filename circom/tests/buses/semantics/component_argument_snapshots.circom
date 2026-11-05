// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefixes=CHECK,CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefixes=CHECK,TEMPLATED
// END.

// Output tags retain constructor argument values after locals and indices change,
// including when an input-tag assignment later refreshes the component summary.

pragma circom 2.2.3;

template Source(N) {
    signal output {size} out;
    out.size = N;
    out <== 0;
}

template TaggedSource(N) {
    signal input {size} in;
    signal output {size} out;
    out.size = N + in.size;
    out <== in;
}

template Main() {
    var n = 2;
    var values[3] = [1, 4, 6];
    var index = 0;
    component scalar = Source(n);
    component indexed = Source(values[index + 1]);
    component delayed = TaggedSource(n);

    n = 3;
    values[1] = 9;
    index = 1;

    signal {size} tagged;
    tagged.size = 5;
    tagged <== 0;
    delayed.in <== tagged;

    signal output scalar_size;
    signal output indexed_size;
    signal output refreshed_size;
    scalar_size <== scalar.out.size;
    indexed_size <== indexed.out.size;
    refreshed_size <== delayed.out.size;
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main{{_[0-9]+}} {
// TEMPLATED-LABEL: struct.def @Main {
// CHECK-LABEL: function.def @compute(
// CHECK-DAG: %[[TWO:[a-zA-Z0-9_.-]+]] = felt.const 2 :
// CHECK-DAG: struct.writem {{.*}}[@scalar_size] = %[[TWO]] :
// CHECK-DAG: %[[FOUR:[a-zA-Z0-9_.-]+]] = felt.const 4 :
// CHECK-DAG: struct.writem {{.*}}[@indexed_size] = %[[FOUR]] :
// CHECK-DAG: %[[SEVEN:[a-zA-Z0-9_.-]+]] = felt.const 7 :
// CHECK-DAG: struct.writem {{.*}}[@refreshed_size] = %[[SEVEN]] :
// CHECK: function.return

// CHECK-LABEL: function.def @constrain(
// CHECK-DAG: %[[SCALAR:[a-zA-Z0-9_.-]+]] = struct.readm {{.*}}[@scalar_size]
// CHECK-DAG: %[[INDEXED:[a-zA-Z0-9_.-]+]] = struct.readm {{.*}}[@indexed_size]
// CHECK-DAG: %[[REFRESHED:[a-zA-Z0-9_.-]+]] = struct.readm {{.*}}[@refreshed_size]
// CHECK-DAG: %[[TWO:[a-zA-Z0-9_.-]+]] = felt.const 2 :
// CHECK-DAG: constrain.eq %[[SCALAR]], %[[TWO]] :
// CHECK-DAG: %[[FOUR:[a-zA-Z0-9_.-]+]] = felt.const 4 :
// CHECK-DAG: constrain.eq %[[INDEXED]], %[[FOUR]] :
// CHECK-DAG: %[[SEVEN:[a-zA-Z0-9_.-]+]] = felt.const 7 :
// CHECK-DAG: constrain.eq %[[REFRESHED]], %[[SEVEN]] :
// CHECK: function.return
