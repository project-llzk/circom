// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Nested partial writes in loops complete both entries of a mixed component array.

pragma circom 2.2.3;
bus Point() { signal x; signal y; }
bus Points() { Point() points[2]; }
template Sum(N) {
    Points() input in;
    signal output out;
    out <== in.points[0].x + in.points[0].y + in.points[1].x + in.points[1].y + N;
}
template Main() {
    signal input in[4];
    component children[2];
    children[0] = Sum(2);
    children[1] = Sum(3);
    for (var j = 0; j < 2; j++) {
        for (var i = 0; i < 2; i++) {
            children[j].in.points[i].x <== in[2*i];
            children[j].in.points[i].y <== in[2*i + 1];
        }
    }
    signal output out;
    out <== children[0].out + children[1].out;
}
component main = Main();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_2::@Main_2<[]>>} {
// CONCRETE-NEXT:    poly.template @Main_2 {
// CONCRETE-NEXT:      struct.def @Main_2 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @children : !pod.type<[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>
// CONCRETE-NEXT:        struct.member @children$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Main_2::@Main_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_2]] }  : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_4]], @idx_1 = %[[VAL_6]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_7]], %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_8]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !felt.type<"bn128">) {
// CONCRETE-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_14]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_15]]) %[[VAL_11]], %[[VAL_12]], %[[VAL_13]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_16]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_17]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_19]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !felt.type<"bn128">) {
// CONCRETE-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_23]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_25]]) %[[VAL_21]], %[[VAL_22]], %[[VAL_23]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_29]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_31]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_33]], %[[VAL_35]] : index
// CONCRETE-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_34]], %[[VAL_36]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_33]], %[[VAL_38]] : index
// CONCRETE-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_34]], %[[VAL_39]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_40]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                  %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_47]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  pod.write %[[VAL_48]][@x] = %[[VAL_32]] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  array.write %[[VAL_46]]{{\[}}%[[VAL_47]]] = %[[VAL_48]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  pod.write %[[VAL_45]][@points] = %[[VAL_46]] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_44]][@in] = %[[VAL_45]] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                  pod.write %[[VAL_27]][@idx_1] = %[[VAL_44]] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@count] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_50]], %[[VAL_51]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_43]][@count] = %[[VAL_52]] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_52]], %[[VAL_53]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_54]] {
// CONCRETE-NEXT:                    %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@params] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    %[[VAL_57:[0-9a-zA-Z_\.]+]] = function.call @Sum_1::@Sum_1::@compute(%[[VAL_56]]) : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_43]][@comp] = %[[VAL_57]] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  pod.write %[[VAL_26]][@idx_1] = %[[VAL_43]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_26]], %[[VAL_27]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_58:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_37]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_63]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    pod.write %[[VAL_64]][@x] = %[[VAL_32]] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    array.write %[[VAL_62]]{{\[}}%[[VAL_63]]] = %[[VAL_64]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    pod.write %[[VAL_61]][@points] = %[[VAL_62]] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_60]][@in] = %[[VAL_61]] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_27]][@idx_0] = %[[VAL_60]] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@count] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_66]], %[[VAL_67]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_59]][@count] = %[[VAL_68]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_68]], %[[VAL_69]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_70]] {
// CONCRETE-NEXT:                      %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@params] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                      %[[VAL_73:[0-9a-zA-Z_\.]+]] = function.call @Sum_0::@Sum_0::@compute(%[[VAL_72]]) : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_59]][@comp] = %[[VAL_73]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_26]][@idx_0] = %[[VAL_59]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_26]], %[[VAL_27]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_74:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_75:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_74]], %[[VAL_75]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_58]]#0, %[[VAL_58]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_42]]#0, %[[VAL_42]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_76]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_77]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_80]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_82]], %[[VAL_84]] : index
// CONCRETE-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_83]], %[[VAL_85]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_82]], %[[VAL_87]] : index
// CONCRETE-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_83]], %[[VAL_88]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>) {
// CONCRETE-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_89]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>) {
// CONCRETE-NEXT:                  %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]]#1[@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                  %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_96]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  pod.write %[[VAL_97]][@y] = %[[VAL_81]] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  array.write %[[VAL_95]]{{\[}}%[[VAL_96]]] = %[[VAL_97]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  pod.write %[[VAL_94]][@points] = %[[VAL_95]] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  pod.write %[[VAL_93]][@in] = %[[VAL_94]] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                  pod.write %[[VAL_41]]#1[@idx_1] = %[[VAL_93]] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@count] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                  %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_99]], %[[VAL_100]] : index
// CONCRETE-NEXT:                  pod.write %[[VAL_92]][@count] = %[[VAL_101]] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                  %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                  %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_101]], %[[VAL_102]] : index
// CONCRETE-NEXT:                  scf.if %[[VAL_103]] {
// CONCRETE-NEXT:                    %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@params] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                    %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    %[[VAL_106:[0-9a-zA-Z_\.]+]] = function.call @Sum_1::@Sum_1::@compute(%[[VAL_105]]) : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_92]][@comp] = %[[VAL_106]] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  pod.write %[[VAL_41]]#0[@idx_1] = %[[VAL_92]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                  scf.yield %[[VAL_41]]#0, %[[VAL_41]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  %[[VAL_107:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_86]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>) {
// CONCRETE-NEXT:                    %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]]#1[@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_112]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_113]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    pod.write %[[VAL_113]][@y] = %[[VAL_81]] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    array.write %[[VAL_111]]{{\[}}%[[VAL_112]]] = %[[VAL_113]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    pod.write %[[VAL_110]][@points] = %[[VAL_111]] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    pod.write %[[VAL_109]][@in] = %[[VAL_110]] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    pod.write %[[VAL_41]]#1[@idx_0] = %[[VAL_109]] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@count] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:                    %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_115]], %[[VAL_116]] : index
// CONCRETE-NEXT:                    pod.write %[[VAL_108]][@count] = %[[VAL_117]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:                    %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:                    %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_117]], %[[VAL_118]] : index
// CONCRETE-NEXT:                    scf.if %[[VAL_119]] {
// CONCRETE-NEXT:                      %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@params] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:                      %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                      %[[VAL_122:[0-9a-zA-Z_\.]+]] = function.call @Sum_0::@Sum_0::@compute(%[[VAL_121]]) : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:                      pod.write %[[VAL_108]][@comp] = %[[VAL_122]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:                    }
// CONCRETE-NEXT:                    pod.write %[[VAL_41]]#0[@idx_0] = %[[VAL_108]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_41]]#0, %[[VAL_41]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                    %[[VAL_123:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>
// CONCRETE-NEXT:                    %[[VAL_124:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                    scf.yield %[[VAL_123]], %[[VAL_124]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                  scf.yield %[[VAL_107]]#0, %[[VAL_107]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield %[[VAL_91]]#0, %[[VAL_91]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_90]]#0, %[[VAL_90]]#1, %[[VAL_126]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_127]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_20]]#0, %[[VAL_20]]#1, %[[VAL_128]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_130]][@out] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@comp] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_133]][@out] : <@Sum_1::@Sum_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_131]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_135]] : <@Main_2::@Main_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@children$inputs] = %[[VAL_10]]#1 : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]]#0[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]]#0[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@comp] : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_137]], @idx_1 = %[[VAL_139]] }  : <[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@children] = %[[VAL_140]] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@Main_2::@Main_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_141:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_2::@Main_2<[]>>, %[[VAL_142:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_141]][@out] : <@Main_2::@Main_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_141]][@children] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>
// CONCRETE-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_141]][@children$inputs] : <@Main_2::@Main_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_148:[0-9a-zA-Z_\.]+]] = %[[VAL_146]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_148]], %[[VAL_149]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_150]]) %[[VAL_148]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_151:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_154:[0-9a-zA-Z_\.]+]] = %[[VAL_152]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_154]], %[[VAL_155]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.condition(%[[VAL_156]]) %[[VAL_154]] : !felt.type<"bn128">
// CONCRETE-NEXT:            } do {
// CONCRETE-NEXT:            ^bb0(%[[VAL_157:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_158]], %[[VAL_157]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_159]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]{{\[}}%[[VAL_160]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_151]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:              %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_162]], %[[VAL_164]] : index
// CONCRETE-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_163]], %[[VAL_165]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_162]], %[[VAL_167]] : index
// CONCRETE-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_163]], %[[VAL_168]] : i1, i1
// CONCRETE-NEXT:              scf.execute_region {
// CONCRETE-NEXT:                scf.if %[[VAL_169]] {
// CONCRETE-NEXT:                  %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                  %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_173:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_174:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_172]]{{\[}}%[[VAL_173]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_175]], %[[VAL_161]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  scf.if %[[VAL_166]] {
// CONCRETE-NEXT:                    %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_178]]{{\[}}%[[VAL_179]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_181]], %[[VAL_161]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_182]], %[[VAL_157]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_183]], %[[VAL_184]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_185]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_187:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]{{\[}}%[[VAL_186]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_151]] : !felt.type<"bn128">
// CONCRETE-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant true
// CONCRETE-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_188]], %[[VAL_190]] : index
// CONCRETE-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_189]], %[[VAL_191]] : i1, i1
// CONCRETE-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_188]], %[[VAL_193]] : index
// CONCRETE-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_189]], %[[VAL_194]] : i1, i1
// CONCRETE-NEXT:              scf.execute_region {
// CONCRETE-NEXT:                scf.if %[[VAL_195]] {
// CONCRETE-NEXT:                  %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                  %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_196]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                  %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_197]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                  %[[VAL_199:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CONCRETE-NEXT:                  %[[VAL_200:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_198]]{{\[}}%[[VAL_199]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                  %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                  constrain.eq %[[VAL_201]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                } else {
// CONCRETE-NEXT:                  scf.if %[[VAL_192]] {
// CONCRETE-NEXT:                    %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:                    %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:                    %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_203]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:                    %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CONCRETE-NEXT:                    %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_204]]{{\[}}%[[VAL_205]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:                    %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:                    constrain.eq %[[VAL_207]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:                  } else {
// CONCRETE-NEXT:                  }
// CONCRETE-NEXT:                }
// CONCRETE-NEXT:                scf.yield
// CONCRETE-NEXT:              }
// CONCRETE-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_157]], %[[VAL_208]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:              scf.yield %[[VAL_209]] : !felt.type<"bn128">
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_151]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_211]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_0] : <[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_212]][@out] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_1] : <[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_214]][@out] : <@Sum_1::@Sum_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_213]], %[[VAL_215]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_143]], %[[VAL_216]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_0] : <[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_0] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          function.call @Sum_0::@Sum_0::@constrain(%[[VAL_217]], %[[VAL_219]]) : (!struct.type<@Sum_0::@Sum_0<[]>>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@idx_1] : <[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>, !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@idx_1] : <[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// CONCRETE-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// CONCRETE-NEXT:          function.call @Sum_1::@Sum_1::@constrain(%[[VAL_220]], %[[VAL_222]]) : (!struct.type<@Sum_1::@Sum_1<[]>>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Sum_0 {
// CONCRETE-NEXT:      struct.def @Sum_0 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_223:[0-9a-zA-Z_\.]+]]: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]> {function.arg_name = "in"}) -> !struct.type<@Sum_0::@Sum_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_223]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_226]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_225]]{{\[}}%[[VAL_227]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_228]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_223]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_231]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_230]]{{\[}}%[[VAL_232]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_233]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_229]], %[[VAL_234]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_223]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_237]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_236]]{{\[}}%[[VAL_238]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_235]], %[[VAL_240]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_223]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_242]]{{\[}}%[[VAL_244]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_241]], %[[VAL_246]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_247]], %[[VAL_248]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_224]][@out] = %[[VAL_249]] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_224]] : !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_250:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum_0::@Sum_0<[]>>, %[[VAL_251:[0-9a-zA-Z_\.]+]]: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_250]][@out] : <@Sum_0::@Sum_0<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_251]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_254]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_253]]{{\[}}%[[VAL_255]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_256]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_251]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_259]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_258]]{{\[}}%[[VAL_260]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_261]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_257]], %[[VAL_262]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_251]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_265]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_264]]{{\[}}%[[VAL_266]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_267]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_263]], %[[VAL_268]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_251]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_271]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_270]]{{\[}}%[[VAL_272]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_273]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_269]], %[[VAL_274]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_275]], %[[VAL_276]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_252]], %[[VAL_277]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @Sum_1 {
// CONCRETE-NEXT:      struct.def @Sum_1 {
// CONCRETE-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_278:[0-9a-zA-Z_\.]+]]: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]> {function.arg_name = "in"}) -> !struct.type<@Sum_1::@Sum_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_278]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_281]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_283:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_280]]{{\[}}%[[VAL_282]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_284:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_283]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_285:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_278]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_287:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_288:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_285]]{{\[}}%[[VAL_287]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_288]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_284]], %[[VAL_289]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_291:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_278]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_293:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_294:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_291]]{{\[}}%[[VAL_293]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_295:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_294]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_290]], %[[VAL_295]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_297:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_278]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_300:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_297]]{{\[}}%[[VAL_299]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_302:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_296]], %[[VAL_301]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_303:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_304:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_302]], %[[VAL_303]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_279]][@out] = %[[VAL_304]] : <@Sum_1::@Sum_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_279]] : !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_305:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum_1::@Sum_1<[]>>, %[[VAL_306:[0-9a-zA-Z_\.]+]]: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_305]][@out] : <@Sum_1::@Sum_1<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_308:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_306]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_310:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_309]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_308]]{{\[}}%[[VAL_310]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_311]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_306]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_314:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_315:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_314]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_316:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_313]]{{\[}}%[[VAL_315]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_316]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_318:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_312]], %[[VAL_317]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_306]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_320]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_319]]{{\[}}%[[VAL_321]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_322]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_318]], %[[VAL_323]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_306]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// CONCRETE-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_327:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_326]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_325]]{{\[}}%[[VAL_327]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_329:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_328]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_324]], %[[VAL_329]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_330]], %[[VAL_331]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_307]], %[[VAL_332]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// TEMPLATED-NEXT:    poly.template @Main {
// TEMPLATED-NEXT:      struct.def @Main {
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @children : !array.type<2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:        struct.member @children$inputs : !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_4]] }  : <[@N: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_6]], @params = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_7]] : (!pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_9]]] = %[[VAL_10]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_11]] }  : <[@N: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_13]], @params = %[[VAL_12]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_14]] : (!pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_16]]] = %[[VAL_17]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !felt.type<"bn128">) {
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_20]], %[[VAL_21]], %[[VAL_22]] : !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_25]], %[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_26]], %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_28]]) : (!array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !felt.type<"bn128">) {
// TEMPLATED-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_32]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_34]]) %[[VAL_30]], %[[VAL_31]], %[[VAL_32]] : !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, %[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_38]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_40]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_42]]] : <2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// TEMPLATED-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_42]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_47]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              pod.write %[[VAL_48]][@x] = %[[VAL_41]] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              array.write %[[VAL_46]]{{\[}}%[[VAL_47]]] = %[[VAL_48]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              pod.write %[[VAL_45]][@points] = %[[VAL_46]] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_43]][@in] = %[[VAL_45]] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_50]], %[[VAL_51]] : index
// TEMPLATED-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_52]], %[[VAL_53]], %[[VAL_51]] : index
// TEMPLATED-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_54]], %[[VAL_55]] : index
// TEMPLATED-NEXT:              scf.if %[[VAL_56]] {
// TEMPLATED-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_57]], %[[VAL_58]] : index
// TEMPLATED-NEXT:                pod.write %[[VAL_44]][@count] = %[[VAL_59]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_59]], %[[VAL_60]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_61]] {
// TEMPLATED-NEXT:                  %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                  %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@N] : <[@N: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_66:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_63]]) {(%[[VAL_65]])} : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  pod.write %[[VAL_44]][@comp] = %[[VAL_66]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              array.write %[[VAL_36]]{{\[}}%[[VAL_42]]] = %[[VAL_43]] : <2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// TEMPLATED-NEXT:              array.write %[[VAL_35]]{{\[}}%[[VAL_42]]] = %[[VAL_44]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_67]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_68]], %[[VAL_69]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_71]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_73]]] : <2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// TEMPLATED-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_73]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_78]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              pod.write %[[VAL_79]][@y] = %[[VAL_72]] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              array.write %[[VAL_77]]{{\[}}%[[VAL_78]]] = %[[VAL_79]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              pod.write %[[VAL_76]][@points] = %[[VAL_77]] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_74]][@in] = %[[VAL_76]] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_81]], %[[VAL_82]] : index
// TEMPLATED-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_83]], %[[VAL_84]], %[[VAL_82]] : index
// TEMPLATED-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_85]], %[[VAL_86]] : index
// TEMPLATED-NEXT:              scf.if %[[VAL_87]] {
// TEMPLATED-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_88]], %[[VAL_89]] : index
// TEMPLATED-NEXT:                pod.write %[[VAL_75]][@count] = %[[VAL_90]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_90]], %[[VAL_91]] : index
// TEMPLATED-NEXT:                scf.if %[[VAL_92]] {
// TEMPLATED-NEXT:                  %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">]>
// TEMPLATED-NEXT:                  %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:                  %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@N] : <[@N: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// TEMPLATED-NEXT:                  %[[VAL_97:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_94]]) {(%[[VAL_96]])} : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                  pod.write %[[VAL_75]][@comp] = %[[VAL_97]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:                }
// TEMPLATED-NEXT:              }
// TEMPLATED-NEXT:              array.write %[[VAL_36]]{{\[}}%[[VAL_73]]] = %[[VAL_74]] : <2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// TEMPLATED-NEXT:              array.write %[[VAL_35]]{{\[}}%[[VAL_73]]] = %[[VAL_75]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_37]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_35]], %[[VAL_36]], %[[VAL_99]] : !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_29]]#0, %[[VAL_29]]#1, %[[VAL_101]] : !array.type<2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]#0{{\[}}%[[VAL_103]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_104]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@out] : <@Sum::@Sum<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]#0{{\[}}%[[VAL_108]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_110]][@out] : <@Sum::@Sum<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_106]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_112]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@children$inputs] = %[[VAL_19]]#1 : <@Main::@Main<[]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_117:[0-9a-zA-Z_\.]+]] = %[[VAL_115]] to %[[VAL_114]] step %[[VAL_116]] {
// TEMPLATED-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]#0{{\[}}%[[VAL_117]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            array.write %[[VAL_113]]{{\[}}%[[VAL_117]]] = %[[VAL_119]] : <2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@children] = %[[VAL_113]] : <@Main::@Main<[]>>, !array.type<2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@Main::@Main<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_120:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>, %[[VAL_121:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@out] : <@Main::@Main<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@children] : <@Main::@Main<[]>>, !array.type<2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@children$inputs] : <@Main::@Main<[]>>, !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_127:[0-9a-zA-Z_\.]+]] = %[[VAL_125]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_127]], %[[VAL_128]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_129]]) %[[VAL_127]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_130:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_131]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:              %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_135:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_133]], %[[VAL_134]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.condition(%[[VAL_135]]) %[[VAL_133]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            } do {
// TEMPLATED-NEXT:            ^bb0(%[[VAL_136:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_137]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_139]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_130]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_141]]] : <2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// TEMPLATED-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_136]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_144]]{{\[}}%[[VAL_145]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_147]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_148]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_149]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_152:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_151]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_153:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_152]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_130]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_154]]] : <2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// TEMPLATED-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_136]] : !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_157]]{{\[}}%[[VAL_158]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_159]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:              constrain.eq %[[VAL_160]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_136]], %[[VAL_161]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:              scf.yield %[[VAL_162]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_130]], %[[VAL_163]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_164]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_165]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_123]]{{\[}}%[[VAL_166]]] : <2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_167]][@out] : <@Sum::@Sum<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_123]]{{\[}}%[[VAL_170]]] : <2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@out] : <@Sum::@Sum<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_168]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_122]], %[[VAL_173]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_177:[0-9a-zA-Z_\.]+]] = %[[VAL_175]] to %[[VAL_174]] step %[[VAL_176]] {
// TEMPLATED-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_123]]{{\[}}%[[VAL_177]]] : <2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>, !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_177]]] : <2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>, !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>
// TEMPLATED-NEXT:            %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@in] : <[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>
// TEMPLATED-NEXT:            function.call @Sum::@Sum::@constrain(%[[VAL_178]], %[[VAL_180]]) : (!struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>, !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> ()
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @Sum {
// TEMPLATED-NEXT:      poly.param @N
// TEMPLATED-NEXT:      struct.def @Sum {
// TEMPLATED-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_181:[0-9a-zA-Z_\.]+]]: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]> {function.arg_name = "in"}) -> !struct.type<@Sum::@Sum<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@N]>>
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_185]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_184]]{{\[}}%[[VAL_186]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_189]]{{\[}}%[[VAL_191]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_188]], %[[VAL_193]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_195]]{{\[}}%[[VAL_197]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_194]], %[[VAL_199]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_201]]{{\[}}%[[VAL_203]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_200]], %[[VAL_205]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_206]], %[[VAL_183]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_182]][@out] = %[[VAL_207]] : <@Sum::@Sum<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_182]] : !struct.type<@Sum::@Sum<[@N]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_208:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@N]>>, %[[VAL_209:[0-9a-zA-Z_\.]+]]: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_208]][@out] : <@Sum::@Sum<[@N]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_213]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_212]]{{\[}}%[[VAL_214]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_217]]{{\[}}%[[VAL_219]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_220]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_216]], %[[VAL_221]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_224]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_223]]{{\[}}%[[VAL_225]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_226]][@x] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_222]], %[[VAL_227]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@points] : <[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>, !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_230]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_231]]] : <2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>, !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@y] : <[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_228]], %[[VAL_233]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_234]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_211]], %[[VAL_235]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
