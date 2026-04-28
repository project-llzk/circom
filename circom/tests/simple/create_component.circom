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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A::@A<[5]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.expr @"n_Mul_n@327" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_1]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @x : !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:        struct.member @x$inputs : !pod.type<[@inB: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_n@327" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[@inB: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_n@327_0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_7]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_10]] : (!pod.type<[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_6]][@inB] = %[[VAL_2]] : <[@inB: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_12]], %[[VAL_13]] : index
// CHECK-NEXT:          pod.write %[[VAL_11]][@count] = %[[VAL_14]] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_14]], %[[VAL_15]] : index
// CHECK-NEXT:          scf.if %[[VAL_16]] {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@inB] : <[@inB: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_18]]) : (!felt.type<"bn128">) -> !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:            pod.write %[[VAL_11]][@comp] = %[[VAL_19]] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_3]][@x$inputs] = %[[VAL_6]] : <@A::@A<[@n]>>, !pod.type<[@inB: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:          struct.writem %[[VAL_3]][@x] = %[[VAL_20]] : <@A::@A<[@n]>>, !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_n@327" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@x] : <@A::@A<[@n]>>, !struct.type<@B::@B<[@"n_Mul_n@327"]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_21]][@x$inputs] : <@A::@A<[@n]>>, !pod.type<[@inB: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_n@327_0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_27]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@B::@B<[@"n_Mul_n@327_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@inB] : <[@inB: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @B::@B::@constrain(%[[VAL_25]], %[[VAL_30]]) : (!struct.type<@B::@B<[@"n_Mul_n@327"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"n_Mul_n@327_0" {
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_31]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        function.def @compute(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@B::@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n]>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_34]] : !struct.type<@B::@B<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n]>>, %[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
