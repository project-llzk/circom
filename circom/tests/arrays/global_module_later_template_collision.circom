// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s
// END.

pragma circom 2.0.0;

// Functions are lowered before templates. This creates the generated-global module before the
// source-level template named `global` is inserted.
function literal() {
    var values[2] = [1, 2];
    return values[0];
}

template global() {
    signal output out <== literal();
}

template Main() {
    component child = global();
    signal output out <== child.out;
}

component main = Main();

// CHECK: module @global_ {
// CHECK: poly.template @literal {
// CHECK: global.read const @global_::@array_const_0
// CHECK: poly.template @global {
