// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Block-local declarations restore outer constants; assignments to outer locals persist.
pragma circom 2.2.3;

bus Value() { signal x; }

template Main() {
    Value() input in;
    signal output shadow;
    signal output write;
    var choose = 0;
    var changed = 0;
    if (1) {
        var choose = 1;
        changed = 1;
        var changed = 0;
    }
    if (choose) { shadow <== 11; }
    else { shadow <== 22; }
    if (changed) { write <== 33; }
    else { write <== 44; }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_0 {
// CONCRETE: function.def @compute(
// CONCRETE: %[[SHADOW:[a-zA-Z0-9_.-]+]] = felt.const 22 :
// CONCRETE-NEXT: struct.writem {{.*}}[@shadow] = %[[SHADOW]]
// CONCRETE: %[[WRITE:[a-zA-Z0-9_.-]+]] = felt.const 33 :
// CONCRETE-NEXT: struct.writem {{.*}}[@write] = %[[WRITE]]

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[SHADOW:[a-zA-Z0-9_.-]+]] = felt.const 22 :
// TEMPLATED-NEXT: struct.writem {{.*}}[@shadow] = %[[SHADOW]]
// TEMPLATED: %[[WRITE:[a-zA-Z0-9_.-]+]] = felt.const 33 :
// TEMPLATED-NEXT: struct.writem {{.*}}[@write] = %[[WRITE]]
