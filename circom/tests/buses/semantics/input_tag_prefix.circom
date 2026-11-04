// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The unused x tag has no value. It must not hide a derived output tag that
// depends only on xy, even while xy is a symbolic input tag in the caller.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Derive() {
    signal input {x, xy} in;
    signal output {size} out;
    out.size = in.xy > 0 ? in.xy + 1 : 1;
    out <== in;
}

template Expand() {
    signal input {size} in;
    Vec(in.size) output out;
    for (var i = 0; i < in.size; i++) { out.x[i] <== in; }
}

template Forward() {
    signal input {xy} in;
    signal {x, xy} tagged;
    tagged.xy = in.xy;
    tagged <== in;

    component derived = Derive();
    derived.in <== tagged;
    component expanded = Expand();
    expanded.in <== derived.out;

    Vec(derived.out.size) output out;
    for (var i = 0; i < derived.out.size; i++) {
        out.x[i] <== expanded.out.x[i];
    }
}

template Main() {
    signal {xy} source;
    source.xy = 2;
    source <== 5;
    component forwarded = Forward();
    forwarded.in <== source;
    signal output out;
    out <== forwarded.out.x[2];
}

component main = Main();

// CONCRETE-LABEL: struct.def @Derive_0 {
// CONCRETE-LABEL: struct.def @Expand_1 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @Forward_2 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @derived : !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE: struct.member @expanded : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Derive_0::@Derive_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!felt.type<"bn128">) -> !struct.type<@Derive_0::@Derive_0<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_1::@Expand_1::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!felt.type<"bn128">) -> !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE-LABEL: struct.def @Main_3 {
// CONCRETE: struct.member @forwarded : !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Forward_2::@Forward_2::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!felt.type<"bn128">) -> !struct.type<@Forward_2::@Forward_2<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}

// TEMPLATED: poly.param @"$tag$in$x"
// TEMPLATED: poly.param @"$tag$in$xy"
// TEMPLATED-LABEL: struct.def @Derive {
// TEMPLATED: poly.param @"$tag$in$size" : index
// TEMPLATED-LABEL: struct.def @Expand {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>
// TEMPLATED: poly.param @"$tag$in$xy"
// TEMPLATED: poly.param @"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" : index
// TEMPLATED: poly.expr @"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET:[0-9]+]]" {
// TEMPLATED-LABEL: struct.def @Forward {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$layout$(($tag$in$xy_Greater_0)?($tag$in$xy_Add_1):1)" x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @derived : !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED: struct.member @expanded : !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Derive::@Derive::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!felt.type<"bn128">) -> !struct.type<@Derive::@Derive<[0, @"$tag$in$xy"]>>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand::@Expand::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!felt.type<"bn128">) -> !struct.type<@Expand::@Expand<[@"$tag$in$xy_Greater_0?$tag$in$xy_Add_1:1@[[OFFSET]]"]>>
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @forwarded : !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Forward::@Forward::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!felt.type<"bn128">) -> !struct.type<@Forward::@Forward<[2, 3]>>
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
