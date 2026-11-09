// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// One missing leaf keeps the tag unavailable, even after the sibling fields and
// the rest of the nested bus array have been initialized.

pragma circom 2.2.3;

bus Tagged(ds, i) { signal {size} z[ds[i]]; signal a; }
bus Rows(ds, i) { Tagged(ds[i], 0) rows[2]; signal a; }

template Main() {
    signal {size} s;
    s.size = 4;
    s <== 1;
    Rows([[3, 5], [7, 8]], 0) data;
    data.rows[0].a <== 1;
    data.rows[1].a <== 1;
    data.a <== 1;
    data.rows[0].z <== [s, s, s];
    data.rows[1].z[0] <== s;
    data.rows[1].z[1] <== s;
    // TEMPLATED: nested_indexed_partial_tag.circom:[[@LINE+1]]:{{[0-9]+}}: tag data.rows.z.size read before all array elements are initialized
    signal output out[data.rows.z.size];
    for (var i = 0; i < data.rows.z.size; i++) { out[i] <== s; }
}

component main = Main();

// CONCRETE: Tag value has not been previously initialized
// CONCRETE: nested_indexed_partial_tag.circom{{.*}}:{{[0-9]+}}:
