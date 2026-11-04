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
// CONCRETE: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@b] = %{{[a-zA-Z0-9_.-]+}} : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE2:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// CONCRETE: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[STATE1]][@params]
// CONCRETE: %[[X1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@x]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@b]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @error_0::@error_0::@compute(%[[X1]], %[[B1]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error_0::@error_0<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @error_1::@error_1::@compute(%{{[a-zA-Z0-9_.-]+}}, %{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error_1::@error_1<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@aux]
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux1]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE4]][@error_[[MEMBER0]]]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@error_[[MEMBER0]]$inputs]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE4]][@error_[[MEMBER1]]]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@error_[[MEMBER1]]$inputs]
// CONCRETE: %[[VALUE5:[a-zA-Z0-9_.-]+]] = felt.const  9 : <"bn128">
// CONCRETE: %[[X3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@x]
// CONCRETE: constrain.eq %[[X3]], %[[VALUE5]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[VALUE6:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[X4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@x]
// CONCRETE: %[[X5:[a-zA-Z0-9_.-]+]] = pod.read %[[X4]][@x]
// CONCRETE: %[[X6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@x]
// CONCRETE: constrain.eq %[[X5]], %[[X6]]
// CONCRETE: %[[X7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@x]
// CONCRETE: constrain.eq %[[X7]], %[[VALUE6]]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@b]
// CONCRETE: constrain.eq %[[B4]], %[[VALUE6]]
// CONCRETE: %[[X8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@x]
// CONCRETE: %[[X9:[a-zA-Z0-9_.-]+]] = pod.read %[[X8]][@x]
// CONCRETE: %[[X10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@x]
// CONCRETE: constrain.eq %[[X9]], %[[X10]]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD4]][@x]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD4]][@b]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD6]][@x]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD6]][@b]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @error_0 {
// CONCRETE-LABEL: struct.def @error_1 {
// CONCRETE: function.def @constrain(
// CONCRETE: %[[X13:[a-zA-Z0-9_.-]+]] = pod.read %{{[a-zA-Z0-9_.-]+}}[@x]
// CONCRETE: constrain.eq %[[X13]], %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @aux : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED: struct.member @aux1 : !pod.type<[@x: !felt.type<"bn128">]>
// TEMPLATED: struct.member @error_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@error::@error<[0]>>
// TEMPLATED: struct.member @error_[[MEMBER0]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED: struct.member @error_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@error::@error<[4]>>
// TEMPLATED: struct.member @error_[[MEMBER1]]$inputs : !pod.type<[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@b] = %{{[a-zA-Z0-9_.-]+}} : <[@x: !pod.type<[@x: !felt.type<"bn128">]>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE2:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[X1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@x]
// TEMPLATED: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@b]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @error::@error::@compute(%[[X1]], %[[B1]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !felt.type<"bn128">) -> !struct.type<@error::@error<[0]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@aux]
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux1]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE4]][@error_[[MEMBER0]]]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@error_[[MEMBER0]]$inputs]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE4]][@error_[[MEMBER1]]]
// TEMPLATED: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@error_[[MEMBER1]]$inputs]
// TEMPLATED: %[[VALUE5:[a-zA-Z0-9_.-]+]] = felt.const  9 : <"bn128">
// TEMPLATED: %[[X2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@x]
// TEMPLATED: constrain.eq %[[X2]], %[[VALUE5]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: constrain.eq %[[B2]], %[[VALUE6:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[X3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@x]
// TEMPLATED: %[[X4:[a-zA-Z0-9_.-]+]] = pod.read %[[X3]][@x]
// TEMPLATED: %[[X5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@x]
// TEMPLATED: constrain.eq %[[X4]], %[[X5]]
// TEMPLATED: %[[X6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@x]
// TEMPLATED: constrain.eq %[[X6]], %[[VALUE6]]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@b]
// TEMPLATED: constrain.eq %[[B3]], %[[VALUE6]]
// TEMPLATED: %[[X7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@x]
// TEMPLATED: %[[X8:[a-zA-Z0-9_.-]+]] = pod.read %[[X7]][@x]
// TEMPLATED: %[[X9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@x]
// TEMPLATED: constrain.eq %[[X8]], %[[X9]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD4]][@x]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD4]][@b]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD6]][@x]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD6]][@b]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$x$x$a"
// TEMPLATED-LABEL: struct.def @error {
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[X12:[a-zA-Z0-9_.-]+]] = pod.read %{{[a-zA-Z0-9_.-]+}}[@x]
// TEMPLATED: constrain.eq %[[X12]], %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: function.return
