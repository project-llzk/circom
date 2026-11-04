// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Every constructor for a component path needs hidden tag arguments, including
// both parameter-controlled branches and copies of each branch in fixed loops.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Branch(CHOOSE) {
    Tagged() a;
    a.x.size = 2;
    a.x <== 5;
    component child;
    if (CHOOSE != 0) { child = Expand(); }
    else { child = Expand(); }
    child.in <== a;
    signal output out;
    out <== child.out.x[1];
}

template LoopBranch(CHOOSE) {
    Tagged() a;
    Tagged() b;
    a.x.size = 2;
    b.x.size = 3;
    a.x <== 5;
    b.x <== 7;
    component children[2];
    for (var i = 0; i < 2; i++) {
        if (CHOOSE != 0) { children[i] = parallel Expand(); }
        else { children[i] = parallel (parallel Expand()); }
    }
    children[0].in <== a;
    children[1].in <== b;
    signal output out;
    out <== children[0].out.x[1] + children[1].out.x[2];
}

template Main() {
    component fromThen = Branch(1);
    component fromElse = Branch(0);
    component loopThen = LoopBranch(1);
    component loopElse = LoopBranch(0);
    signal output out;
    out <== fromThen.out + fromElse.out + loopThen.out + loopElse.out;
}

component main = Main();

// CONCRETE-LABEL: struct.def @Branch_1 {
// CONCRETE: struct.member @child : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_0::@Expand_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE-LABEL: struct.def @Branch_2 {
// CONCRETE: struct.member @child : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_0::@Expand_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE-LABEL: struct.def @Expand_0 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @Expand_3 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @LoopBranch_4 {
// CONCRETE: struct.member @children : !pod.type<[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE: function.def @compute(
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %[[POD3:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %[[POD3]] }  : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_3::@Expand_3::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_0::@Expand_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_3::@Expand_3::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_0::@Expand_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE-LABEL: struct.def @LoopBranch_5 {
// CONCRETE: struct.member @children : !pod.type<[@idx_0: !struct.type<@Expand_0::@Expand_0<[]>>, @idx_1: !struct.type<@Expand_3::@Expand_3<[]>>]>
// CONCRETE: function.def @compute(
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %[[POD4:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Expand_0::@Expand_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %[[POD4]] }  : <[@count: index, @comp: !struct.type<@Expand_3::@Expand_3<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_3::@Expand_3::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_0::@Expand_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_3::@Expand_3::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_3::@Expand_3<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand_0::@Expand_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE-LABEL: struct.def @Main_6 {
// CONCRETE: struct.member @fromElse : !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE: struct.member @fromThen : !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE: struct.member @loopElse : !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE: struct.member @loopThen : !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Branch_2::@Branch_2::@compute() : () -> !struct.type<@Branch_2::@Branch_2<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @Branch_1::@Branch_1::@compute() : () -> !struct.type<@Branch_1::@Branch_1<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @LoopBranch_5::@LoopBranch_5::@compute() : () -> !struct.type<@LoopBranch_5::@LoopBranch_5<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @LoopBranch_4::@LoopBranch_4::@compute() : () -> !struct.type<@LoopBranch_4::@LoopBranch_4<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @CHOOSE
// TEMPLATED-LABEL: struct.def @Branch {
// TEMPLATED: struct.member @child : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = scf.if %{{[a-zA-Z0-9_.-]+}} -> (!pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>) {
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: } else {
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand::@Expand::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: poly.param @"$tag$in$x$size" : index
// TEMPLATED-LABEL: struct.def @Expand {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED: poly.param @CHOOSE
// TEMPLATED-LABEL: struct.def @LoopBranch {
// TEMPLATED: struct.member @children : !array.type<2 x !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>>
// TEMPLATED: function.def @compute(
// TEMPLATED: scf.if %{{[a-zA-Z0-9_.-]+}} {
// TEMPLATED: %[[STATE3:[a-zA-Z0-9_.-]+]] = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[VALUE5:[a-zA-Z0-9_.-]+]] = poly.unifiable_cast %[[STATE3]]
// TEMPLATED: array.write %[[VALUE6:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[VALUE5]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: } else {
// TEMPLATED: %[[STATE4:[a-zA-Z0-9_.-]+]] = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[2]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[VALUE8:[a-zA-Z0-9_.-]+]] = poly.unifiable_cast %[[STATE4]]
// TEMPLATED: array.write %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[VALUE8]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: scf.if %{{[a-zA-Z0-9_.-]+}} {
// TEMPLATED: %[[STATE5:[a-zA-Z0-9_.-]+]] = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[VALUE11:[a-zA-Z0-9_.-]+]] = poly.unifiable_cast %[[STATE5]]
// TEMPLATED: array.write %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[VALUE11]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: } else {
// TEMPLATED: %[[STATE6:[a-zA-Z0-9_.-]+]] = pod.new { @count = %{{[a-zA-Z0-9_.-]+}}, @params = %{{[a-zA-Z0-9_.-]+}} }  : <[@count: index, @comp: !struct.type<@Expand::@Expand<[3]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[VALUE13:[a-zA-Z0-9_.-]+]] = poly.unifiable_cast %[[STATE6]]
// TEMPLATED: array.write %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[VALUE13]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>, @params: !pod.type<[@"$tag$in$x$size": !felt.type<"bn128">]>]>
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %{{[a-zA-Z0-9_.-]+}}[@params]
// TEMPLATED: %[[__TAG_IN_X_SIZE_1:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@"$tag$in$x$size"]
// TEMPLATED: %[[VALUE15:[a-zA-Z0-9_.-]+]] = cast.toindex %[[__TAG_IN_X_SIZE_1]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand::@Expand::@compute(%{{[a-zA-Z0-9_.-]+}}) {(%[[VALUE15]])} : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED: %[[PARAMS2:[a-zA-Z0-9_.-]+]] = pod.read %{{[a-zA-Z0-9_.-]+}}[@params]
// TEMPLATED: %[[__TAG_IN_X_SIZE_2:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS2]][@"$tag$in$x$size"]
// TEMPLATED: %[[VALUE16:[a-zA-Z0-9_.-]+]] = cast.toindex %[[__TAG_IN_X_SIZE_2]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Expand::@Expand::@compute(%{{[a-zA-Z0-9_.-]+}}) {(%[[VALUE16]])} : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[#[[$ATTR_0]]]>>
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @fromElse : !struct.type<@Branch::@Branch<[0]>>
// TEMPLATED: struct.member @fromThen : !struct.type<@Branch::@Branch<[1]>>
// TEMPLATED: struct.member @loopElse : !struct.type<@LoopBranch::@LoopBranch<[0]>>
// TEMPLATED: struct.member @loopThen : !struct.type<@LoopBranch::@LoopBranch<[1]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Branch::@Branch::@compute() : () -> !struct.type<@Branch::@Branch<[1]>>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @Branch::@Branch::@compute() : () -> !struct.type<@Branch::@Branch<[0]>>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @LoopBranch::@LoopBranch::@compute() : () -> !struct.type<@LoopBranch::@LoopBranch<[1]>>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @LoopBranch::@LoopBranch::@compute() : () -> !struct.type<@LoopBranch::@LoopBranch<[0]>>
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
