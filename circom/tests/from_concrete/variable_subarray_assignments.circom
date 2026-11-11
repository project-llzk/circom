// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.1.0;

function patch(x) {
    var rows[2][4] = [[9, 9, 9, 9], [8, 8, 8, 8]];
    rows[0] = x;
    rows[1] = [1, 2, 3, 4, 5, 6];
    return rows;
}

template Main() {
    signal input in[2];
    var rows[2][4] = [[9, 9, 9, 9], [8, 8, 8, 8]];
    rows[0] = in;
    rows[1] = [1, 2, 3, 4, 5, 6];
    rows === [[in[0], in[1], 9, 9], [1, 2, 3, 4]];
    rows === patch(in);
}

component main = Main();

// Preserve the existing slice's tail, then write it back to its parent array.
// CHECK-LABEL: function.def @patch_
// CHECK: %[[FUNCTION_ROW:[0-9a-zA-Z_.-]+]] = array.extract
// CHECK: array.write %[[FUNCTION_ROW]]
// CHECK: array.insert {{.*}} = %[[FUNCTION_ROW]]
// CHECK-LABEL: struct.def @Main_
// CHECK: %[[TEMPLATE_ROW:[0-9a-zA-Z_.-]+]] = array.extract
// CHECK: array.write %[[TEMPLATE_ROW]]
// CHECK: array.insert {{.*}} = %[[TEMPLATE_ROW]]
