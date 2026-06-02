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
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) -> !struct.type<@Nop::@Nop<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Nop::@Nop<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@o] = %[[VAL_0]] : <@Nop::@Nop<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Nop::@Nop<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@Nop::@Nop<[@n]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@o] : <@Nop::@Nop<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_6]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SubCmp {
// CHECK-NEXT:      struct.def @SubCmp {
// CHECK-NEXT:        struct.member @o : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @n : !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:        struct.member @n$inputs : !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) -> !struct.type<@SubCmp::@SubCmp<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_10]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_12]], @params = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_9]][@i] = %[[VAL_7]] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_14]], %[[VAL_15]] : index
// CHECK-NEXT:          pod.write %[[VAL_13]][@count] = %[[VAL_16]] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_16]], %[[VAL_17]] : index
// CHECK-NEXT:          scf.if %[[VAL_18]] {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@params] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = function.call @Nop::@Nop::@compute(%[[VAL_20]]) : (!felt.type<"bn128">) -> !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:            pod.write %[[VAL_13]][@comp] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@o] : <@Nop::@Nop<[1]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_8]][@o] = %[[VAL_23]] : <@SubCmp::@SubCmp<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_8]][@n$inputs] = %[[VAL_9]] : <@SubCmp::@SubCmp<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          struct.writem %[[VAL_8]][@n] = %[[VAL_24]] : <@SubCmp::@SubCmp<[]>>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          function.return %[[VAL_8]] : !struct.type<@SubCmp::@SubCmp<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmp::@SubCmp<[]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "i"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@o] : <@SubCmp::@SubCmp<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@n] : <@SubCmp::@SubCmp<[]>>, !struct.type<@Nop::@Nop<[1]>>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@n$inputs] : <@SubCmp::@SubCmp<[]>>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_30]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Nop::@Nop<[1]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_33]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@o] : <@Nop::@Nop<[1]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_27]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Nop::@Nop::@constrain(%[[VAL_28]], %[[VAL_35]]) : (!struct.type<@Nop::@Nop<[1]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
