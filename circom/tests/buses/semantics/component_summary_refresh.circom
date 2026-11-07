// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefixes=CHECK,CONCRETE
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CALLS-CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefixes=CHECK,TEMPLATED
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=CALLS-TEMPLATED
// END.

// Exercise selective refresh across expanded arrays, whole-bus and repeated
// equal-tag assignments, unrelated writes, and a chain of component outputs.
// Fixed-size assignments and nominal bus copies check the derived layouts in
// both pipelines without depending on generated SSA names.

pragma circom 2.2.3;

bus Tagged() {
    signal {size} x[2];
    signal {size} y;
}

bus Vec(N) { signal x[N]; }

template Child() {
    Tagged() input in;
    signal output {size} out;
    out.size = in.x.size + in.y.size;
    out <== in.x[0] + in.x[1] + in.y;
}

template Bump() {
    signal input {size} in;
    signal output {size} out;
    out.size = in.size + 1;
    out <== in;
}

template Expand(SIZE) {
    signal input in;
    Vec(SIZE) output out;
    for (var i = 0; i < SIZE; i++) { out.x[i] <== in; }
}

template Branch(CHOOSE) {
    Tagged() left;
    Tagged() right;
    left.x.size = 2;
    right.x.size = 7;
    left.y.size = 3;
    right.y.size = 3;
    left.x <== [1, 2];
    right.x <== [3, 4];
    left.y <== 5;
    right.y <== 6;

    component child = Child();
    if (CHOOSE) { child.in <== left; }
    else { child.in <== right; }
    signal unrelated;
    unrelated <== 1;
    component expanded = Expand(child.out.size);
    expanded.in <== child.out;
    Vec(CHOOSE ? 5 : 10) output out;
    out <== expanded.out;
}

template Main() {
    Tagged() source;
    source.x.size = 2;
    source.y.size = 3;
    source.x <== [1, 2];
    source.y <== 3;

    component children[128];
    for (var i = 0; i < 128; i++) {
        children[i] = parallel Child();
    }
    signal unrelated[128];
    for (var j = 0; j < 128; j++) {
        unrelated[j] <== j;
        if (j < 64) {
            children[j].in <== source;
        } else {
            children[j].in.x[0] <== source.x[0];
            children[j].in.x[1] <== source.x[1];
            children[j].in.y <== source.y;
        }
        assert(children[j].out.size == 5);
    }

    component first = Bump();
    component second = Bump();
    first.in <== children[127].out;
    second.in <== first.out;
    signal output out[second.out.size];
    out <== [1, 2, 3, 4, 5, 6, 7];

    component fromThen = Branch(1);
    component fromElse = Branch(0);
    Vec(5) output left;
    Vec(10) output right;
    left <== fromThen.out;
    right <== fromElse.out;
}

component main = Main();

// Branch summaries keep the selected input tag and derived output dimension.
// Capture expression symbols without their source-location suffixes.
// TEMPLATED-LABEL: poly.template @Branch {
// TEMPLATED: poly.param [[LAYOUT:@"\$layout\$[^" ]+"]] : index
// TEMPLATED: poly.expr [[X_TAG:@"CHOOSE\?2:7@[0-9]+"]] {
// TEMPLATED: %[[TWO:[0-9a-zA-Z_.-]+]] = felt.const 2 :
// TEMPLATED: %[[SEVEN:[0-9a-zA-Z_.-]+]] = felt.const 7 :
// TEMPLATED: %[[TAG_SELECT:[0-9a-zA-Z_.-]+]] = arith.select {{.*}}, %[[TWO]], %[[SEVEN]]
// TEMPLATED-NEXT: poly.yield %[[TAG_SELECT]]
// TEMPLATED: poly.expr [[SIZE:@"CHOOSE\?5:10@[0-9]+"]] {
// TEMPLATED: %[[FIVE:[0-9a-zA-Z_.-]+]] = felt.const 5 :
// TEMPLATED: %[[TEN:[0-9a-zA-Z_.-]+]] = felt.const 10 :
// TEMPLATED: %[[SIZE_SELECT:[0-9a-zA-Z_.-]+]] = arith.select {{.*}}, %[[FIVE]], %[[TEN]]
// TEMPLATED-NEXT: poly.yield %[[SIZE_SELECT]]
// TEMPLATED-LABEL: struct.def @Branch {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<[[LAYOUT]] x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @child : !struct.type<@Child::@Child<{{\[}}[[X_TAG]], 3]>>
// TEMPLATED: struct.member @expanded : !struct.type<@Expand::@Expand<{{\[}}[[SIZE]]]>>
// TEMPLATED-LABEL: function.def @compute(
// TEMPLATED: %[[LEFT:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<
// TEMPLATED: %[[RIGHT:[0-9a-zA-Z_.-]+]] = llzk.nondet : !pod.type<
// TEMPLATED: pod.write %[[BRANCH_INPUTS:[0-9a-zA-Z_.-]+]][@in] = %[[LEFT]]
// TEMPLATED: function.call @Child::@Child::@compute({{.*}} -> !struct.type<@Child::@Child<{{\[}}[[X_TAG]], 3]>>
// TEMPLATED-LABEL: } else {
// TEMPLATED: pod.write %[[BRANCH_INPUTS]][@in] = %[[RIGHT]]
// TEMPLATED: function.call @Child::@Child::@compute({{.*}} -> !struct.type<@Child::@Child<{{\[}}[[X_TAG]], 3]>>
// TEMPLATED: struct.writem {{.*}}[@unrelated]
// TEMPLATED: function.call @Expand::@Expand::@compute({{.*}} -> !struct.type<@Expand::@Expand<{{\[}}[[SIZE]]]>>
// TEMPLATED-LABEL: function.def @constrain(

// Concrete branches specialize the same layouts to five and ten leaves.
// CONCRETE-LABEL: struct.def @Branch{{_[0-9]+}} {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<5 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @child : !struct.type<@[[THEN_CHILD:Child_[0-9]+]]::@[[THEN_CHILD]]<[]>>
// CONCRETE: struct.member @expanded : !struct.type<@[[EXPAND5:Expand_[0-9]+]]::@[[EXPAND5]]<[]>>
// CONCRETE-LABEL: function.def @compute(
// CONCRETE: function.call @[[THEN_CHILD]]::@[[THEN_CHILD]]::@compute(
// CONCRETE: struct.writem {{.*}}[@unrelated]
// CONCRETE: function.call @[[EXPAND5]]::@[[EXPAND5]]::@compute(
// CONCRETE: struct.writem {{.*}}[@out] = {{.*}}, !pod.type<[@x: !array.type<5 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: function.def @constrain(
// CONCRETE-LABEL: struct.def @Branch{{_[0-9]+}} {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<10 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @child : !struct.type<@[[ELSE_CHILD:Child_[0-9]+]]::@[[ELSE_CHILD]]<[]>>
// CONCRETE: struct.member @expanded : !struct.type<@[[EXPAND10:Expand_[0-9]+]]::@[[EXPAND10]]<[]>>
// CONCRETE-LABEL: function.def @compute(
// CONCRETE: function.call @[[ELSE_CHILD]]::@[[ELSE_CHILD]]::@compute(
// CONCRETE: struct.writem {{.*}}[@unrelated]
// CONCRETE: function.call @[[EXPAND10]]::@[[EXPAND10]]::@compute(
// CONCRETE: struct.writem {{.*}}[@out] = {{.*}}, !pod.type<[@x: !array.type<10 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: function.def @constrain(

// Main retains all 128 children and the layouts derived through both Bumps
// and both Branch instantiations. Member ordering is irrelevant here.
// CHECK-LABEL: struct.def @Main{{(_[0-9]+)?}} {
// CHECK-DAG: struct.member @source : [[BUS:!pod\.type<\[@x: !array\.type<2 x !felt\.type<"bn128">>, @y: !felt\.type<"bn128">\]>]]
// CHECK-DAG: struct.member @out : !array.type<7 x !felt.type<"bn128">>
// CHECK-DAG: struct.member @left : !pod.type<[@x: !array.type<5 x !felt.type<"bn128">>]>
// CHECK-DAG: struct.member @right : !pod.type<[@x: !array.type<10 x !felt.type<"bn128">>]>
// CONCRETE-DAG: struct.member @children : !array.type<128 x !struct.type<@[[CHILD:Child_[0-9]+]]::@[[CHILD]]<[]>>>
// TEMPLATED-DAG: struct.member @children : !array.type<128 x !struct.type<@[[CHILD:Child]]::@[[CHILD]]<[2, 3]>>>
// CHECK-DAG: struct.member @children$inputs : !array.type<128 x !pod.type<[@in: [[BUS]]]>>
// CONCRETE-DAG: struct.member @first : !struct.type<@[[FIRST:Bump_[0-9]+]]::@[[FIRST]]<[]>>
// CONCRETE-DAG: struct.member @second : !struct.type<@[[SECOND:Bump_[0-9]+]]::@[[SECOND]]<[]>>
// CONCRETE-DAG: struct.member @fromThen : !struct.type<@[[THEN:Branch_[0-9]+]]::@[[THEN]]<[]>>
// CONCRETE-DAG: struct.member @fromElse : !struct.type<@[[ELSE:Branch_[0-9]+]]::@[[ELSE]]<[]>>
// TEMPLATED-DAG: struct.member @first : !struct.type<@[[FIRST:Bump]]::@[[FIRST]]<[5]>>
// TEMPLATED-DAG: struct.member @second : !struct.type<@[[SECOND:Bump]]::@[[SECOND]]<[6]>>
// TEMPLATED-DAG: struct.member @fromThen : !struct.type<@Branch::@Branch<[1, 5]>>
// TEMPLATED-DAG: struct.member @fromElse : !struct.type<@Branch::@Branch<[0, 10]>>
// CHECK-LABEL: function.def @compute(
// CHECK: %[[SOURCE:[0-9a-zA-Z_.-]+]] = llzk.nondet : [[BUS]]
// CHECK: %[[THREE_INPUTS:[0-9a-zA-Z_.-]+]] = arith.constant 3 : index
// CHECK-NEXT: %[[INITIAL_STATE:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[THREE_INPUTS]], @params = {{.*}}@comp: !struct.type<@[[CHILD]]::@[[CHILD]]<
// TEMPLATED-NEXT: %[[INITIAL_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 0 :
// TEMPLATED-NEXT: %[[INITIAL_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[INITIAL_OFFSET]]
// TEMPLATED-NEXT: array.write {{.*}}[%[[INITIAL_INDEX]]] = %[[INITIAL_STATE]]
// CONCRETE: function.call @[[ELSE]]::@[[ELSE]]::@compute()
// CONCRETE: function.call @[[THEN]]::@[[THEN]]::@compute()

// A whole-bus assignment consumes three leaves and stores the completed child
// only in the zero-remainder arm. Follow both inputs and state back to the array.
// CHECK: %[[WHOLE_INPUTS:[0-9a-zA-Z_.-]+]] = array.read %[[INPUTS:[0-9a-zA-Z_.-]+]][%[[WHOLE_INDEX:[0-9a-zA-Z_.-]+]]] : <128 x !pod.type<[@in: [[BUS]]]>>
// CHECK-NEXT: %[[WHOLE_STATE:[0-9a-zA-Z_.-]+]] = array.read %[[STATES:[0-9a-zA-Z_.-]+]][%[[WHOLE_INDEX]]]
// CHECK: pod.write %[[WHOLE_INPUTS]][@in] = %[[SOURCE]]
// CHECK: scf.if %{{[0-9a-zA-Z_.-]+}} {
// CHECK-NEXT: %[[WHOLE_COUNT:[0-9a-zA-Z_.-]+]] = pod.read %[[WHOLE_STATE]][@count]
// CHECK-NEXT: %[[WHOLE_WRITTEN:[0-9a-zA-Z_.-]+]] = arith.constant 3 : index
// CHECK-NEXT: %[[WHOLE_REMAINING:[0-9a-zA-Z_.-]+]] = arith.subi %[[WHOLE_COUNT]], %[[WHOLE_WRITTEN]]
// CHECK-NEXT: pod.write %[[WHOLE_STATE]][@count] = %[[WHOLE_REMAINING]]
// CHECK-NEXT: %[[WHOLE_ZERO:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT: %[[WHOLE_READY:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[WHOLE_REMAINING]], %[[WHOLE_ZERO]]
// CHECK-NEXT: scf.if %[[WHOLE_READY]] {
// CHECK: %[[WHOLE_ARG:[0-9a-zA-Z_.-]+]] = pod.read %[[WHOLE_INPUTS]][@in]
// CHECK-NEXT: %[[WHOLE_RESULT:[0-9a-zA-Z_.-]+]] = function.call @[[CHILD]]::@[[CHILD]]::@compute(%[[WHOLE_ARG]])
// CHECK-NEXT: pod.write %[[WHOLE_STATE]][@comp] = %[[WHOLE_RESULT]]
// CHECK-NEXT: }
// CHECK-NEXT: }
// CHECK-NEXT: array.write %[[INPUTS]][%[[WHOLE_INDEX]]] = %[[WHOLE_INPUTS]]
// CHECK-NEXT: array.write %[[STATES]][%[[WHOLE_INDEX]]] = %[[WHOLE_STATE]]

// In the concrete loop, the else arm contains the three narrowed writes.
// The templated pipeline expands the loop; its first narrowed write is child 64.
// CONCRETE: scf.yield %[[STATES]], %[[INPUTS]]
// CONCRETE-LABEL: } else {
// CHECK: %[[X0_SOURCE:[0-9a-zA-Z_.-]+]] = pod.read %[[SOURCE]][@x]
// CHECK: %[[X0_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 0 :
// CHECK-NEXT: %[[X0_SRC_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[X0_OFFSET]]
// CHECK-NEXT: %[[X0_VALUE:[0-9a-zA-Z_.-]+]] = array.read %[[X0_SOURCE]][%[[X0_SRC_INDEX]]]
// TEMPLATED: %[[X0_CHILD_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 64 :
// TEMPLATED-NEXT: %[[X0_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[X0_CHILD_OFFSET]]
// CONCRETE: %[[X0_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %{{[0-9a-zA-Z_.-]+}}
// CHECK-NEXT: %[[X0_INPUTS:[0-9a-zA-Z_.-]+]] = array.read %[[INPUTS]][%[[X0_INDEX]]]
// CHECK-NEXT: %[[X0_STATE:[0-9a-zA-Z_.-]+]] = array.read %[[STATES]][%[[X0_INDEX]]]
// CHECK: %[[X0_BUS:[0-9a-zA-Z_.-]+]] = pod.read %[[X0_INPUTS]][@in]
// CHECK: %[[X0_ARRAY:[0-9a-zA-Z_.-]+]] = pod.read %[[X0_BUS]][@x]
// CHECK: %[[X0_DST_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 0 :
// CHECK-NEXT: %[[X0_DST_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[X0_DST_OFFSET]]
// CHECK: array.write %[[X0_ARRAY]][%[[X0_DST_INDEX]]] = %[[X0_VALUE]]
// CHECK-NEXT: pod.write %[[X0_BUS]][@x] = %[[X0_ARRAY]]
// CHECK-NEXT: pod.write %[[X0_INPUTS]][@in] = %[[X0_BUS]]
// CHECK: scf.if %{{[0-9a-zA-Z_.-]+}} {
// CHECK-NEXT: %[[X0_COUNT:[0-9a-zA-Z_.-]+]] = pod.read %[[X0_STATE]][@count]
// CHECK-NEXT: %[[X0_WRITTEN:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT: %[[X0_REMAINING:[0-9a-zA-Z_.-]+]] = arith.subi %[[X0_COUNT]], %[[X0_WRITTEN]]
// CHECK-NEXT: pod.write %[[X0_STATE]][@count] = %[[X0_REMAINING]]
// CHECK-NEXT: %[[X0_ZERO:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT: %[[X0_READY:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[X0_REMAINING]], %[[X0_ZERO]]
// CHECK-NEXT: scf.if %[[X0_READY]] {
// CHECK: %[[X0_ARG:[0-9a-zA-Z_.-]+]] = pod.read %[[X0_INPUTS]][@in]
// CHECK-NEXT: %[[X0_RESULT:[0-9a-zA-Z_.-]+]] = function.call @[[CHILD]]::@[[CHILD]]::@compute(%[[X0_ARG]])
// CHECK-NEXT: pod.write %[[X0_STATE]][@comp] = %[[X0_RESULT]]
// CHECK-NEXT: }
// CHECK-NEXT: }
// CHECK-NEXT: array.write %[[INPUTS]][%[[X0_INDEX]]] = %[[X0_INPUTS]]
// CHECK-NEXT: array.write %[[STATES]][%[[X0_INDEX]]] = %[[X0_STATE]]

// CHECK: %[[X1_SOURCE:[0-9a-zA-Z_.-]+]] = pod.read %[[SOURCE]][@x]
// CHECK: %[[X1_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 1 :
// CHECK-NEXT: %[[X1_SRC_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[X1_OFFSET]]
// CHECK-NEXT: %[[X1_VALUE:[0-9a-zA-Z_.-]+]] = array.read %[[X1_SOURCE]][%[[X1_SRC_INDEX]]]
// TEMPLATED: %[[X1_CHILD_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 64 :
// TEMPLATED-NEXT: %[[X1_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[X1_CHILD_OFFSET]]
// CONCRETE: %[[X1_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %{{[0-9a-zA-Z_.-]+}}
// CHECK-NEXT: %[[X1_INPUTS:[0-9a-zA-Z_.-]+]] = array.read %[[INPUTS]][%[[X1_INDEX]]]
// CHECK-NEXT: %[[X1_STATE:[0-9a-zA-Z_.-]+]] = array.read %[[STATES]][%[[X1_INDEX]]]
// CHECK: %[[X1_BUS:[0-9a-zA-Z_.-]+]] = pod.read %[[X1_INPUTS]][@in]
// CHECK: %[[X1_ARRAY:[0-9a-zA-Z_.-]+]] = pod.read %[[X1_BUS]][@x]
// CHECK: %[[X1_DST_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 1 :
// CHECK-NEXT: %[[X1_DST_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[X1_DST_OFFSET]]
// CHECK: array.write %[[X1_ARRAY]][%[[X1_DST_INDEX]]] = %[[X1_VALUE]]
// CHECK-NEXT: pod.write %[[X1_BUS]][@x] = %[[X1_ARRAY]]
// CHECK-NEXT: pod.write %[[X1_INPUTS]][@in] = %[[X1_BUS]]
// CHECK: scf.if %{{[0-9a-zA-Z_.-]+}} {
// CHECK-NEXT: %[[X1_COUNT:[0-9a-zA-Z_.-]+]] = pod.read %[[X1_STATE]][@count]
// CHECK-NEXT: %[[X1_WRITTEN:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT: %[[X1_REMAINING:[0-9a-zA-Z_.-]+]] = arith.subi %[[X1_COUNT]], %[[X1_WRITTEN]]
// CHECK-NEXT: pod.write %[[X1_STATE]][@count] = %[[X1_REMAINING]]
// CHECK-NEXT: %[[X1_ZERO:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT: %[[X1_READY:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[X1_REMAINING]], %[[X1_ZERO]]
// CHECK-NEXT: scf.if %[[X1_READY]] {
// CHECK: %[[X1_ARG:[0-9a-zA-Z_.-]+]] = pod.read %[[X1_INPUTS]][@in]
// CHECK-NEXT: %[[X1_RESULT:[0-9a-zA-Z_.-]+]] = function.call @[[CHILD]]::@[[CHILD]]::@compute(%[[X1_ARG]])
// CHECK-NEXT: pod.write %[[X1_STATE]][@comp] = %[[X1_RESULT]]
// CHECK-NEXT: }
// CHECK-NEXT: }
// CHECK-NEXT: array.write %[[INPUTS]][%[[X1_INDEX]]] = %[[X1_INPUTS]]
// CHECK-NEXT: array.write %[[STATES]][%[[X1_INDEX]]] = %[[X1_STATE]]

// The scalar y write also consumes exactly one input, not the whole bus.
// CHECK: %[[Y_VALUE:[0-9a-zA-Z_.-]+]] = pod.read %[[SOURCE]][@y]
// TEMPLATED: %[[Y_CHILD_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 64 :
// TEMPLATED-NEXT: %[[Y_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[Y_CHILD_OFFSET]]
// CONCRETE: %[[Y_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %{{[0-9a-zA-Z_.-]+}}
// CHECK-NEXT: %[[Y_INPUTS:[0-9a-zA-Z_.-]+]] = array.read %[[INPUTS]][%[[Y_INDEX]]]
// CHECK-NEXT: %[[Y_STATE:[0-9a-zA-Z_.-]+]] = array.read %[[STATES]][%[[Y_INDEX]]]
// CHECK: %[[Y_BUS:[0-9a-zA-Z_.-]+]] = pod.read %[[Y_INPUTS]][@in]
// CHECK: pod.write %[[Y_BUS]][@y] = %[[Y_VALUE]]
// CHECK-NEXT: pod.write %[[Y_INPUTS]][@in] = %[[Y_BUS]]
// CHECK: scf.if %{{[0-9a-zA-Z_.-]+}} {
// CHECK-NEXT: %[[Y_COUNT:[0-9a-zA-Z_.-]+]] = pod.read %[[Y_STATE]][@count]
// CHECK-NEXT: %[[Y_WRITTEN:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT: %[[Y_REMAINING:[0-9a-zA-Z_.-]+]] = arith.subi %[[Y_COUNT]], %[[Y_WRITTEN]]
// CHECK-NEXT: pod.write %[[Y_STATE]][@count] = %[[Y_REMAINING]]
// CHECK-NEXT: %[[Y_ZERO:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT: %[[Y_READY:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[Y_REMAINING]], %[[Y_ZERO]]
// CHECK-NEXT: scf.if %[[Y_READY]] {
// CHECK: %[[Y_ARG:[0-9a-zA-Z_.-]+]] = pod.read %[[Y_INPUTS]][@in]
// CHECK-NEXT: %[[Y_RESULT:[0-9a-zA-Z_.-]+]] = function.call @[[CHILD]]::@[[CHILD]]::@compute(%[[Y_ARG]])
// CHECK-NEXT: pod.write %[[Y_STATE]][@comp] = %[[Y_RESULT]]
// CHECK-NEXT: }
// CHECK-NEXT: }
// CHECK-NEXT: array.write %[[INPUTS]][%[[Y_INDEX]]] = %[[Y_INPUTS]]
// CHECK-NEXT: array.write %[[STATES]][%[[Y_INDEX]]] = %[[Y_STATE]]

// The last child's output feeds first, then second. Their propagated tags are
// five and six, so Main.out has seven elements even after the unrelated writes.
// TEMPLATED: pod.new { @"$tag$in$size" =
// TEMPLATED-NEXT: %[[FIRST_N:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT: pod.new { @count = %[[FIRST_N]], @params = {{.*}}@comp: !struct.type<@Bump::@Bump<[5]>>
// TEMPLATED: pod.new { @"$tag$in$size" =
// TEMPLATED-NEXT: %[[SECOND_N:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED-NEXT: pod.new { @count = %[[SECOND_N]], @params = {{.*}}@comp: !struct.type<@Bump::@Bump<[6]>>
// CHECK: %[[LAST_OFFSET:[0-9a-zA-Z_.-]+]] = felt.const 127 :
// CHECK-NEXT: %[[LAST_INDEX:[0-9a-zA-Z_.-]+]] = cast.toindex %[[LAST_OFFSET]]
// CHECK-NEXT: %[[LAST_STATE:[0-9a-zA-Z_.-]+]] = array.read {{.*}}[%[[LAST_INDEX]]]
// CHECK-NEXT: %[[LAST_CHILD:[0-9a-zA-Z_.-]+]] = pod.read %[[LAST_STATE]][@comp]
// CHECK-NEXT: %[[LAST_OUT:[0-9a-zA-Z_.-]+]] = struct.readm %[[LAST_CHILD]][@out]
// CHECK-NEXT: pod.write %[[FIRST_INPUTS:[0-9a-zA-Z_.-]+]][@in] = %[[LAST_OUT]]
// CHECK: %[[FIRST_COUNT:[0-9a-zA-Z_.-]+]] = pod.read %[[FIRST_STATE:[0-9a-zA-Z_.-]+]][@count]
// CHECK-NEXT: %[[FIRST_ONE:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT: %[[FIRST_REMAINING:[0-9a-zA-Z_.-]+]] = arith.subi %[[FIRST_COUNT]], %[[FIRST_ONE]]
// CHECK-NEXT: pod.write %[[FIRST_STATE]][@count] = %[[FIRST_REMAINING]]
// CHECK-NEXT: %[[FIRST_ZERO:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT: %[[FIRST_READY:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[FIRST_REMAINING]], %[[FIRST_ZERO]]
// CHECK-NEXT: scf.if %[[FIRST_READY]] {
// CHECK: %[[FIRST_ARG:[0-9a-zA-Z_.-]+]] = pod.read %[[FIRST_INPUTS]][@in]
// CHECK-NEXT: %[[FIRST_RESULT:[0-9a-zA-Z_.-]+]] = function.call @[[FIRST]]::@[[FIRST]]::@compute(%[[FIRST_ARG]])
// CHECK-NEXT: pod.write %[[FIRST_STATE]][@comp] = %[[FIRST_RESULT]]
// CHECK-NEXT: }
// CHECK-NEXT: %[[FIRST_COMP:[0-9a-zA-Z_.-]+]] = pod.read %[[FIRST_STATE]][@comp]
// CHECK-NEXT: %[[FIRST_OUT:[0-9a-zA-Z_.-]+]] = struct.readm %[[FIRST_COMP]][@out]
// CHECK-NEXT: pod.write %[[SECOND_INPUTS:[0-9a-zA-Z_.-]+]][@in] = %[[FIRST_OUT]]
// CHECK: %[[SECOND_COUNT:[0-9a-zA-Z_.-]+]] = pod.read %[[SECOND_STATE:[0-9a-zA-Z_.-]+]][@count]
// CHECK-NEXT: %[[SECOND_ONE:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT: %[[SECOND_REMAINING:[0-9a-zA-Z_.-]+]] = arith.subi %[[SECOND_COUNT]], %[[SECOND_ONE]]
// CHECK-NEXT: pod.write %[[SECOND_STATE]][@count] = %[[SECOND_REMAINING]]
// CHECK-NEXT: %[[SECOND_ZERO:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT: %[[SECOND_READY:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[SECOND_REMAINING]], %[[SECOND_ZERO]]
// CHECK-NEXT: scf.if %[[SECOND_READY]] {
// CHECK: %[[SECOND_ARG:[0-9a-zA-Z_.-]+]] = pod.read %[[SECOND_INPUTS]][@in]
// CHECK-NEXT: %[[SECOND_RESULT:[0-9a-zA-Z_.-]+]] = function.call @[[SECOND]]::@[[SECOND]]::@compute(%[[SECOND_ARG]])
// CHECK-NEXT: pod.write %[[SECOND_STATE]][@comp] = %[[SECOND_RESULT]]
// CHECK-NEXT: }
// TEMPLATED: function.call @Branch::@Branch::@compute() : () -> !struct.type<@Branch::@Branch<[1, 5]>>
// TEMPLATED: function.call @Branch::@Branch::@compute() : () -> !struct.type<@Branch::@Branch<[0, 10]>>
// CHECK-LABEL: function.def @constrain(

// Concrete keeps a loop with four child call sites; templated expands 64 whole
// writes plus 64 * 3 leaf writes. Both also call two Bumps and two Branches.
// CALLS-CONCRETE-LABEL: struct.def @Main{{_[0-9]+}} {
// CALLS-CONCRETE-LABEL: function.def @compute(
// CALLS-CONCRETE-NOT: function.call
// CALLS-CONCRETE-COUNT-8: function.call
// CALLS-CONCRETE-NOT: function.call
// CALLS-CONCRETE-LABEL: function.def @constrain(
// CALLS-TEMPLATED-LABEL: struct.def @Main {
// CALLS-TEMPLATED-LABEL: function.def @compute(
// CALLS-TEMPLATED-NOT: function.call
// CALLS-TEMPLATED-COUNT-260: function.call
// CALLS-TEMPLATED-NOT: function.call
// CALLS-TEMPLATED-LABEL: function.def @constrain(
