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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@SubCmp::@SubCmp<[]>>} {
// CHECK-NEXT:    poly.template @Nop {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Nop {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) -> !struct.type<@Nop::@Nop<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Nop::@Nop<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@o] = %[[VAL_0]] : <@Nop::@Nop<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Nop::@Nop<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Nop::@Nop<[@n]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@o] : <@Nop::@Nop<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_8]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmp {
// CHECK-NEXT:      struct.def @SubCmp {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @n : !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:        struct.member @n$inputs : !pod.type<[@i: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) -> !struct.type<@SubCmp::@SubCmp<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_12]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_14]], @params = %[[VAL_13]] }  : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          pod.write %[[VAL_11]][@i] = %[[VAL_9]] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@count] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_16]], %[[VAL_17]] : index
// CHECK-NEXT:          pod.write %[[VAL_15]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// CHECK-NEXT:          scf.if %[[VAL_20]] {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@params] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @Nop::@Nop::@compute(%[[VAL_22]]) : (!felt.type<"bn128">) -> !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:            pod.write %[[VAL_15]][@comp] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_24]][@o] : <@Nop::@Nop<[1]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_10]][@o] = %[[VAL_25]] : <@SubCmp::@SubCmp<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_10]][@n$inputs] = %[[VAL_11]] : <@SubCmp::@SubCmp<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          struct.writem %[[VAL_10]][@n] = %[[VAL_26]] : <@SubCmp::@SubCmp<[]>>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          function.return %[[VAL_10]] : !struct.type<@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmp::@SubCmp<[]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@o] : <@SubCmp::@SubCmp<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@n] : <@SubCmp::@SubCmp<[]>>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@n$inputs] : <@SubCmp::@SubCmp<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_32]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_35]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@o] : <@Nop::@Nop<[1]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_29]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Nop::@Nop::@constrain(%[[VAL_30]], %[[VAL_37]]) : (!struct.type<@Nop::@Nop<[1]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
