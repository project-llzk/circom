// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --llzk templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: sed 's/\x1b\[[0-9;]*m//g' %t/templated.stderr | FileCheck %s --check-prefix=TEMPLATED-ERROR
// RUN: if %circom --llzk concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: sed 's/\x1b\[[0-9;]*m//g' %t/concrete.stderr | FileCheck %s --check-prefix=CONCRETE-ERROR
// END.

pragma circom 2.0.0;

template Vector() {
    signal input in[4];
    signal output out[4];
    out <== in;
}

template Main() {
    // Assigning a shorter array is invalid, even when the tail was assigned earlier.
    component witness = Vector();
    witness.in[2] <-- 33;
    witness.in[3] <-- 44;
    witness.in <-- [11, 22];

    component constrained = Vector();
    constrained.in[2] <== 33;
    constrained.in[3] <== 44;
    constrained.in <== [11, 22];
}

component main = Main();

// TEMPLATED-ERROR: Failed to generate LLZK IR:
// TEMPLATED-ERROR-SAME: Unsupported cast to 'expected' type '!array.type<4 x !felt.type<"bn128">>' from value type '!array.type<2 x !felt.type<"bn128">>'

// CONCRETE-ERROR: error[T3001]: Typing error found: mismatched dimensions.
// CONCRETE-ERROR-NEXT: Expected length: 4, given 2
