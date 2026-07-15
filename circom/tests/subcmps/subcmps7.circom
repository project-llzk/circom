// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Nop(n) {
    signal input i;
    signal output o;
}

template SubCmp() {
    signal input i;
    signal output o;
    component n[2];
    n[0] = Nop(1);
    n[1] = Nop(1);
    //n[0].i <== i;
    //o <== n[0].o;
}

component main = SubCmp();

// This test is not 100% testable because array support is not complete.
// Currently we only care about having the right type in the field definition.
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@SubCmp::@SubCmp<[]>>} {
// CHECK-NEXT:    poly.template @Nop {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Nop {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) -> !struct.type<@Nop::@Nop<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Nop::@Nop<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Nop::@Nop<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Nop::@Nop<[@n]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@o] : <@Nop::@Nop<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmp {
// CHECK-NEXT:      struct.def @SubCmp {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @n : !array.type<2 x !struct.type<@Nop::@Nop<[1]>>>
// CHECK-NEXT:        struct.member @n$inputs : !array.type<2 x !pod.type<[@i: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) -> !struct.type<@SubCmp::@SubCmp<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@i: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_13]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_15]], @params = %[[VAL_14]] }  : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_18]]] = %[[VAL_16]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_19]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_21]], @params = %[[VAL_20]] }  : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_24]]] = %[[VAL_22]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          struct.writem %[[VAL_10]][@n$inputs] = %[[VAL_12]] : <@SubCmp::@SubCmp<[]>>, !array.type<2 x !pod.type<[@i: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Nop::@Nop<[1]>>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_27]] to %[[VAL_26]] step %[[VAL_28]] {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_29]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:            array.write %[[VAL_25]]{{\[}}%[[VAL_29]]] = %[[VAL_31]] : <2 x !struct.type<@Nop::@Nop<[1]>>>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_10]][@n] = %[[VAL_25]] : <@SubCmp::@SubCmp<[]>>, !array.type<2 x !struct.type<@Nop::@Nop<[1]>>>
// CHECK-NEXT:          function.return %[[VAL_10]] : !struct.type<@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmp::@SubCmp<[]>>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@o] : <@SubCmp::@SubCmp<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@n] : <@SubCmp::@SubCmp<[]>>, !array.type<2 x !struct.type<@Nop::@Nop<[1]>>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@n$inputs] : <@SubCmp::@SubCmp<[]>>, !array.type<2 x !pod.type<[@i: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_37]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_40]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_46:[0-9a-zA-Z_\.]+]] = %[[VAL_44]] to %[[VAL_43]] step %[[VAL_45]] {
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_46]]] : <2 x !struct.type<@Nop::@Nop<[1]>>>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_46]]] : <2 x !pod.type<[@i: !felt.type<"bn128">]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Nop::@Nop::@constrain(%[[VAL_47]], %[[VAL_49]]) : (!struct.type<@Nop::@Nop<[1]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
