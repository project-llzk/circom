// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Nop(n) {
    signal input i;
    signal output o;
    o <== i;
}

template SubCmp() {
    signal input i;
    signal output o;
    component n = Nop(1);
    n.i <== i;
    o <== n.o;
}

component main = SubCmp();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmp::@SubCmp<[]>>} {
// CHECK-NEXT:    poly.template @Nop {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Nop {
// CHECK-NEXT:        struct.member @o : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Nop::@Nop<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Nop::@Nop<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@o] = %[[VAL_0]] : <@Nop::@Nop<[@n]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Nop::@Nop<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@Nop::@Nop<[@n]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@o] : <@Nop::@Nop<[@n]>>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_6]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmp {
// CHECK-NEXT:      struct.def @SubCmp {
// CHECK-NEXT:        struct.member @o : !felt.type {llzk.pub}
// CHECK-NEXT:        struct.member @n : !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:        struct.member @n$inputs : !pod.type<[@i: !felt.type]>
// CHECK-NEXT:        function.def @compute(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@SubCmp::@SubCmp<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]] }  : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type]>
// CHECK-NEXT:          pod.write %[[VAL_11]][@i] = %[[VAL_7]] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_12]], %[[VAL_13]] : index
// CHECK-NEXT:          pod.write %[[VAL_10]][@count] = %[[VAL_14]] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_14]], %[[VAL_15]] : index
// CHECK-NEXT:          scf.if %[[VAL_16]] {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@i] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = function.call @Nop::@Nop::@compute(%[[VAL_17]]) : (!felt.type) -> !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:            pod.write %[[VAL_10]][@comp] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@o] : <@Nop::@Nop<[1]>>, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_8]][@o] = %[[VAL_20]] : <@SubCmp::@SubCmp<[]>>, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_8]][@n$inputs] = %[[VAL_11]] : <@SubCmp::@SubCmp<[]>>, !pod.type<[@i: !felt.type]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          struct.writem %[[VAL_8]][@n] = %[[VAL_21]] : <@SubCmp::@SubCmp<[]>>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          function.return %[[VAL_8]] : !struct.type<@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmp::@SubCmp<[]>>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@o] : <@SubCmp::@SubCmp<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@n] : <@SubCmp::@SubCmp<[]>>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@n$inputs] : <@SubCmp::@SubCmp<[]>>, !pod.type<[@i: !felt.type]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@i] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_27]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@o] : <@Nop::@Nop<[1]>>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_28]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@i] : <[@i: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @Nop::@Nop::@constrain(%[[VAL_25]], %[[VAL_29]]) : (!struct.type<@Nop::@Nop<[1]>>, !felt.type) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
