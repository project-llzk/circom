// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Equal values survive merging, including an implicit else and untouched locals.
pragma circom 2.2.3;

bus Pair() { signal {size} x[2]; }

template Main(CHOOSE) {
    signal {size} s;
    s.size = 7;
    s <== 3;
    Pair() a;
    Pair() b;
    Pair() c;
    var bound;
    var unchanged = 2;
    var implicit = 2;
    if (CHOOSE) { bound = 1 + 1; }
    else { bound = 2; }
    if (CHOOSE) { implicit = 2; }
    for (var i = 0; i < bound; i++) { a.x[i] <== s; }
    for (var j = 0; j < unchanged; j++) { b.x[j] <== s; }
    for (var k = 0; k < implicit; k++) { c.x[k] <== s; }
    signal output out;
    out <== a.x.size + b.x.size + c.x.size;
}

component main = Main(0);

// CONCRETE-LABEL: struct.def @Main_0 {
// CONCRETE: function.def @compute(
// CONCRETE: %[[SUM:[0-9a-zA-Z_.-]+]] = felt.const 21 :
// CONCRETE-NEXT: struct.writem {{.*}}[@out] = %[[SUM]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[A:[0-9a-zA-Z_.-]+]] = felt.const 7 :
// TEMPLATED-NEXT: %[[B:[0-9a-zA-Z_.-]+]] = felt.const 7 :
// TEMPLATED-NEXT: %[[AB:[0-9a-zA-Z_.-]+]] = felt.add %[[A]], %[[B]]
// TEMPLATED-NEXT: %[[C:[0-9a-zA-Z_.-]+]] = felt.const 7 :
// TEMPLATED-NEXT: %[[ABC:[0-9a-zA-Z_.-]+]] = felt.add %[[AB]], %[[C]]
// TEMPLATED-NEXT: struct.writem {{.*}}[@out] = %[[ABC]]
// TEMPLATED: function.return
