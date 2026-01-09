// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Nop() {
    signal input i;
    signal output o;
    o <== i;
}

template SubCmp() {
    signal input i;
    signal output o;
    component n = Nop();
    n.i <== i;
    o <== n.o;
}

component main = SubCmp();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @Nop<[]> {
// CHECK:           struct.field @o : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute(
// CHECK-SAME:         %[[ARG_0:[0-9a-zA-Z_\.]+]]: !felt.type
// CHECK-SAME:      ) -> !struct.type<@Nop<[]>> attributes {function.allow_witness} {
// CHECK-DAG:         %[[SELF:[0-9a-zA-Z_\.]+]] = struct.new : <@Nop<[]>>
// CHECK-DAG:         struct.writef %[[SELF]][@o] = %[[ARG_0]] : <@Nop<[]>>, !felt.type
// CHECK:             function.return %[[SELF]] : !struct.type<@Nop<[]>>
// CHECK-LABEL:     function.def @constrain(
// CHECK-SAME:        %[[SELF:[0-9a-zA-Z_\.]+]]: !struct.type<@Nop<[]>>,
// CHECK-SAME:        %[[ARG_0:[0-9a-zA-Z_\.]+]]: !felt.type
// CHECK-SAME:      ) attributes {function.allow_constraint} {
// CHECK-DAG:         %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.readf %[[SELF]][@o] : <@Nop<[]>>, !felt.type
// CHECK-DAG:         constrain.eq %[[VAL_0]], %[[ARG_0]] : !felt.type, !felt.type
// CHECK:             function.return
// CHECK-LABEL:  struct.def @SubCmp<[]> {
// CHECK:          struct.field @o : !felt.type {llzk.pub}
// CHECK:          struct.field @n : !struct.type<@Nop<[]>>
// CHECK-LABEL:    function.def @compute(
// CHECK-SAME:       %[[ARG_0:[0-9a-zA-Z_\.]+]]: !felt.type
// CHECK-SAME:     ) -> !struct.type<@SubCmp<[]>> attributes {function.allow_witness} {
// CHECK-DAG:        %[[SELF:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmp<[]>>
// CHECK-DAG:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = function.call @Nop::@compute(%[[ARG_0]]) : (!felt.type) -> !struct.type<@Nop<[]>>
// CHECK-DAG:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_0]][@o] : <@Nop<[]>>, !felt.type
// CHECK-DAG:        struct.writef %[[SELF]][@o] = %[[VAL_1]] : <@SubCmp<[]>>, !felt.type
// CHECK-DAG:        struct.writef %[[SELF]][@n] = %[[VAL_0]] : <@SubCmp<[]>>, !struct.type<@Nop<[]>>
// CHECK:            function.return %[[SELF]] : !struct.type<@SubCmp<[]>>
// CHECK-LABEL:    function.def @constrain(
// CHECK-SAME:       %[[SELF:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmp<[]>>,
// CHECK-SAME:       %[[ARG_0:[0-9a-zA-Z_\.]+]]: !felt.type
// CHECK-SAME:     ) attributes {function.allow_constraint} {
// CHECK-DAG:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.readf %[[SELF]][@n] : <@SubCmp<[]>>, !struct.type<@Nop<[]>>
// CHECK-DAG:        function.call @Nop::@constrain(%[[VAL_0]], %[[ARG_0]]) : (!struct.type<@Nop<[]>>, !felt.type) -> ()
// CHECK-DAG:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_0]][@o] : <@Nop<[]>>, !felt.type
// CHECK-DAG:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.readf %[[SELF]][@o] : <@SubCmp<[]>>, !felt.type
// CHECK-DAG:        constrain.eq %[[VAL_2]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK:            function.return
