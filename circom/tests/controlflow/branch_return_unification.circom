// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.8;

// Regression test: when both branches of an if/else return arrays of different concrete sizes
// and the function's return type is a type variable (!poly.tvar<@T_return>), code generation
// must not error with "expected array return type when both branches return arrays".
function f(n) {
    if (n == 1) {
        return [1, 2];
    } else {
        return [1, 2, 3];
    }
}

template T() {
    signal output out;
    var x[2] = f(1);
    out <== 0;
}

component main = T();

// CHECK-LABEL: poly.template @f
