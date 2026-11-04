// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.0;

bus S(){
    signal {a} aux;
}

template A(){
    input S() {b} inter;

    inter.b === 2;
    output S() {b} out <== inter;
}

template B(){
    component a = A();
    S() {b} prueba; prueba.b = 2; prueba.aux <== 1;
    a.inter <== prueba;
    a.out.b === 2;
}

component main = B();

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// CONCRETE: %[[VALUE2:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: %[[VALUE3:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE2]], %[[VALUE3]]
// CONCRETE: %[[AUX1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@aux]
// CONCRETE: %[[AUX2:[a-zA-Z0-9_.-]+]] = pod.read %{{[a-zA-Z0-9_.-]+}}[@aux]
// CONCRETE: constrain.eq %[[AUX1]], %[[AUX2]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_1 {
// CONCRETE: struct.member @prueba : !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE: struct.member @a : !struct.type<@A_0::@A_0<[]>>
// CONCRETE: struct.member @a$inputs : !pod.type<[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@inter] = %{{[a-zA-Z0-9_.-]+}} : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE6:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE6]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// CONCRETE: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[STATE1]][@params]
// CONCRETE: %[[INTER1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@inter]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[INTER1]]) : (!pod.type<[@aux: !felt.type<"bn128">]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE8:[a-zA-Z0-9_.-]+]][@prueba]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE8]][@a]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE8]][@a$inputs]
// CONCRETE: %[[VALUE9:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[AUX3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@aux]
// CONCRETE: constrain.eq %[[AUX3]], %[[VALUE9]]
// CONCRETE: %[[INTER2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@inter]
// CONCRETE: %[[AUX4:[a-zA-Z0-9_.-]+]] = pod.read %[[INTER2]][@aux]
// CONCRETE: %[[AUX5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@aux]
// CONCRETE: constrain.eq %[[AUX4]], %[[AUX5]]
// CONCRETE: %[[VALUE10:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: %[[VALUE11:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE10]], %[[VALUE11]]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD4]][@inter]
// CONCRETE: function.return

// TEMPLATED: poly.param @"$tag$inter$aux$a"
// TEMPLATED: poly.param @"$tag$inter$b"
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// TEMPLATED: %[[VALUE2:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE2]]
// TEMPLATED: %[[AUX1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@aux]
// TEMPLATED: %[[AUX2:[a-zA-Z0-9_.-]+]] = pod.read %{{[a-zA-Z0-9_.-]+}}[@aux]
// TEMPLATED: constrain.eq %[[AUX1]], %[[AUX2]]
// TEMPLATED: function.return
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @prueba : !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED: struct.member @a : !struct.type<@A::@A<[0, 2]>>
// TEMPLATED: struct.member @a$inputs : !pod.type<[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@inter] = %{{[a-zA-Z0-9_.-]+}} : <[@inter: !pod.type<[@aux: !felt.type<"bn128">]>]>, !pod.type<[@aux: !felt.type<"bn128">]>
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE6:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE6]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[INTER1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@inter]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[INTER1]]) : (!pod.type<[@aux: !felt.type<"bn128">]>) -> !struct.type<@A::@A<[0, 2]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE8:[a-zA-Z0-9_.-]+]][@prueba]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE8]][@a]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE8]][@a$inputs]
// TEMPLATED: %[[VALUE9:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED: %[[AUX3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@aux]
// TEMPLATED: constrain.eq %[[AUX3]], %[[VALUE9]]
// TEMPLATED: %[[INTER2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@inter]
// TEMPLATED: %[[AUX4:[a-zA-Z0-9_.-]+]] = pod.read %[[INTER2]][@aux]
// TEMPLATED: %[[AUX5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@aux]
// TEMPLATED: constrain.eq %[[AUX4]], %[[AUX5]]
// TEMPLATED: %[[VALUE10:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED: %[[VALUE11:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE10]], %[[VALUE11]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD4]][@inter]
// TEMPLATED: function.return
