// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
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
// CONCRETE: struct.member @out : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[VALUE1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]] = %[[VALUE3:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return %[[VALUE4:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5:[a-zA-Z0-9_.-]+]][@out2]
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5]][@out]
// CONCRETE: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE7:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE6]], %[[VALUE7]]
// CONCRETE: %[[VALUE8:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE: %[[VALUE9:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE8]], %[[VALUE9]]
// CONCRETE: %[[VALUE10:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: %[[VALUE11:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE10]], %[[VALUE11]]
// CONCRETE: %[[VALUE12:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT1]], %[[VALUE12]]
// CONCRETE: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// CONCRETE: %[[VALUE15:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE14]], %[[VALUE15]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE16:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE17:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[AUX1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@aux]
// CONCRETE: %[[AUX2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@aux]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[AUX1]]{{\[}}%[[VALUE18:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[AUX2]]{{\[}}%[[VALUE18]]]
// CONCRETE: %[[AUX3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@aux]
// CONCRETE: %[[AUX4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@aux]
// CONCRETE: constrain.eq %[[AUX3]], %[[AUX4]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_1 {
// CONCRETE: struct.member @prueba2 : !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @prueba : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE: struct.member @a : !array.type<1 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE: struct.member @a$inputs : !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[INTER1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE19:[a-zA-Z0-9_.-]+]]] = %[[VALUE20:[a-zA-Z0-9_.-]+]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// CONCRETE: pod.write %[[ELEMENT5:[a-zA-Z0-9_.-]+]][@inter] = %[[INTER1]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE21:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE21]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@count]
// CONCRETE: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[ELEMENT6]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@params]
// CONCRETE: %[[INTER2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@inter]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[INTER2]]) : (!array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[ELEMENT6]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %[[VALUE22:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23:[a-zA-Z0-9_.-]+]][@anda]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@prueba2]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@prueba]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@a]
// CONCRETE: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@a$inputs]
// CONCRETE: %[[VALUE24:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD3]], %[[VALUE24]]
// CONCRETE: %[[AUX5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@aux]
// CONCRETE: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[AUX5]]{{\[}}%[[VALUE25:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT7]], %[[FIELD3]]
// CONCRETE: %[[AUX6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@aux]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[AUX6]]{{\[}}%[[VALUE26:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[AUX7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@aux]
// CONCRETE: %[[AUX8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@aux]
// CONCRETE: constrain.eq %[[AUX7]], %[[AUX8]]
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD7]]{{\[}}%[[VALUE27:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[INTER3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@inter]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[INTER3]]{{\[}}%[[VALUE28:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[AUX9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@aux]
// CONCRETE: %[[AUX10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@aux]
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[AUX9]]{{\[}}%[[VALUE29:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[AUX10]]{{\[}}%[[VALUE29]]]
// CONCRETE: %[[AUX11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@aux]
// CONCRETE: %[[AUX12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@aux]
// CONCRETE: constrain.eq %[[AUX11]], %[[AUX12]]
// CONCRETE: %[[VALUE30:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// CONCRETE: %[[VALUE31:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE30]], %[[VALUE31]]
// CONCRETE: %[[VALUE32:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: %[[VALUE33:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE32]], %[[VALUE33]]
// CONCRETE: %[[VALUE34:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE: %[[VALUE35:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE34]], %[[VALUE35]]
// CONCRETE: %[[VALUE36:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE37:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE36]], %[[VALUE37]]
// CONCRETE: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD6]]{{\[}}%[[VALUE38:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD7]]{{\[}}%[[VALUE38]]]
// CONCRETE: %[[INTER4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT14]][@inter]
// CONCRETE: function.return

// TEMPLATED: poly.param @"$tag$inter$aux$aux$a"
// TEMPLATED: poly.param @"$tag$inter$aux$b"
// TEMPLATED: poly.param @"$tag$inter$c" : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out2 : !array.type<@"$tag$inter$c" x !felt.type<"bn128">>
// TEMPLATED: struct.member @out : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: array.write %[[VALUE1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]] = %[[VALUE3:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.return %[[VALUE4:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5:[a-zA-Z0-9_.-]+]][@out2]
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5]][@out]
// TEMPLATED: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE7:[a-zA-Z0-9_.-]+]], %[[VALUE6]]
// TEMPLATED: %[[VALUE8:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE9:[a-zA-Z0-9_.-]+]], %[[VALUE8]]
// TEMPLATED: %[[VALUE10:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE11:[a-zA-Z0-9_.-]+]], %[[VALUE10]]
// TEMPLATED: %[[VALUE12:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT1]], %[[VALUE12]]
// TEMPLATED: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE15:[a-zA-Z0-9_.-]+]], %[[VALUE14]]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE16:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE17:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[AUX1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@aux]
// TEMPLATED: %[[AUX2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@aux]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[AUX1]]{{\[}}%[[VALUE18:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[AUX2]]{{\[}}%[[VALUE18]]]
// TEMPLATED: %[[AUX3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@aux]
// TEMPLATED: %[[AUX4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@aux]
// TEMPLATED: constrain.eq %[[AUX3]], %[[AUX4]]
// TEMPLATED: function.return
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @prueba2 : !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @prueba : !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED: struct.member @a : !array.type<1 x !struct.type<@A::@A<[5, 4, 3]>>>
// TEMPLATED: struct.member @a$inputs : !array.type<1 x !pod.type<[@inter: !array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: array.write %[[INTER1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE19:[a-zA-Z0-9_.-]+]]] = %[[VALUE20:[a-zA-Z0-9_.-]+]] : <1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>, !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>
// TEMPLATED: pod.write %[[ELEMENT5:[a-zA-Z0-9_.-]+]][@inter] = %[[INTER1]]
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE21:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE21]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@count]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[ELEMENT6]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@params]
// TEMPLATED: %[[INTER2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@inter]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[INTER2]]) : (!array.type<1 x !pod.type<[@aux: !array.type<1 x !pod.type<[@aux: !array.type<1 x !felt.type<"bn128">>]>>]>>) -> !struct.type<@A::@A<[5, 4, 3]>>
// TEMPLATED: pod.write %[[ELEMENT6]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE22:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23:[a-zA-Z0-9_.-]+]][@anda]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@prueba2]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@prueba]
// TEMPLATED: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@a]
// TEMPLATED: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE23]][@a$inputs]
// TEMPLATED: %[[VALUE24:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD3]], %[[VALUE24]]
// TEMPLATED: %[[AUX5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@aux]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[AUX5]]{{\[}}%[[VALUE25:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT7]], %[[FIELD3]]
// TEMPLATED: %[[AUX6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@aux]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[AUX6]]{{\[}}%[[VALUE26:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[AUX7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@aux]
// TEMPLATED: %[[AUX8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@aux]
// TEMPLATED: constrain.eq %[[AUX7]], %[[AUX8]]
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD7]]{{\[}}%[[VALUE27:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[INTER3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@inter]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[INTER3]]{{\[}}%[[VALUE28:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[AUX9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@aux]
// TEMPLATED: %[[AUX10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@aux]
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[AUX9]]{{\[}}%[[VALUE29:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[AUX10]]{{\[}}%[[VALUE29]]]
// TEMPLATED: %[[AUX11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@aux]
// TEMPLATED: %[[AUX12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@aux]
// TEMPLATED: constrain.eq %[[AUX11]], %[[AUX12]]
// TEMPLATED: %[[VALUE30:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// TEMPLATED: %[[VALUE31:[a-zA-Z0-9_.-]+]] = felt.const  8 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE30]], %[[VALUE31]]
// TEMPLATED: %[[VALUE32:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED: %[[VALUE33:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE32]], %[[VALUE33]]
// TEMPLATED: %[[VALUE34:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// TEMPLATED: %[[VALUE35:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE34]], %[[VALUE35]]
// TEMPLATED: %[[VALUE36:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED: %[[VALUE37:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE36]], %[[VALUE37]]
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD6]]{{\[}}%[[VALUE38:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD7]]{{\[}}%[[VALUE38]]]
// TEMPLATED: %[[INTER4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT14]][@inter]
// TEMPLATED: function.return
