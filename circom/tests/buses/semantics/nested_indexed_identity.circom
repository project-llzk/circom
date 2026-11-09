// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// A nested constructor's indexed argument agrees with the standalone bus identity.

pragma circom 2.2.3;

bus Point(N) { signal z; signal a; }
bus Outer(ds, i) { Point(ds[i]) value; }

template Main() {
    Outer([2, 3], 0) input in;
    Point(2) output out;
    out <== in.value;
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_0 {
// CONCRETE: struct.member @out : !pod.type<[@z: !felt.type<"bn128">, @a: !felt.type<"bn128">]>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @out : !pod.type<[@z: !felt.type<"bn128">, @a: !felt.type<"bn128">]>
