// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefixes=CHECK,CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefixes=CHECK,TEMPLATED
// END.

// Nested aggregate temporaries, component outputs, and names reused in sibling scopes.
// Check aggregate types and construction in both compute and constrain, including
// component-output copies and differently typed temporaries in sibling loops.

pragma circom 2.2.3;

bus Pair() { signal x; signal y; }
bus Row() { Pair() points[2]; }
template Forward(N) {
    Pair() input in;
    Pair() output out <== in;
}
template Main() {
    Row() input rows[2];
    Pair() output matrix[2][2] <== [rows[0].points, [rows[1].points[1], rows[1].points[0]]];
    component children[2];
    children[0] = Forward(1);
    children[1] = Forward(2);
    children[0].in <== rows[0].points[0];
    children[1].in <== rows[0].points[1];
    Pair() output copied[2][2] <== [[children[0].out, children[1].out], rows[1].points];
    Row() output row_cubes[2][2][2];
    Pair() output pair_cubes[2][2][2];
    for (var i = 0; i < 2; i++) {
        row_cubes[i] <== [[rows[0], rows[1]], [rows[1], rows[0]]];
    }
    for (var i = 0; i < 2; i++) {
        pair_cubes[i] <== [[rows[0].points[0], rows[0].points[1]], rows[1].points];
    }
    var user_auto[2] = [3, 4];
    signal output numeric <== user_auto[0] + user_auto[1];
}
component main = Main();

// The ordinary user array must retain its own value after aggregate temporaries.
// TEMPLATED: global.def const @[[USER_AUTO:[a-zA-Z0-9_]+]] : !array.type<2 x !felt.type<"bn128">> = [ 3 : <"bn128">, 4 : <"bn128">]

// CHECK-LABEL: struct.def @Main{{(_[0-9]+)?}} {
// CHECK: struct.member @matrix : !array.type<2,2 x [[PAIR:!pod\.type<\[@x: !felt\.type<"bn128">, @y: !felt\.type<"bn128">\]>]]>
// CHECK: struct.member @copied : !array.type<2,2 x [[PAIR]]>
// CHECK: struct.member @row_cubes : !array.type<2,2,2 x [[ROW:!pod\.type<\[@points: !array\.type<2 x !pod\.type<\[@x: !felt\.type<"bn128">, @y: !felt\.type<"bn128">\]>>\]>]]>
// CHECK: struct.member @pair_cubes : !array.type<2,2,2 x [[PAIR]]>
// CONCRETE: struct.member @children : !pod.type<[@idx_0: !struct.type<@Forward_0::@Forward_0<[]>>, @idx_1: !struct.type<@Forward_1::@Forward_1<[]>>]>
// TEMPLATED: struct.member @children : !array.type<2 x !struct.type<@Forward::@Forward<{{.*}}>>>
// CHECK-LABEL: function.def @compute(
// CHECK-SAME: %[[ROWS:[a-zA-Z0-9_.-]+]]: !array.type<2 x [[ROW]]>
// CHECK: %[[SELF:[a-zA-Z0-9_.-]+]] = struct.new

// Build both elements of the reversed Pair row, then insert both matrix rows.
// CONCRETE: %[[REVERSED:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[PAIR]]>
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POINTS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@points]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POS1:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX3:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS1]]
// CONCRETE: array.write %[[REVERSED]]{{\[}}%[[INDEX3]]] = %[[ELEMENT2]] : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POINTS2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@points]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POS2:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX6:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS2]]
// CONCRETE: array.write %[[REVERSED]]{{\[}}%[[INDEX6]]] = %[[ELEMENT4]] : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POINTS3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@points]
// CONCRETE: %[[POS3:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX8:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS3]]
// CONCRETE: array.insert %[[MATRIX:[a-zA-Z0-9_.-]+]]{{\[}}%[[INDEX8]]] = %[[POINTS3]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// CONCRETE: %[[POS4:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX9:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS4]]
// CONCRETE: array.insert %[[MATRIX]]{{\[}}%[[INDEX9]]] = %[[REVERSED]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// CONCRETE: function.call @Forward_1::@Forward_1::@compute(
// CONCRETE: function.call @Forward_0::@Forward_0::@compute(

// Copy both child outputs through a Pair temporary into the second matrix.
// CONCRETE: %[[CHILD_OUTPUTS:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[PAIR]]>
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE1:[a-zA-Z0-9_.-]+]]#0[@idx_0]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = pod.read %[[CHILD1]][@comp]
// CONCRETE: %[[OUTPUT1:[a-zA-Z0-9_.-]+]] = struct.readm %[[CHILD2]][@out]
// CONCRETE: %[[POS5:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX10:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS5]]
// CONCRETE: array.write %[[CHILD_OUTPUTS]]{{\[}}%[[INDEX10]]] = %[[OUTPUT1]] : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE1]]#0[@idx_1]
// CONCRETE: %[[CHILD4:[a-zA-Z0-9_.-]+]] = pod.read %[[CHILD3]][@comp]
// CONCRETE: %[[OUTPUT2:[a-zA-Z0-9_.-]+]] = struct.readm %[[CHILD4]][@out]
// CONCRETE: %[[POS6:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX11:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS6]]
// CONCRETE: array.write %[[CHILD_OUTPUTS]]{{\[}}%[[INDEX11]]] = %[[OUTPUT2]] : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: %[[POS7:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX12:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS7]]
// CONCRETE: array.insert %[[COPIED:[a-zA-Z0-9_.-]+]]{{\[}}%[[INDEX12]]] = %[[CHILD_OUTPUTS]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POINTS4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@points]
// CONCRETE: %[[POS8:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX14:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS8]]
// CONCRETE: array.insert %[[COPIED]]{{\[}}%[[INDEX14]]] = %[[POINTS4]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>

// The first loop builds Row temporaries and inserts both subarrays.
// CONCRETE: scf.while
// CONCRETE: ^bb0(%[[ROW_I:[a-zA-Z0-9_.-]+]]: !felt.type<"bn128">):
// CONCRETE: %[[FORWARD_ROWS:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[ROW]]>
// CONCRETE: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POS9:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX16:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS9]]
// CONCRETE: array.write %[[FORWARD_ROWS]]{{\[}}%[[INDEX16]]] = %[[ELEMENT7]] : <2 x [[ROW]]>, [[ROW]]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POS10:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX18:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS10]]
// CONCRETE: array.write %[[FORWARD_ROWS]]{{\[}}%[[INDEX18]]] = %[[ELEMENT8]] : <2 x [[ROW]]>, [[ROW]]
// CONCRETE: %[[REVERSED_ROWS:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[ROW]]>
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POS11:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX20:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS11]]
// CONCRETE: array.write %[[REVERSED_ROWS]]{{\[}}%[[INDEX20]]] = %[[ELEMENT9]] : <2 x [[ROW]]>, [[ROW]]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POS12:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX22:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS12]]
// CONCRETE: array.write %[[REVERSED_ROWS]]{{\[}}%[[INDEX22]]] = %[[ELEMENT10]] : <2 x [[ROW]]>, [[ROW]]
// CONCRETE: %[[INDEX23:[a-zA-Z0-9_.-]+]] = cast.toindex %[[ROW_I]]
// CONCRETE: %[[POS13:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX24:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS13]]
// CONCRETE: array.insert %[[ROW_CUBES:[a-zA-Z0-9_.-]+]]{{\[}}%[[INDEX23]], %[[INDEX24]]] = %[[FORWARD_ROWS]] : <2,2,2 x [[ROW]]>, <2 x [[ROW]]>
// CONCRETE: %[[INDEX25:[a-zA-Z0-9_.-]+]] = cast.toindex %[[ROW_I]]
// CONCRETE: %[[POS14:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX26:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS14]]
// CONCRETE: array.insert %[[ROW_CUBES]]{{\[}}%[[INDEX25]], %[[INDEX26]]] = %[[REVERSED_ROWS]] : <2,2,2 x [[ROW]]>, <2 x [[ROW]]>

// The sibling loop reuses source names with Pair temporaries, not Row temporaries.
// CONCRETE: scf.while
// CONCRETE: ^bb0(%[[PAIR_I:[a-zA-Z0-9_.-]+]]: !felt.type<"bn128">):
// CONCRETE: %[[PAIR_ROW:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[PAIR]]>
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POINTS5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@points]
// CONCRETE: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS5]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POS15:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX29:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS15]]
// CONCRETE: array.write %[[PAIR_ROW]]{{\[}}%[[INDEX29]]] = %[[ELEMENT12]] : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POINTS6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@points]
// CONCRETE: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POS16:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX32:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS16]]
// CONCRETE: array.write %[[PAIR_ROW]]{{\[}}%[[INDEX32]]] = %[[ELEMENT14]] : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: %[[INDEX33:[a-zA-Z0-9_.-]+]] = cast.toindex %[[PAIR_I]]
// CONCRETE: %[[POS17:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[INDEX34:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS17]]
// CONCRETE: array.insert %[[PAIR_CUBES:[a-zA-Z0-9_.-]+]]{{\[}}%[[INDEX33]], %[[INDEX34]]] = %[[PAIR_ROW]] : <2,2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// CONCRETE: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[POINTS7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@points]
// CONCRETE: %[[INDEX36:[a-zA-Z0-9_.-]+]] = cast.toindex %[[PAIR_I]]
// CONCRETE: %[[POS18:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: %[[INDEX37:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS18]]
// CONCRETE: array.insert %[[PAIR_CUBES]]{{\[}}%[[INDEX36]], %[[INDEX37]]] = %[[POINTS7]] : <2,2,2 x [[PAIR]]>, <2 x [[PAIR]]>

// The user array still contributes 3 + 4.
// CONCRETE: %[[NUMERIC:[a-zA-Z0-9_.-]+]] = felt.const  7 : <"bn128">
// CONCRETE: struct.writem %[[SELF]][@numeric] = %[[NUMERIC]]
// CONCRETE: struct.writem %[[SELF]][@matrix] = %[[MATRIX]]
// CONCRETE: struct.writem %[[SELF]][@copied] = %[[COPIED]]
// CONCRETE: struct.writem %[[SELF]][@row_cubes] = %[[ROW_CUBES]]
// CONCRETE: struct.writem %[[SELF]][@pair_cubes] = %[[PAIR_CUBES]]

// Nested Pair literals retain their element and matrix types.
// TEMPLATED: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[POINTS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@points]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[POINTS2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@points]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[POINTS3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@points]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[REVERSED:[a-zA-Z0-9_.-]+]] = array.new %[[ELEMENT3]], %[[ELEMENT5]] : <2 x [[PAIR]]>
// TEMPLATED: %[[MATRIX:[a-zA-Z0-9_.-]+]] = array.new  : <2,2 x [[PAIR]]>
// TEMPLATED: %[[INDEX6:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: array.insert %[[MATRIX]]{{\[}}%[[INDEX6]]] = %[[POINTS1]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: %[[INDEX7:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: array.insert %[[MATRIX]]{{\[}}%[[INDEX7]]] = %[[REVERSED]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: struct.writem %[[SELF]][@matrix] = %[[MATRIX]]
// TEMPLATED: function.call @Forward::@Forward::@compute(
// TEMPLATED: function.call @Forward::@Forward::@compute(

// The copied row is constructed from both component outputs.
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[TEMP1:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@comp]
// TEMPLATED: %[[OUTPUT1:[a-zA-Z0-9_.-]+]] = struct.readm %[[CHILD1]][@out]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[TEMP1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@comp]
// TEMPLATED: %[[OUTPUT2:[a-zA-Z0-9_.-]+]] = struct.readm %[[CHILD2]][@out]
// TEMPLATED: %[[CHILD_OUTPUTS:[a-zA-Z0-9_.-]+]] = array.new %[[OUTPUT1]], %[[OUTPUT2]] : <2 x [[PAIR]]>
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[POINTS4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@points]
// TEMPLATED: %[[COPIED:[a-zA-Z0-9_.-]+]] = array.new  : <2,2 x [[PAIR]]>
// TEMPLATED: %[[INDEX11:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: array.insert %[[COPIED]]{{\[}}%[[INDEX11]]] = %[[CHILD_OUTPUTS]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: %[[INDEX12:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: array.insert %[[COPIED]]{{\[}}%[[INDEX12]]] = %[[POINTS4]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: struct.writem %[[SELF]][@copied] = %[[COPIED]]

// Each Row loop iteration builds two rows and inserts a complete matrix.
// TEMPLATED: scf.while
// TEMPLATED: ^bb0(%[[ROW_I:[a-zA-Z0-9_.-]+]]: !felt.type<"bn128">):
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[FORWARD_ROWS:[a-zA-Z0-9_.-]+]] = array.new %[[ELEMENT9]], %[[ELEMENT10]] : <2 x [[ROW]]>
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[REVERSED_ROWS:[a-zA-Z0-9_.-]+]] = array.new %[[ELEMENT11]], %[[ELEMENT12]] : <2 x [[ROW]]>
// TEMPLATED: %[[ROW_MATRIX:[a-zA-Z0-9_.-]+]] = array.new  : <2,2 x [[ROW]]>
// TEMPLATED: %[[INDEX17:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: array.insert %[[ROW_MATRIX]]{{\[}}%[[INDEX17]]] = %[[FORWARD_ROWS]] : <2,2 x [[ROW]]>, <2 x [[ROW]]>
// TEMPLATED: %[[INDEX18:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: array.insert %[[ROW_MATRIX]]{{\[}}%[[INDEX18]]] = %[[REVERSED_ROWS]] : <2,2 x [[ROW]]>, <2 x [[ROW]]>
// TEMPLATED: %[[INDEX19:[a-zA-Z0-9_.-]+]] = cast.toindex %[[ROW_I]]
// TEMPLATED: array.insert %[[ROW_CUBES:[a-zA-Z0-9_.-]+]]{{\[}}%[[INDEX19]]] = %[[ROW_MATRIX]] : <2,2,2 x [[ROW]]>, <2,2 x [[ROW]]>

// The sibling loop builds a Pair matrix with the same source variable name.
// TEMPLATED: scf.while
// TEMPLATED: ^bb0(%[[PAIR_I:[a-zA-Z0-9_.-]+]]: !felt.type<"bn128">):
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[POINTS5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@points]
// TEMPLATED: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS5]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[POINTS6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@points]
// TEMPLATED: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[PAIR_ROW:[a-zA-Z0-9_.-]+]] = array.new %[[ELEMENT14]], %[[ELEMENT16]] : <2 x [[PAIR]]>
// TEMPLATED: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[POINTS7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT17]][@points]
// TEMPLATED: %[[PAIR_MATRIX:[a-zA-Z0-9_.-]+]] = array.new  : <2,2 x [[PAIR]]>
// TEMPLATED: %[[INDEX25:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: array.insert %[[PAIR_MATRIX]]{{\[}}%[[INDEX25]]] = %[[PAIR_ROW]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: %[[INDEX26:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: array.insert %[[PAIR_MATRIX]]{{\[}}%[[INDEX26]]] = %[[POINTS7]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: %[[INDEX27:[a-zA-Z0-9_.-]+]] = cast.toindex %[[PAIR_I]]
// TEMPLATED: array.insert %[[PAIR_CUBES:[a-zA-Z0-9_.-]+]]{{\[}}%[[INDEX27]]] = %[[PAIR_MATRIX]] : <2,2,2 x [[PAIR]]>, <2,2 x [[PAIR]]>

// Read the user array, not a generated aggregate temporary.
// TEMPLATED: %[[USER_VALUES:[a-zA-Z0-9_.-]+]] = global.read const @global::@[[USER_AUTO]]
// TEMPLATED: %[[POS1:[a-zA-Z0-9_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED: %[[INDEX28:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS1]]
// TEMPLATED: %[[THREE:[a-zA-Z0-9_.-]+]] = array.read %[[USER_VALUES]]{{\[}}%[[INDEX28]]]
// TEMPLATED: %[[POS2:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED: %[[INDEX29:[a-zA-Z0-9_.-]+]] = cast.toindex %[[POS2]]
// TEMPLATED: %[[FOUR:[a-zA-Z0-9_.-]+]] = array.read %[[USER_VALUES]]{{\[}}%[[INDEX29]]]
// TEMPLATED: %[[NUMERIC:[a-zA-Z0-9_.-]+]] = felt.add %[[THREE]], %[[FOUR]]
// TEMPLATED: struct.writem %[[SELF]][@numeric] = %[[NUMERIC]]
// TEMPLATED: struct.writem %[[SELF]][@row_cubes] = %[[ROW_CUBES]]
// TEMPLATED: struct.writem %[[SELF]][@pair_cubes] = %[[PAIR_CUBES]]

// CHECK-LABEL: function.return
// CHECK-SAME: %[[SELF]]
// CHECK-LABEL: function.def @constrain(

// Constraint generation must recover the same temporary element/subarray types.
// CONCRETE: %[[C_REVERSED:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[PAIR]]>
// CONCRETE: array.write %[[C_REVERSED]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: array.write %[[C_REVERSED]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: %[[C_CHILD_OUTPUTS:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[PAIR]]>
// CONCRETE: array.write %[[C_CHILD_OUTPUTS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: array.write %[[C_CHILD_OUTPUTS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: %[[C_FORWARD_ROWS:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[ROW]]>
// CONCRETE: array.write %[[C_FORWARD_ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[ROW]]>, [[ROW]]
// CONCRETE: array.write %[[C_FORWARD_ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[ROW]]>, [[ROW]]
// CONCRETE: %[[C_REVERSED_ROWS:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[ROW]]>
// CONCRETE: array.write %[[C_REVERSED_ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[ROW]]>, [[ROW]]
// CONCRETE: array.write %[[C_REVERSED_ROWS]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[ROW]]>, [[ROW]]
// CONCRETE: %[[C_PAIR_ROW:[a-zA-Z0-9_.-]+]] = llzk.nondet : !array.type<2 x [[PAIR]]>
// CONCRETE: array.write %[[C_PAIR_ROW]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>, [[PAIR]]
// CONCRETE: array.write %[[C_PAIR_ROW]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>, [[PAIR]]

// Constraint generation must recover the same temporary element/subarray types.
// TEMPLATED: %[[C_REVERSED:[a-zA-Z0-9_.-]+]] = array.new %{{[a-zA-Z0-9_.-]+}}, %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>
// TEMPLATED: %[[C_MATRIX:[a-zA-Z0-9_.-]+]] = array.new  : <2,2 x [[PAIR]]>
// TEMPLATED: array.insert %[[C_MATRIX]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: array.insert %[[C_MATRIX]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[C_REVERSED]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: %[[C_CHILD_OUTPUTS:[a-zA-Z0-9_.-]+]] = array.new %{{[a-zA-Z0-9_.-]+}}, %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>
// TEMPLATED: %[[C_COPIED:[a-zA-Z0-9_.-]+]] = array.new  : <2,2 x [[PAIR]]>
// TEMPLATED: array.insert %[[C_COPIED]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[C_CHILD_OUTPUTS]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: array.insert %[[C_COPIED]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: %[[C_FORWARD_ROWS:[a-zA-Z0-9_.-]+]] = array.new %{{[a-zA-Z0-9_.-]+}}, %{{[a-zA-Z0-9_.-]+}} : <2 x [[ROW]]>
// TEMPLATED: %[[C_REVERSED_ROWS:[a-zA-Z0-9_.-]+]] = array.new %{{[a-zA-Z0-9_.-]+}}, %{{[a-zA-Z0-9_.-]+}} : <2 x [[ROW]]>
// TEMPLATED: %[[C_ROW_MATRIX:[a-zA-Z0-9_.-]+]] = array.new  : <2,2 x [[ROW]]>
// TEMPLATED: array.insert %[[C_ROW_MATRIX]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[C_FORWARD_ROWS]] : <2,2 x [[ROW]]>, <2 x [[ROW]]>
// TEMPLATED: array.insert %[[C_ROW_MATRIX]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[C_REVERSED_ROWS]] : <2,2 x [[ROW]]>, <2 x [[ROW]]>
// TEMPLATED: %[[C_PAIR_ROW:[a-zA-Z0-9_.-]+]] = array.new %{{[a-zA-Z0-9_.-]+}}, %{{[a-zA-Z0-9_.-]+}} : <2 x [[PAIR]]>
// TEMPLATED: %[[C_PAIR_MATRIX:[a-zA-Z0-9_.-]+]] = array.new  : <2,2 x [[PAIR]]>
// TEMPLATED: array.insert %[[C_PAIR_MATRIX]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[C_PAIR_ROW]] : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>
// TEMPLATED: array.insert %[[C_PAIR_MATRIX]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <2,2 x [[PAIR]]>, <2 x [[PAIR]]>

// CHECK-LABEL: function.return
