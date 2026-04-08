// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs od -t x1 -N 4 | FileCheck %s
// END.

pragma circom 2.0.0;

// Verifies that the default bytecode output (i.e., no `--llzk_plaintext`) is MLIR bytecode
// by checking the 4-byte magic number at the start of the file.
template BytecodeOutput() {
    signal input a;
    signal output b;
    b <== a;
}

component main = BytecodeOutput();

// CHECK: 4d 4c ef 52
