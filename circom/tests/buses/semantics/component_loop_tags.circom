// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Separate loops must address the same component instances regardless of the
// induction variable's name. Each instance keeps its own constructor arguments
// and tags, even when the constructors share a source location.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Child(OFFSET) {
    Tagged() input in;
    signal output {size} out;
    out.size = in.x.size + OFFSET;
    out <== in.x;
}

template Main() {
    Tagged() a;
    Tagged() b;
    a.x.size = 2;
    b.x.size = 3;
    a.x <== 5;
    b.x <== 7;
    component children[2];
    for (var i = 0; i < 2; i++) {
        children[i] = parallel (parallel Child(i));
    }
    for (var j = 0; j < 2; j++) {
        if (j == 0) { children[j].in <== a; }
        else { children[j].in <== b; }
    }
    signal output left[children[0].out.size];
    signal output right[children[1].out.size];
    for (var k = 0; k < 2; k++) {
        left[k] <== children[0].out;
    }
    for (var l = 0; l < 4; l++) {
        right[l] <== children[1].out;
    }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Child_0 {
// CONCRETE-LABEL: struct.def @Child_1 {
// CONCRETE-LABEL: struct.def @Main_2 {
// CONCRETE: struct.member @left : !array.type<2 x !felt.type<"bn128">>
// CONCRETE: struct.member @right : !array.type<4 x !felt.type<"bn128">>
// CONCRETE: struct.member @children : !pod.type<[@idx_0: !struct.type<@Child_0::@Child_0<[]>>, @idx_1: !struct.type<@Child_1::@Child_1<[]>>]>
// CONCRETE: function.def @compute(
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %[[POD1:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Child_0::@Child_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %[[POD1]] }  : <[@count: index, @comp: !struct.type<@Child_1::@Child_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Child_1::@Child_1::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Child_0::@Child_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Child_1::@Child_1::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_1::@Child_1<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Child_0::@Child_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child_0::@Child_0<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @OFFSET
// TEMPLATED: poly.param @"$tag$in$x$size"
// TEMPLATED-LABEL: struct.def @Child {
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @left : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED: struct.member @right : !array.type<4 x !felt.type<"bn128">>
// TEMPLATED: struct.member @children : !array.type<2 x !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[STATE1:[a-zA-Z0-9_.-]+]] = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Child::@Child<[0, 2]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[VALUE1:[a-zA-Z0-9_.-]+]] = poly.unifiable_cast %[[STATE1]]
// TEMPLATED: array.write %[[VALUE2:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[VALUE1]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[STATE2:[a-zA-Z0-9_.-]+]] = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Child::@Child<[1, 3]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[VALUE4:[a-zA-Z0-9_.-]+]] = poly.unifiable_cast %[[STATE2]]
// TEMPLATED: array.write %[[VALUE2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[VALUE4]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@OFFSET: !felt.type<"bn128">, @"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %{{[a-zA-Z0-9_.-]+}}[@params]
// TEMPLATED: %[[OFFSET1:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@OFFSET]
// TEMPLATED: %[[VALUE6:[a-zA-Z0-9_.-]+]] = cast.toindex %[[OFFSET1]]
// TEMPLATED: %[[__TAG_IN_X_SIZE_1:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@"$tag$in$x$size"]
// TEMPLATED: %[[VALUE7:[a-zA-Z0-9_.-]+]] = cast.toindex %[[__TAG_IN_X_SIZE_1]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Child::@Child::@compute(%{{[a-zA-Z0-9_.-]+}}) {(%[[VALUE6]]), (%[[VALUE7]])} : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED: %[[PARAMS2:[a-zA-Z0-9_.-]+]] = pod.read %{{[a-zA-Z0-9_.-]+}}[@params]
// TEMPLATED: %[[OFFSET2:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS2]][@OFFSET]
// TEMPLATED: %[[VALUE8:[a-zA-Z0-9_.-]+]] = cast.toindex %[[OFFSET2]]
// TEMPLATED: %[[__TAG_IN_X_SIZE_2:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS2]][@"$tag$in$x$size"]
// TEMPLATED: %[[VALUE9:[a-zA-Z0-9_.-]+]] = cast.toindex %[[__TAG_IN_X_SIZE_2]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Child::@Child::@compute(%{{[a-zA-Z0-9_.-]+}}) {(%[[VALUE8]]), (%[[VALUE9]])} : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Child::@Child<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
