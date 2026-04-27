// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmp::@SubCmp<[]>>} {
// CHECK-NEXT:    poly.template @Nop {
// CHECK-NEXT:      struct.def @Nop {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Nop::@Nop<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Nop::@Nop<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@o] = %[[VAL_0]] : <@Nop::@Nop<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Nop::@Nop<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@Nop::@Nop<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@o] : <@Nop::@Nop<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmp {
// CHECK-NEXT:      struct.def @SubCmp {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @n : !struct.type<@Nop::@Nop<[]>>
// CHECK-NEXT:        struct.member @n$inputs : !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@SubCmp::@SubCmp<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@Nop::@Nop<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          pod.write %[[VAL_7]][@i] = %[[VAL_5]] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_11]], %[[VAL_12]] : index
// CHECK-NEXT:          pod.write %[[VAL_10]][@count] = %[[VAL_13]] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_13]], %[[VAL_14]] : index
// CHECK-NEXT:          scf.if %[[VAL_15]] {
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@params] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = function.call @Nop::@Nop::@compute(%[[VAL_17]]) : (!felt.type<"bn128">) -> !struct.type<@Nop::@Nop<[]>>
// CHECK-NEXT:            pod.write %[[VAL_10]][@comp] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[]>>, @params: !pod.type<[]>]>, !struct.type<@Nop::@Nop<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[]>>, @params: !pod.type<[]>]>, !struct.type<@Nop::@Nop<[]>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@o] : <@Nop::@Nop<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_6]][@o] = %[[VAL_20]] : <@SubCmp::@SubCmp<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_6]][@n$inputs] = %[[VAL_7]] : <@SubCmp::@SubCmp<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[]>>, @params: !pod.type<[]>]>, !struct.type<@Nop::@Nop<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@n] = %[[VAL_21]] : <@SubCmp::@SubCmp<[]>>, !struct.type<@Nop::@Nop<[]>>
// CHECK-NEXT:          function.return %[[VAL_6]] : !struct.type<@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmp::@SubCmp<[]>>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@o] : <@SubCmp::@SubCmp<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@n] : <@SubCmp::@SubCmp<[]>>, !struct.type<@Nop::@Nop<[]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@n$inputs] : <@SubCmp::@SubCmp<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_28]], @params = %[[VAL_27]] }  : <[@count: index, @comp: !struct.type<@Nop::@Nop<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Nop::@Nop::@constrain(%[[VAL_25]], %[[VAL_30]]) : (!struct.type<@Nop::@Nop<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
