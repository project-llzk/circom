// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk --llzk_passes='builtin.module(canonicalize,cse,remove-dead-values)' -o %t %s
// RUN: rm -rf %t && mkdir %t && %circom --llzk --llzk_passes='builtin.module(llzk-duplicate-read-write-elim,llzk-duplicate-op-elim)' -o %t %s
// RUN: rm -rf %t && mkdir %t && %circom --llzk --llzk_passes='builtin.module(llzk-inline-includes,llzk-const-global-propagation,llzk-pod-to-scalar)' -o %t %s
// END.

// Smoke test pass registration and execution only; transformed IR is intentionally unchecked.
// Keep the circuit empty so the passes need not perform any substantive transformations.
pragma circom 2.0.0;

template Empty() {}

component main = Empty();
