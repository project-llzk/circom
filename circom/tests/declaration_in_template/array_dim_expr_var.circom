// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
  var s = 6;
  signal input in[s];
  var x[s] = in;
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.expr @"s@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:        poly.yield %[[VAL_0]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"s@[[OFFSET1:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:        poly.yield %[[VAL_1]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        function.def @compute(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !array.type<@"s@[[OFFSET0]]" x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @"s@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_4]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @"s@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <@"s@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_10]], %[[VAL_11]] : <@"s@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_13]] to %[[VAL_12]] step %[[VAL_14]] {
// CHECK-NEXT:            array.write %[[VAL_10]]{{\[}}%[[VAL_15]]] = %[[VAL_9]] : <@"s@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @"s@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @"s@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_16]], %[[VAL_17]] : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_18]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_16]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_17]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]] to %[[VAL_19]] step %[[VAL_21]] {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_22]]] : <@"s@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_10]]{{\[}}%[[VAL_22]]] = %[[VAL_23]] : <@"s@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<@"s@[[OFFSET0]]" x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.read_const @"s@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_26]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @"s@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_28]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.new  : <@"s@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_32]], %[[VAL_33]] : <@"s@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_35]] to %[[VAL_34]] step %[[VAL_36]] {
// CHECK-NEXT:            array.write %[[VAL_32]]{{\[}}%[[VAL_37]]] = %[[VAL_31]] : <@"s@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.read_const @"s@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = poly.read_const @"s@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_38]], %[[VAL_39]] : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_40]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_38]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_39]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_42]] to %[[VAL_41]] step %[[VAL_43]] {
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_44]]] : <@"s@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_32]]{{\[}}%[[VAL_44]]] = %[[VAL_45]] : <@"s@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
