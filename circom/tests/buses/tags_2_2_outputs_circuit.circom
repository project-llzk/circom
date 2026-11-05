// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefixes=CHECK,CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefixes=CHECK,TEMPLATED
// END.

pragma circom 2.2.0;
bus S2(){
    signal {a} aux[1];
}
bus S(){
    S2 {b} aux[1];
}

template A(){
    input S() {c} inter[1];
    //input signal {c} aux2;
    log(inter.c);
    inter.c === 3;
    log(inter.aux.b);
    inter.aux.b === 4;
    log(inter.aux.aux.a);
    inter.aux.aux.a === 5;
    signal output {c} out2[inter.c]; //using the value of inter.c to define the size of out2
    out2.c = inter.c + inter.aux.aux.a;
    for(var i = 0; i < inter.c; i++){
        out2[i] <== 0;
    }
    log(out2.c);
    out2.c === 8;
    output S() {c} out <== inter[0];
}

template B(){
    component a[1];
    a[0] = A();
    signal {a} anda; anda.a = 5; anda <== 3;
    S2() {b} prueba2; prueba2.b = 4;
    S() {c} prueba; prueba.c = 3;
    prueba2.aux[0] <== anda;
    prueba.aux[0] <== prueba2;

    a[0].inter[0] <== prueba;
    //log(a[0].out.aux[0].a); //First, it fails since a is not defined in S(). It should be b.
    //log(a[0].out.aux[0].b); //When used correctly, it fails since tags should not be used with array accesses but in the component array.
    //log(a[0].out.aux.b.a); //When used correctly, it fails since after a tag cannot be accessed anything else.
    log(a[0].out2.c); //When used correctly,
    a[0].out2.c === 8;
    log(a[0].out.aux.aux.a); //When used correctly,
    a[0].out.aux.aux.a === 5;
    log(a[0].out.aux.b); //When used correctly,
    a[0].out.aux.b === 4;
    log(a[0].out.c); //When used correctly,
    a[0].out.c === 3;
}

component main = B();

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out2 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED: poly.param @"$tag$inter$aux$aux$a"
// TEMPLATED: poly.param @"$tag$inter$aux$b"
// TEMPLATED: poly.param @"$tag$inter$c" : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out2 : !array.type<@"$tag$inter$c" x !felt.type<"bn128">>
// CHECK: struct.member @out : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CHECK: function.def @compute(
// CHECK: array.write %{{[a-zA-Z0-9_.-]+}}{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}}
// CHECK: function.return %{{[a-zA-Z0-9_.-]+}}
// CHECK: function.def @constrain(
// CHECK: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5:[a-zA-Z0-9_.-]+]][@out2]
// CHECK: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5]][@out]
// CHECK: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE7:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE6]], %[[VALUE7]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE6]]
// CHECK: %[[VALUE8:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE: %[[VALUE9:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE8]], %[[VALUE9]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE8]]
// CHECK: %[[VALUE10:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: %[[VALUE11:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE10]], %[[VALUE11]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE10]]
// CHECK: %[[VALUE12:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CHECK: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: constrain.eq %[[ELEMENT1]], %[[VALUE12]]
// CHECK: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// CONCRETE: %[[VALUE15:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE14]], %[[VALUE15]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE14]]
// CHECK: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %{{[a-zA-Z0-9_.-]+}}{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[AUX1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@aux]
// CHECK: %[[AUX2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@aux]
// CHECK: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[AUX1]]{{\[}}%[[VALUE18:[a-zA-Z0-9_.-]+]]]
// CHECK: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[AUX2]]{{\[}}%[[VALUE18]]]
// CHECK: %[[AUX3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@aux]
// CHECK: %[[AUX4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@aux]
// CHECK: constrain.eq %[[AUX3]], %[[AUX4]]
// CHECK: function.return
// CONCRETE-LABEL: struct.def @B_1 {
// TEMPLATED-LABEL: struct.def @B {
// CHECK: struct.member @prueba2 : !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CHECK: struct.member @prueba : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE: struct.member @a : !array.type<1 x !struct.type<@A_0::@A_0<[]>>>
// TEMPLATED: struct.member @a : !array.type<1 x !struct.type<@A::@A<[5, 4, 3]>>>
// CHECK: struct.member @a$inputs : !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// CHECK: function.def @compute(
// CHECK: array.write %[[INTER1:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CHECK: pod.write %[[ELEMENT5:[a-zA-Z0-9_.-]+]][@inter] = %[[INTER1]]
// CHECK: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6:[a-zA-Z0-9_.-]+]][@count]
// CHECK: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CHECK: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CHECK: %[[VALUE21:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CHECK: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE21]], %[[N3]]
// CHECK: scf.if %[[READY2]] {
// CHECK: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@count]
// CHECK: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CHECK: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CHECK: pod.write %[[ELEMENT6]][@count] = %[[REMAINING1]]
// CHECK: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CHECK: scf.if %[[READY3]] {
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[ELEMENT6]][@params]
// CHECK: %[[INTER2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@inter]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[INTER2]]) : (!array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>) -> !struct.type<@A_0::@A_0<[]>>
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[INTER2]]) : (!array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>) -> !struct.type<@A::@A<[5, 4, 3]>>
// CHECK: pod.write %[[ELEMENT6]][@comp] = %[[CHILD1]]
// CHECK: function.return %{{[a-zA-Z0-9_.-]+}}
// CHECK: function.def @constrain(
// CHECK: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23:[a-zA-Z0-9_.-]+]][@anda]
// CHECK: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@prueba2]
// CHECK: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@prueba]
// CHECK: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@a]
// CHECK: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@a$inputs]
// CHECK: %[[VALUE24:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CHECK: constrain.eq %[[FIELD3]], %[[VALUE24]]
// CHECK: %[[AUX5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@aux]
// CHECK: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[AUX5]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: constrain.eq %[[ELEMENT7]], %[[FIELD3]]
// CHECK: %[[AUX6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@aux]
// CHECK: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[AUX6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[AUX7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@aux]
// CHECK: %[[AUX8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@aux]
// CHECK: constrain.eq %[[AUX7]], %[[AUX8]]
// CHECK: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD7]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[INTER3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@inter]
// CHECK: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[INTER3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[AUX9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@aux]
// CHECK: %[[AUX10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@aux]
// CHECK: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[AUX9]]{{\[}}%[[VALUE29:[a-zA-Z0-9_.-]+]]]
// CHECK: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[AUX10]]{{\[}}%[[VALUE29]]]
// CHECK: %[[AUX11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@aux]
// CHECK: %[[AUX12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@aux]
// CHECK: constrain.eq %[[AUX11]], %[[AUX12]]
// CHECK: %[[VALUE30:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// CHECK: %[[VALUE31:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// CHECK: constrain.eq %[[VALUE30]], %[[VALUE31]]
// CHECK: %[[VALUE32:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CHECK: %[[VALUE33:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CHECK: constrain.eq %[[VALUE32]], %[[VALUE33]]
// CHECK: %[[VALUE34:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CHECK: %[[VALUE35:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CHECK: constrain.eq %[[VALUE34]], %[[VALUE35]]
// CHECK: %[[VALUE36:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CHECK: %[[VALUE37:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CHECK: constrain.eq %[[VALUE36]], %[[VALUE37]]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = array.read %[[FIELD6]]{{\[}}%[[VALUE38:[a-zA-Z0-9_.-]+]]]
// CHECK: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD7]]{{\[}}%[[VALUE38]]]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[ELEMENT14]][@inter]
// CHECK: function.return
