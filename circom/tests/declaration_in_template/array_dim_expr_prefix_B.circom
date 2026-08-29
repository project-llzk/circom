// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
  var s = -6;
  signal input in[-s];
  s = -12;
  var x[-s] = in;
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.expr @"Sub_s@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:        poly.yield %[[VAL_0]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"Sub_s@[[OFFSET1:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = arith.constant 12 : index
// CHECK-NEXT:        poly.yield %[[VAL_1]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        function.def @compute(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !array.type<@"Sub_s@[[OFFSET0]]" x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_8]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.new  : <@"Sub_s@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_15]], %[[VAL_16]] : <@"Sub_s@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]] to %[[VAL_17]] step %[[VAL_19]] {
// CHECK-NEXT:            array.write %[[VAL_15]]{{\[}}%[[VAL_20]]] = %[[VAL_14]] : <@"Sub_s@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_23]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_21]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_22]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_25]] to %[[VAL_24]] step %[[VAL_26]] {
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_27]]] : <@"Sub_s@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_15]]{{\[}}%[[VAL_27]]] = %[[VAL_28]] : <@"Sub_s@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_5]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !array.type<@"Sub_s@[[OFFSET0]]" x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_31]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_33]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.new  : <@"Sub_s@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_40]], %[[VAL_41]] : <@"Sub_s@[[OFFSET1]]" x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_43]] to %[[VAL_42]] step %[[VAL_44]] {
// CHECK-NEXT:            array.write %[[VAL_40]]{{\[}}%[[VAL_45]]] = %[[VAL_39]] : <@"Sub_s@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.read_const @"Sub_s@[[OFFSET1]]" : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_48]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_46]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_47]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_50]] to %[[VAL_49]] step %[[VAL_51]] {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_52]]] : <@"Sub_s@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_40]]{{\[}}%[[VAL_52]]] = %[[VAL_53]] : <@"Sub_s@[[OFFSET1]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
