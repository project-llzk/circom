// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Nested loops, nonzero starts, equivalent index expressions, and empty loops
// must retain the identities of each component and its derived output tags.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Child() {
    Tagged() input in;
    signal output {size} out;
    out.size = in.x.size;
    out <== in.x;
}

template Main() {
    Tagged() source;
    source.x.size = 3;
    source.x <== 5;
    component children[2][2];
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
            children[i][j] = Child();
        }
    }
    for (var row = 1; row < 3; row++) {
        for (var col = 1; col < 3; col++) {
            children[row - 1][col - 1].in <== source;
        }
    }
    // This unreachable assignment must not change any component's tags.
    for (var empty = 2; empty < 2; empty++) {
        children[0][0].in.x <== 0;
    }
    signal output out[children[1][1].out.size];
    for (var k = 0; k < 3; k++) {
        out[k] <== children[0][0].out + children[0][1].out
            + children[1][0].out + children[1][1].out;
    }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Child_0 {
// CONCRETE-LABEL: struct.def @Main_1 {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @children : !array.type<2,2 x !struct.type<@Child_0::@Child_0<[]>>>
// CONCRETE: function.def @compute(
// CONCRETE: %[[STATE1:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N1:[a-zA-Z0-9_.-]+]], @params = %[[POD1:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE: array.write %[[VALUE1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]], %[[VALUE3:[a-zA-Z0-9_.-]+]]] = %[[STATE1]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Child_0::@Child_0::@compute(%[[IN1:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE: function.return %[[VALUE4:[a-zA-Z0-9_.-]+]]

// TEMPLATED: poly.param @"$tag$in$x$size"
// TEMPLATED-LABEL: struct.def @Child {
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED: struct.member @children : !array.type<2,2 x !struct.type<@Child::@Child<[3]>>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[STATE1:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N1:[a-zA-Z0-9_.-]+]], @params = %[[POD1:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: array.write %[[VALUE1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]], %[[VALUE3:[a-zA-Z0-9_.-]+]]] = %[[STATE1]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[STATE2:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N2:[a-zA-Z0-9_.-]+]], @params = %[[POD2:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: array.write %[[VALUE1]]{{\[}}%[[VALUE4:[a-zA-Z0-9_.-]+]], %[[VALUE5:[a-zA-Z0-9_.-]+]]] = %[[STATE2]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[STATE3:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N3:[a-zA-Z0-9_.-]+]], @params = %[[POD3:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: array.write %[[VALUE1]]{{\[}}%[[VALUE6:[a-zA-Z0-9_.-]+]], %[[VALUE7:[a-zA-Z0-9_.-]+]]] = %[[STATE3]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[STATE4:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N4:[a-zA-Z0-9_.-]+]], @params = %[[POD4:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: array.write %[[VALUE1]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]], %[[VALUE9:[a-zA-Z0-9_.-]+]]] = %[[STATE4]] : <2,2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Child::@Child::@compute(%[[IN1:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[3]>>
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @Child::@Child::@compute(%[[IN2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[3]>>
// TEMPLATED: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @Child::@Child::@compute(%[[IN3:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[3]>>
// TEMPLATED: %[[CHILD4:[a-zA-Z0-9_.-]+]] = function.call @Child::@Child::@compute(%[[IN4:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[3]>>
// TEMPLATED: function.return %[[VALUE10:[a-zA-Z0-9_.-]+]]
