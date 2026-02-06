// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
    n.i <-- i;
    o <-- n.o;
}

component main = SubCmp();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@SubCmp<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Nop<[]> {
// CHECK-NEXT:      struct.member @o : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Nop<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Nop<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_1]][@o] = %[[VAL_0]] : <@Nop<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Nop<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@Nop<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@o] : <@Nop<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @SubCmp<[]> {
// CHECK-NEXT:      struct.member @o : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.member @n : !struct.type<@Nop<[]>>
// CHECK-NEXT:      struct.member @n$inputs : !pod.type<[@i: !felt.type]>
// CHECK-NEXT:      function.def @compute(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@SubCmp<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmp<[]>>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_7]] }  : <[@count: index, @comp: !struct.type<@Nop<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type]>
// CHECK-NEXT:        pod.write %[[VAL_9]][@i] = %[[VAL_5]] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@count] : <[@count: index, @comp: !struct.type<@Nop<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_10]], %[[VAL_11]] : index
// CHECK-NEXT:        pod.write %[[VAL_8]][@count] = %[[VAL_12]] : <[@count: index, @comp: !struct.type<@Nop<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_12]], %[[VAL_13]] : index
// CHECK-NEXT:        scf.if %[[VAL_14]] {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@i] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = function.call @Nop::@compute(%[[VAL_15]]) : (!felt.type) -> !struct.type<@Nop<[]>>
// CHECK-NEXT:          pod.write %[[VAL_8]][@comp] = %[[VAL_16]] : <[@count: index, @comp: !struct.type<@Nop<[]>>, @params: !pod.type<[]>]>, !struct.type<@Nop<[]>>
// CHECK-NEXT:        } else {
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@Nop<[]>>, @params: !pod.type<[]>]>, !struct.type<@Nop<[]>>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@o] : <@Nop<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_6]][@o] = %[[VAL_18]] : <@SubCmp<[]>>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_6]][@n$inputs] = %[[VAL_9]] : <@SubCmp<[]>>, !pod.type<[@i: !felt.type]>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@Nop<[]>>, @params: !pod.type<[]>]>, !struct.type<@Nop<[]>>
// CHECK-NEXT:        struct.writem %[[VAL_6]][@n] = %[[VAL_19]] : <@SubCmp<[]>>, !struct.type<@Nop<[]>>
// CHECK-NEXT:        function.return %[[VAL_6]] : !struct.type<@SubCmp<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmp<[]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@o] : <@SubCmp<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@n] : <@SubCmp<[]>>, !struct.type<@Nop<[]>>
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@n$inputs] : <@SubCmp<[]>>, !pod.type<[@i: !felt.type]>
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@i] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:        function.call @Nop::@constrain(%[[VAL_23]], %[[VAL_25]]) : (!struct.type<@Nop<[]>>, !felt.type) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
