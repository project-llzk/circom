// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.1.6;

bus A(){
    signal {a} x;
}

template error(){
    input A() x;
    input signal b;
    if(x.x.a > 0){
        x.x === b;
        log("adds constraint");
    }
}

template B(){
    input signal b;
    A() aux;
    aux.x.a = 0;
    aux.x <== 9;
    error()(aux, b);

    A() aux1;
    aux1.x.a = aux.x.a + 4;
    aux1.x <== b;
    error()(aux1, b);
}

component main = B();

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @B_2 {
// CONCRETE: struct.member @aux : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE: struct.member @aux1 : !pod.type<[@x: !felt.type<"bn128">]>
// CONCRETE: struct.member @error_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@error_0::@error_0<[]>>
// CONCRETE: struct.member @error_[[MEMBER0]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// CONCRETE: struct.member @error_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@error_1::@error_1<[]>>
// CONCRETE: struct.member @error_[[MEMBER1]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[0-9a-zA-Z_.-]+]][@b] = %{{[0-9a-zA-Z_.-]+}} : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE2:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// CONCRETE: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// CONCRETE: %[[X1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@x]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@b]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @error_0::@error_0::@compute(%[[X1]], %[[B1]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error_0::@error_0<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @error_1::@error_1::@compute(%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error_1::@error_1<[]>>
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4:[0-9a-zA-Z_.-]+]][@aux]
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@aux1]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = struct.readm %[[VALUE4]][@error_[[MEMBER0]]]
// CONCRETE: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@error_[[MEMBER0]]$inputs]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = struct.readm %[[VALUE4]][@error_[[MEMBER1]]]
// CONCRETE: %[[FIELD6:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@error_[[MEMBER1]]$inputs]
// CONCRETE: %[[VALUE5:[0-9a-zA-Z_.-]+]] = felt.const  9 : <"bn128">
// CONCRETE: %[[X3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@x]
// CONCRETE: constrain.eq %[[X3]], %[[VALUE5]]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD4]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[VALUE6:[0-9a-zA-Z_.-]+]]
// CONCRETE: %[[X4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD4]][@x]
// CONCRETE: %[[X5:[0-9a-zA-Z_.-]+]] = pod.read %[[X4]][@x]
// CONCRETE: %[[X6:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@x]
// CONCRETE: constrain.eq %[[X5]], %[[X6]]
// CONCRETE: %[[X7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@x]
// CONCRETE: constrain.eq %[[X7]], %[[VALUE6]]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@b]
// CONCRETE: constrain.eq %[[B4]], %[[VALUE6]]
// CONCRETE: %[[X8:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@x]
// CONCRETE: %[[X9:[0-9a-zA-Z_.-]+]] = pod.read %[[X8]][@x]
// CONCRETE: %[[X10:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@x]
// CONCRETE: constrain.eq %[[X9]], %[[X10]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD4]][@x]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD4]][@b]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD6]][@x]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD6]][@b]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @error_0 {
// CONCRETE-LABEL: struct.def @error_1 {
// CONCRETE: function.def @constrain(
// CONCRETE: %[[X13:[0-9a-zA-Z_.-]+]] = pod.read %{{[0-9a-zA-Z_.-]+}}[@x]
// CONCRETE: constrain.eq %[[X13]], %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @aux : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED: struct.member @aux1 : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED: struct.member @error_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@error::@error<[0]>>
// TEMPLATED: struct.member @error_[[MEMBER0]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED: struct.member @error_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@error::@error<[4]>>
// TEMPLATED: struct.member @error_[[MEMBER1]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[0-9a-zA-Z_.-]+]][@b] = %{{[0-9a-zA-Z_.-]+}} : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE2:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[X1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@x]
// TEMPLATED: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@b]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @error::@error::@compute(%[[X1]], %[[B1]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error::@error<[0]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4:[0-9a-zA-Z_.-]+]][@aux]
// TEMPLATED: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@aux1]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = struct.readm %[[VALUE4]][@error_[[MEMBER0]]]
// TEMPLATED: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@error_[[MEMBER0]]$inputs]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = struct.readm %[[VALUE4]][@error_[[MEMBER1]]]
// TEMPLATED: %[[FIELD6:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@error_[[MEMBER1]]$inputs]
// TEMPLATED: %[[VALUE5:[0-9a-zA-Z_.-]+]] = felt.const  9 : <"bn128">
// TEMPLATED: %[[X2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@x]
// TEMPLATED: constrain.eq %[[X2]], %[[VALUE5]]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: constrain.eq %[[B2]], %[[VALUE6:[0-9a-zA-Z_.-]+]]
// TEMPLATED: %[[X3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD4]][@x]
// TEMPLATED: %[[X4:[0-9a-zA-Z_.-]+]] = pod.read %[[X3]][@x]
// TEMPLATED: %[[X5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@x]
// TEMPLATED: constrain.eq %[[X4]], %[[X5]]
// TEMPLATED: %[[X6:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@x]
// TEMPLATED: constrain.eq %[[X6]], %[[VALUE6]]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@b]
// TEMPLATED: constrain.eq %[[B3]], %[[VALUE6]]
// TEMPLATED: %[[X7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@x]
// TEMPLATED: %[[X8:[0-9a-zA-Z_.-]+]] = pod.read %[[X7]][@x]
// TEMPLATED: %[[X9:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@x]
// TEMPLATED: constrain.eq %[[X8]], %[[X9]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD4]][@x]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD4]][@b]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD6]][@x]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD6]][@b]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$x$x$a"
// TEMPLATED-LABEL: struct.def @error {
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[X12:[0-9a-zA-Z_.-]+]] = pod.read %{{[0-9a-zA-Z_.-]+}}[@x]
// TEMPLATED: constrain.eq %[[X12]], %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.return
