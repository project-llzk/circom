// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template B(n) {
  signal input inB;
}

template A(n) {
  signal input inA;
  component x = B(n * n);
  x.inB <-- inA;
}

component main = A(5);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[5]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.expr @"n_Mul_n@327" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_0]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @x : !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:        struct.member @x$inputs : !pod.type<[@inB: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inA"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_5]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_n@327" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[@inB: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_n@327" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_10]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_12]], @params = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          pod.write %[[VAL_8]][@inB] = %[[VAL_3]] : <[@inB: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_14]], %[[VAL_15]] : index
// CHECK-NEXT:          pod.write %[[VAL_13]][@count] = %[[VAL_16]] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_16]], %[[VAL_17]] : index
// CHECK-NEXT:          scf.if %[[VAL_18]] {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@inB] : <[@inB: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_20]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:            pod.write %[[VAL_13]][@comp] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_4]][@x$inputs] = %[[VAL_8]] : <@A::@A<[@n]>>, !pod.type<[@inB: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:          struct.writem %[[VAL_4]][@x] = %[[VAL_22]] : <@A::@A<[@n]>>, !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:          function.return %[[VAL_4]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inA"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_25]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_n@327" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@x] : <@A::@A<[@n]>>, !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@x$inputs] : <@A::@A<[@n]>>, !pod.type<[@inB: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_n@327" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_31]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@inB] : <[@inB: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_28]], %[[VAL_34]]) : (!struct.type<@B::@B<[@"n_Mul_n@327"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        function.def @compute(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inB"}) -> !struct.type<@B::@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_37]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_36]] : !struct.type<@B::@B<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_39:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n]>>, %[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inB"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_41]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
